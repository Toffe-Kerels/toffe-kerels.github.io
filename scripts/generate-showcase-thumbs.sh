#!/usr/bin/env bash
# generate-showcase-thumbs.sh
# Extracts a thumbnail screenshot from each showcase entry's video.
# Usage: ./scripts/generate-showcase-thumbs.sh
# Requires: ffmpeg

set -euo pipefail

CONTENT_DIR="$(dirname "$0")/../content/showcase"
PUBLIC_DIR="$(dirname "$0")/../public"
THUMB_DIR="$PUBLIC_DIR/images/showcase"
SEEK="00:00:01"
SCALE="800:-1"

mkdir -p "$THUMB_DIR"

find "$CONTENT_DIR" -name "index.md" | while read -r mdfile; do
  slug=$(basename "$(dirname "$mdfile")")
  video=$(grep "^video:" "$mdfile" | head -1 | sed 's/^video: *//;s/^"//;s/"$//' || true)
  image=$(grep "^image:" "$mdfile" | head -1 | sed 's/^image: *//;s/^"//;s/"$//' || true)

  if [ -z "$video" ]; then
    echo "SKIP $slug — no video defined"
    continue
  fi

  video_path="$PUBLIC_DIR$video"

  if [ ! -f "$video_path" ]; then
    echo "SKIP $slug — video not found: $video_path"
    continue
  fi

  # Determine output path: use existing image path if set, else default to slug.jpg
  if [ -n "$image" ]; then
    # Normalize extension: .webp -> .jpg, .jpg stays .jpg
    case "$image" in
      *.webp) out_image="${image%.webp}.jpg" ;;
      *.jpg)  out_image="$image" ;;
      *)      out_image="${image}.jpg" ;;
    esac
    out_path="$PUBLIC_DIR$out_image"
  else
    out_image="/images/showcase/${slug}.jpg"
    out_path="$THUMB_DIR/${slug}.jpg"
  fi

  echo "EXTRACT $slug -> $out_image"
  ffmpeg -y -i "$video_path" -ss "$SEEK" -vframes 1 -vf "scale=$SCALE" "$out_path" 2>/dev/null && \
    echo "  OK: $(du -sh "$out_path" | cut -f1)" || echo "  FAILED"

  # Update frontmatter: ensure image line points to the jpg
  if ! grep -q "^image:" "$mdfile" 2>/dev/null; then
    # Insert image line after title line
    sed -i '' "/^title:/a\\
image: \"$out_image\"
" "$mdfile"
    echo "  Added image: $out_image to $mdfile"
  elif [ -n "$image" ] && [ "$image" != "$out_image" ]; then
    sed -i '' "s|image: \"$image\"|image: \"$out_image\"|" "$mdfile"
    echo "  Updated image path: $image -> $out_image"
  fi
done

echo ""
echo "Done. Thumbnails in $THUMB_DIR:"
ls -lh "$THUMB_DIR"
