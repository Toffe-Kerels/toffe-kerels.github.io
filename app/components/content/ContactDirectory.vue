<script setup lang="ts">
import { ref, computed } from 'vue'

const { locale } = useI18n()
const t = (nl: string, en: string) => locale.value === 'en' ? en : nl

const { data: allItems } = await useAsyncData('contact-directory', () => {
  return queryCollection('content')
    .where('path', 'LIKE', '/showcase/%')
    .where('path', 'NOT LIKE', '/en/%')
    .where('hidden', '<>', true)
    .all()
})

// ── Mode ──────────────────────────────────────────────────────────────────────
type Mode = 'idle' | 'guided' | 'advanced'
const mode = ref<Mode>('idle')

// ── Guided flow ───────────────────────────────────────────────────────────────
const guidedStep = ref(0)
const guidedTag = ref('')

const guidedQuestions = computed(() => [
  {
    question: t('Wat voor soort hulp zoek je?', 'What kind of help are you looking for?'),
    options: allTags.value.map(tag => ({ label: tag, value: tag }))
  }
])

function selectGuidedTag(tag: string) {
  guidedTag.value = tag
  guidedStep.value = 1
}

function resetGuided() {
  guidedTag.value = ''
  guidedStep.value = 0
}

// ── Advanced search ───────────────────────────────────────────────────────────
const search = ref('')
const activeTag = ref('')

const allTags = computed(() => {
  if (!allItems.value) return []
  const tags = new Set<string>()
  allItems.value.forEach(item => item.tags?.forEach((tag: string) => tags.add(tag)))
  return Array.from(tags).sort()
})

const hasActiveFilters = computed(() => search.value || activeTag.value)

function toggleTag(tag: string) {
  activeTag.value = activeTag.value === tag ? '' : tag
}

function clearFilters() {
  search.value = ''
  activeTag.value = ''
}

// ── Filtered results ──────────────────────────────────────────────────────────
const filteredItems = computed(() => {
  if (!allItems.value) return []
  let items = allItems.value

  if (mode.value === 'guided') {
    if (!guidedTag.value) return []
    return items.filter(item => item.tags?.includes(guidedTag.value))
  }

  if (mode.value === 'advanced') {
    if (!hasActiveFilters.value) return []

    if (activeTag.value) {
      items = items.filter(item => item.tags?.includes(activeTag.value))
    }

    const q = search.value.trim().toLowerCase()
    if (q) {
      items = items.filter(item =>
        item.title?.toLowerCase().includes(q) ||
        item.description?.toLowerCase().includes(q) ||
        item.tags?.some((tag: string) => tag.toLowerCase().includes(q)) ||
        item.members?.some((m: string) => m.toLowerCase().includes(q)) ||
        item.contact?.address?.toLowerCase().includes(q)
      )
    }

    return items
  }

  return []
})

// ── Helpers ───────────────────────────────────────────────────────────────────
function whatsappHref(phone: string) {
  const digits = phone.replace(/\D/g, '')
  const intl = digits.startsWith('0') ? '31' + digits.slice(1) : digits
  return `https://wa.me/${intl}`
}
</script>

<template>
  <section class="contact-directory">
    <div class="container">

      <!-- Mode selector (idle) -->
      <div v-if="mode === 'idle'" class="mode-selector">
        <h2 class="mode-title">{{ t('Hoe kunnen we je helpen?', 'How can we help you?') }}</h2>
        <p class="mode-sub">{{ t('Kies hoe je wilt zoeken naar de juiste Toffe Kerel.', 'Choose how you want to find the right Toffe Kerel.') }}</p>
        <div class="mode-cards">
          <button class="mode-card" @click="mode = 'guided'">
            <div class="mode-card-icon">💬</div>
            <h3>{{ t('Stel mij vragen', 'Guide me') }}</h3>
            <p>{{ t('Beantwoord een paar vragen en wij vinden het juiste bedrijf voor jou.', 'Answer a few questions and we\'ll find the right company for you.') }}</p>
          </button>
          <button class="mode-card" @click="mode = 'advanced'">
            <div class="mode-card-icon">🔍</div>
            <h3>{{ t('Zelf zoeken', 'Search myself') }}</h3>
            <p>{{ t('Zoek en filter door alle bedrijven in onze directory.', 'Search and filter through all companies in our directory.') }}</p>
          </button>
        </div>
      </div>

      <!-- Guided mode -->
      <div v-else-if="mode === 'guided'" class="guided-flow">
        <button class="back-btn" @click="mode = 'idle'; resetGuided()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
          {{ t('Terug', 'Back') }}
        </button>

        <!-- Step 0: pick a tag -->
        <div v-if="guidedStep === 0" class="guided-step">
          <h2 class="guided-question">{{ guidedQuestions[0].question }}</h2>
          <div class="guided-options">
            <button
              v-for="opt in guidedQuestions[0].options"
              :key="opt.value"
              class="guided-option"
              @click="selectGuidedTag(opt.value)"
            >
              #{{ opt.label }}
            </button>
          </div>
        </div>

        <!-- Step 1: results -->
        <div v-else class="guided-results">
          <div class="guided-result-header">
            <h2 class="guided-question">
              {{ t('Bedrijven voor', 'Companies for') }} <span class="accent-text">#{{ guidedTag }}</span>
            </h2>
            <button class="tag-pill clear-pill" @click="resetGuided()">{{ t('✕ Opnieuw', '✕ Start over') }}</button>
          </div>

          <div v-if="filteredItems.length" class="directory-grid">
            <div
              v-for="(item, index) in filteredItems"
              :key="item.path"
              class="contact-card"
              :style="{ '--delay': (index * 0.07) + 's' }"
            >
              <ContactCard :item="item" :whatsapp-href="whatsappHref" />
            </div>
          </div>
          <div v-else class="empty-state">
            <div class="empty-icon">🤷</div>
            <p>{{ t('Geen bedrijven gevonden voor deze categorie.', 'No companies found for this category.') }}</p>
          </div>
        </div>
      </div>

      <!-- Advanced mode -->
      <div v-else-if="mode === 'advanced'" class="advanced-flow">
        <button class="back-btn" @click="mode = 'idle'; clearFilters()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 12H5M12 5l-7 7 7 7"/></svg>
          {{ t('Terug', 'Back') }}
        </button>

        <!-- Search bar -->
        <div class="search-bar-wrapper">
          <div class="search-input-wrap">
            <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
            <input
              v-model="search"
              type="text"
              class="search-input"
              :placeholder="t('Zoek op naam, specialisme, adres…', 'Search by name, specialty, address…')"
              autofocus
            />
            <button v-if="search" class="search-clear" @click="search = ''" :aria-label="t('Wis zoekopdracht', 'Clear search')">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M18 6 6 18M6 6l12 12"/></svg>
            </button>
          </div>
        </div>

        <!-- Tag cloud -->
        <div class="tag-cloud">
          <button
            v-for="tag in allTags"
            :key="tag"
            class="tag-pill"
            :class="{ active: activeTag === tag }"
            @click="toggleTag(tag)"
          >
            #{{ tag }}
          </button>
          <button v-if="hasActiveFilters" class="tag-pill clear-pill" @click="clearFilters">
            {{ t('✕ Wis', '✕ Clear') }}
          </button>
        </div>

        <!-- Prompt to start searching -->
        <div v-if="!hasActiveFilters" class="search-prompt">
          <div class="search-prompt-icon">👆</div>
          <p>{{ t('Typ een zoekopdracht of kies een categorie om bedrijven te vinden.', 'Type a search query or pick a category to find companies.') }}</p>
        </div>

        <!-- Results -->
        <template v-else>
          <div class="results-meta">
            <span>{{ filteredItems.length }} {{ t(filteredItems.length === 1 ? 'resultaat' : 'resultaten', filteredItems.length === 1 ? 'result' : 'results') }}</span>
          </div>

          <TransitionGroup v-if="filteredItems.length" name="grid" tag="div" class="directory-grid">
            <div
              v-for="(item, index) in filteredItems"
              :key="item.path"
              class="contact-card"
              :style="{ '--delay': (index * 0.07) + 's' }"
            >
              <ContactCard :item="item" :whatsapp-href="whatsappHref" />
            </div>
          </TransitionGroup>

          <div v-else class="empty-state">
            <div class="empty-icon">🔍</div>
            <p>{{ t('Geen bedrijven gevonden.', 'No companies found.') }}</p>
            <button class="empty-reset" @click="clearFilters">{{ t('Filters wissen', 'Clear filters') }}</button>
          </div>
        </template>
      </div>

    </div>
  </section>
</template>


<style scoped>
.contact-directory {
  padding-top: 4rem;
  padding-bottom: 8rem;
}

/* ── Mode selector ── */
.mode-selector {
  text-align: center;
  max-width: 80rem;
  margin: 0 auto;
}

.mode-title {
  font-size: 3.6rem;
  font-weight: 900;
  letter-spacing: -0.04em;
  text-transform: uppercase;
  margin-bottom: 1.6rem;
}

.mode-sub {
  font-size: 1.8rem;
  color: var(--text-muted);
  margin-bottom: 5rem;
}

.mode-cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3.2rem;
}

.mode-card {
  background: var(--glass-bg);
  border: 2px solid var(--glass-border);
  border-radius: 2.4rem;
  padding: 4rem 3.2rem;
  text-align: left;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  font-family: inherit;
  color: var(--text);
}

.mode-card:hover {
  border-color: var(--gradient-1);
  transform: translateY(-6px);
  box-shadow: 0 20px 60px rgba(15, 23, 42, 0.1);
}

.mode-card-icon {
  font-size: 4rem;
  margin-bottom: 2rem;
}

.mode-card h3 {
  font-size: 2.2rem;
  font-weight: 900;
  letter-spacing: -0.03em;
  text-transform: uppercase;
  margin-bottom: 1.2rem;
}

.mode-card p {
  font-size: 1.5rem;
  color: var(--text-muted);
  line-height: 1.6;
}

/* ── Back button ── */
.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  background: none;
  border: none;
  font-family: inherit;
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--text-muted);
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 4rem;
  padding: 0;
  transition: color 0.2s;
}

.back-btn:hover {
  color: var(--text);
}

.back-btn svg {
  width: 1.6rem;
  height: 1.6rem;
}

/* ── Guided flow ── */
.guided-question {
  font-size: 3rem;
  font-weight: 900;
  letter-spacing: -0.04em;
  text-transform: uppercase;
  margin-bottom: 3.2rem;
}

.guided-options {
  display: flex;
  flex-wrap: wrap;
  gap: 1.2rem;
}

.guided-option {
  padding: 1.2rem 2.8rem;
  border-radius: 50px;
  border: 2px solid var(--glass-border);
  background: var(--glass-bg);
  color: var(--text);
  font-family: inherit;
  font-size: 1.5rem;
  font-weight: 700;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  transition: all 0.2s;
}

.guided-option:hover {
  border-color: var(--gradient-1);
  color: var(--gradient-1);
  transform: translateY(-2px);
}

.guided-result-header {
  display: flex;
  align-items: center;
  gap: 2rem;
  margin-bottom: 3.2rem;
  flex-wrap: wrap;
}

.guided-result-header .guided-question {
  margin-bottom: 0;
  flex: 1;
}

/* ── Advanced flow ── */
.search-bar-wrapper {
  margin-bottom: 2.4rem;
}

.search-input-wrap {
  position: relative;
  max-width: 72rem;
}

.search-icon {
  position: absolute;
  left: 1.8rem;
  top: 50%;
  transform: translateY(-50%);
  width: 2rem;
  height: 2rem;
  color: var(--text-muted);
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 1.4rem 4.8rem 1.4rem 5rem;
  border-radius: 50px;
  border: 2px solid var(--glass-border);
  background: var(--glass-bg);
  color: var(--text);
  font-family: inherit;
  font-size: 1.6rem;
  font-weight: 600;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  backdrop-filter: blur(10px);
}

.search-input::placeholder {
  color: var(--text-muted);
  font-weight: 500;
}

.search-input:focus {
  border-color: var(--gradient-1);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.12);
}

.search-clear {
  position: absolute;
  right: 1.6rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  display: flex;
  align-items: center;
  padding: 0.4rem;
}

.search-clear svg {
  width: 1.6rem;
  height: 1.6rem;
}

/* ── Tag cloud ── */
.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 2.4rem;
}

.tag-pill {
  padding: 0.6rem 1.6rem;
  border-radius: 50px;
  border: 1.5px solid var(--glass-border);
  background: transparent;
  color: var(--text-muted);
  font-family: inherit;
  font-size: 1.3rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.tag-pill:hover {
  border-color: var(--gradient-2);
  color: var(--gradient-2);
}

.tag-pill.active {
  background: var(--gradient-2);
  border-color: var(--gradient-2);
  color: #fff;
}

.clear-pill {
  border-color: rgba(239, 68, 68, 0.4);
  color: #ef4444;
}

.clear-pill:hover {
  background: rgba(239, 68, 68, 0.1);
  border-color: #ef4444;
  color: #ef4444;
}

/* ── Search prompt ── */
.search-prompt {
  text-align: center;
  padding: 8rem 0;
}

.search-prompt-icon {
  font-size: 4rem;
  margin-bottom: 2rem;
}

.search-prompt p {
  font-size: 1.8rem;
  color: var(--text-muted);
  max-width: 50rem;
  margin: 0 auto;
  line-height: 1.6;
}

/* ── Results meta ── */
.results-meta {
  font-size: 1.4rem;
  color: var(--text-muted);
  font-weight: 600;
  margin-bottom: 3rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

/* ── Grid ── */
.directory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(38rem, 1fr));
  gap: 3.2rem;
}

/* ── Contact card ── */
.contact-card {
  background: #ffffff;
  border: 1.5px solid rgba(15, 23, 42, 0.08);
  border-radius: 2.4rem;
  padding: 3.2rem;
  display: flex;
  flex-direction: column;
  gap: 0;
  box-shadow: 0 4px 24px rgba(15, 23, 42, 0.06);
  animation: card-in 0.6s cubic-bezier(0.16, 1, 0.3, 1) both;
  animation-delay: var(--delay, 0s);
  transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.contact-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 20px 60px rgba(15, 23, 42, 0.1);
}

@keyframes card-in {
  from { opacity: 0; transform: translateY(24px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ── Empty state ── */
.empty-state {
  text-align: center;
  padding: 10rem 0;
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 2rem;
}

.empty-state p {
  font-size: 2rem;
  color: var(--text-muted);
  margin: 0 auto 3rem;
}

.empty-reset {
  padding: 1.2rem 3rem;
  border-radius: 50px;
  border: 2px solid var(--gradient-1);
  background: transparent;
  color: var(--gradient-1);
  font-family: inherit;
  font-size: 1.4rem;
  font-weight: 800;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  transition: all 0.2s;
}

.empty-reset:hover {
  background: var(--gradient-1);
  color: #fff;
}

/* ── Transitions ── */
.grid-move {
  transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.grid-enter-active {
  transition: opacity 0.35s ease, transform 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}

.grid-leave-active {
  transition: opacity 0.15s ease;
  pointer-events: none;
}

.grid-enter-from {
  opacity: 0;
  transform: scale(0.95);
}

.grid-leave-to {
  opacity: 0;
}

/* ── Responsive ── */
@media (max-width: 768px) {
  .mode-cards {
    grid-template-columns: 1fr;
  }

  .directory-grid {
    grid-template-columns: 1fr;
    gap: 2.4rem;
  }

  .contact-card {
    padding: 2.4rem;
  }

  .guided-question {
    font-size: 2.4rem;
  }
}
</style>
