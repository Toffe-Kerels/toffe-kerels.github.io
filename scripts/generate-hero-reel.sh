#!/usr/bin/env bash
# generate-hero-reel.sh
# Generates multiple hero reel compilations from originals + showcase videos.
# Each reel uses randomly shuffled snippets at random seek offsets with xfade transitions.
# Outputs: public/videos/hero-reel-1.webm .. hero-reel-N.webm (+ .mp4)
#          public/videos/hero-reel.webm/.mp4 → copy of reel-1 (backward compat)
#
# Requires: ffmpeg

set -euo pipefail

cd "$(dirname "$0")/.."

ORIGINALS_DIR="/Volumes/dev/nl.toffekerels/originals"
SHOWCASE_DIR="content/showcase"
PLACEHOLDERS_DIR="public/videos/placeholders"
OUTPUT_DIR="public/videos"
TEMP_DIR="temp_hero_snippets"
SNIPPET_DURATION=3          # seconds per clip
NUM_REELS=15                # how many compilations to generate
SNIPPETS_PER_REEL=6         # clips per reel
MIN_SEEK=2                  # minimum seek offset (seconds)
MAX_SEEK=12                 # maximum seek offset (seconds)
XFADE_DURATION="0.5"        # crossfade duration in seconds
WIDTH=960
HEIGHT=540
FPS=24
CRF=45

mkdir -p "$OUTPUT_DIR"

# ── 1. Collect source videos (originals only) with usable duration ───────────
declare -a SOURCE_VIDEOS=()
declare -a SOURCE_MAX_SEEKS=()

MIN_USABLE=$(echo "$MIN_SEEK $SNIPPET_DURATION" | awk '{print $1 + $2}')

if [ -d "$ORIGINALS_DIR" ]; then
  while IFS= read -r f; do
    dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null || echo 0)
    max_seek=$(echo "$dur $SNIPPET_DURATION" | awk '{printf "%d", int($1 - $2)}')
    if [ "$max_seek" -ge "$MIN_SEEK" ] 2>/dev/null; then
      SOURCE_VIDEOS+=("$f")
      SOURCE_MAX_SEEKS+=("$max_seek")
    else
      echo "[SKIP] Too short for a snippet: $(basename "$f") (${dur}s)"
    fi
  done < <(find "$ORIGINALS_DIR" -name "*.mp4" -o -name "*.webm" | sort)
fi

# Fill up from placeholders if fewer than 4 usable sources
if [ "${#SOURCE_VIDEOS[@]}" -lt 4 ] && [ -d "$PLACEHOLDERS_DIR" ]; then
  while IFS= read -r f; do
    dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f" 2>/dev/null || echo 0)
    max_seek=$(echo "$dur $SNIPPET_DURATION" | awk '{printf "%d", int($1 - $2)}')
    if [ "$max_seek" -ge "$MIN_SEEK" ] 2>/dev/null; then
      SOURCE_VIDEOS+=("$f")
      SOURCE_MAX_SEEKS+=("$max_seek")
    fi
  done < <(find "$PLACEHOLDERS_DIR" -name "*.webm" -o -name "*.mp4" | sort)
fi

if [ "${#SOURCE_VIDEOS[@]}" -eq 0 ]; then
  echo "[ERROR] No usable source videos found."
  exit 1
fi

echo "[INFO] Found ${#SOURCE_VIDEOS[@]} usable source video(s):"
for i in "${!SOURCE_VIDEOS[@]}"; do echo "  ${SOURCE_VIDEOS[$i]} (max seek: ${SOURCE_MAX_SEEKS[$i]}s)"; done

# ── 2. Helper: shuffle stdin lines via awk ───────────────────────────────────
shuffle_lines() {
  awk 'BEGIN{srand()} {lines[NR]=$0} END{
    for(i=NR;i>1;i--){j=int(rand()*i)+1; t=lines[i]; lines[i]=lines[j]; lines[j]=t}
    for(i=1;i<=NR;i++) print lines[i]
  }'
}

# ── 3. Generate N reels ───────────────────────────────────────────────────────
for reel_num in $(seq 1 "$NUM_REELS"); do
  echo ""
  echo "── Generating reel $reel_num of $NUM_REELS ──────────────────────────"

  OUT_WEBM="$OUTPUT_DIR/hero-reel-${reel_num}.webm"
  OUT_MP4="$OUTPUT_DIR/hero-reel-${reel_num}.mp4"

  if [ -f "$OUT_WEBM" ]; then
    echo "[SKIP] Reel $reel_num webm already exists."
    # Re-derive mp4 if missing
    if [ ! -f "$OUT_MP4" ]; then
      echo "[INFO]   Re-deriving mp4..."
      ffmpeg -y -i "$OUT_WEBM" -c:v libx264 -preset fast -crf 28 -pix_fmt yuv420p -movflags +faststart -an "$OUT_MP4" 2>/dev/null && \
        echo "[OK]    $(du -sh "$OUT_MP4" | cut -f1)" || echo "[ERROR] mp4 re-derive failed"
    fi
    continue
  fi

  # Pick SNIPPETS_PER_REEL shuffled source videos with per-video capped seek
  declare -a SELECTED_VIDEOS=()
  declare -a SELECTED_SEEKS=()
  # Build index list, shuffle it
  declare -a IDX_LIST=()
  for ((ii=0; ii<${#SOURCE_VIDEOS[@]}; ii++)); do IDX_LIST+=("$ii"); done
  declare -a SHUFFLED_IDX=()
  while IFS= read -r idx; do SHUFFLED_IDX+=("$idx"); done < <(printf '%s\n' "${IDX_LIST[@]}" | shuffle_lines)
  INDEX=0
  for idx in "${SHUFFLED_IDX[@]}"; do
    [ "$INDEX" -ge "$SNIPPETS_PER_REEL" ] && break
    video="${SOURCE_VIDEOS[$idx]}"
    max_seek="${SOURCE_MAX_SEEKS[$idx]}"
    [ -f "$video" ] || continue
    seek=$(( RANDOM % (max_seek - MIN_SEEK + 1) + MIN_SEEK ))
    SELECTED_VIDEOS+=("$video")
    SELECTED_SEEKS+=("$seek")
    echo "[INFO]   Clip $((INDEX+1)): $(basename "$video") @ ${seek}s (max ${max_seek}s)"
    INDEX=$((INDEX + 1))
  done
  unset IDX_LIST SHUFFLED_IDX

  COUNT="${#SELECTED_VIDEOS[@]}"
  if [ "$COUNT" -eq 0 ]; then
    echo "[ERROR] No clips selected for reel $reel_num, skipping."
    continue
  fi

  # ── Single-pass: trim+normalize each source in filter_complex, then xfade ──
  INPUTS=""
  for ((i = 0; i < COUNT; i++)); do
    INPUTS="$INPUTS -ss ${SELECTED_SEEKS[$i]} -t $SNIPPET_DURATION -i ${SELECTED_VIDEOS[$i]}"
  done

  FILTER=""
  for ((i = 0; i < COUNT; i++)); do
    FILTER="${FILTER}[${i}:v]fps=${FPS},scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=decrease,pad=${WIDTH}:${HEIGHT}:(ow-iw)/2:(oh-ih)/2,setsar=1,settb=1/${FPS}[n${i}];"
  done

  prev="[n0]"
  for ((i = 1; i < COUNT; i++)); do
    offset=$(echo "$i $SNIPPET_DURATION $XFADE_DURATION" | awk '{printf "%.2f", ($1 * ($2 - $3))}')
    out_label="[v${i}]"
    FILTER="${FILTER}${prev}[n${i}]xfade=transition=fade:duration=${XFADE_DURATION}:offset=${offset}${out_label};"
    prev="$out_label"
  done
  FILTER="${FILTER%;}"

  echo "[INFO]   Rendering → $OUT_WEBM"
  # shellcheck disable=SC2086
  ffmpeg -y $INPUTS \
    -filter_complex "$FILTER" \
    -map "$prev" \
    -c:v libvpx-vp9 -crf $CRF -b:v 0 -an \
    "$OUT_WEBM" 2>/dev/null && \
    echo "[OK]    $(du -sh "$OUT_WEBM" | cut -f1)" || echo "[ERROR] reel $reel_num failed"

  # Also produce mp4 for Safari fallback
  if [ -f "$OUT_WEBM" ]; then
    echo "[INFO]   Converting → $OUT_MP4"
    ffmpeg -y -i "$OUT_WEBM" \
      -c:v libx264 -preset fast -crf 28 -pix_fmt yuv420p -movflags +faststart -an \
      "$OUT_MP4" 2>/dev/null && \
      echo "[OK]    $(du -sh "$OUT_MP4" | cut -f1)" || echo "[ERROR] mp4 conversion failed"
  fi

  unset SELECTED_VIDEOS SELECTED_SEEKS IDX_LIST SHUFFLED_IDX
done

# ── 4. Backward-compat copies (reel-1 → hero-reel) ───────────────────────────
if [ -f "$OUTPUT_DIR/hero-reel-1.webm" ]; then
  cp "$OUTPUT_DIR/hero-reel-1.webm" "$OUTPUT_DIR/hero-reel.webm"
  echo ""
  echo "[INFO] Copied reel-1 → hero-reel.webm (backward compat)"
fi
if [ -f "$OUTPUT_DIR/hero-reel-1.mp4" ]; then
  cp "$OUTPUT_DIR/hero-reel-1.mp4" "$OUTPUT_DIR/hero-reel.mp4"
  echo "[INFO] Copied reel-1 → hero-reel.mp4 (backward compat)"
fi


echo ""
echo "Done. Hero reels in $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR"/hero-reel*.webm "$OUTPUT_DIR"/hero-reel*.mp4 2>/dev/null || echo "(none yet)"
