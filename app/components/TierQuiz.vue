<script setup lang="ts">
const { t } = useI18n()

const emit = defineEmits<{
  close: []
  apply: [plan: 'company' | 'individual' | 'supporter']
}>()

// Scoring: each answer adds points to company / individual / supporter
// answer index 0 = a, 1 = b, 2 = c
const questions = [
  { key: 'q1', scores: [{ company: 2 }, { individual: 1 }, { company: 1, individual: 1 }] },
  { key: 'q2', scores: [{ company: 2 }, { individual: 2 }, { supporter: 2 }] },
  { key: 'q3', scores: [{ company: 2 }, { company: 1, individual: 1 }, { individual: 1 }] },
  { key: 'q4', scores: [{ company: 2 }, { individual: 2 }, { supporter: 2 }] },
  { key: 'q5', scores: [{ individual: 1, company: 1 }, { supporter: 1 }, { supporter: 2 }] },
  { key: 'q6', scores: [{ company: 2 }, { individual: 2 }, { supporter: 2 }] },
  { key: 'q7', scores: [{ company: 2 }, { individual: 2 }, { supporter: 2 }] },
]

const currentStep = ref(0)
const answers = ref<number[]>(Array(questions.length).fill(-1))
const showResult = ref(false)

const totalSteps = questions.length

const currentQuestion = computed(() => questions[currentStep.value])

const selectedAnswer = computed({
  get: () => answers.value[currentStep.value],
  set: (val) => { answers.value[currentStep.value] = val },
})

const canProceed = computed(() => answers.value[currentStep.value] !== -1)

const isLastQuestion = computed(() => currentStep.value === totalSteps - 1)

function next() {
  if (!canProceed.value) return
  if (isLastQuestion.value) {
    showResult.value = true
  } else {
    currentStep.value++
  }
}

function back() {
  if (showResult.value) {
    showResult.value = false
  } else if (currentStep.value > 0) {
    currentStep.value--
  }
}

function retake() {
  currentStep.value = 0
  answers.value = Array(questions.length).fill(-1)
  showResult.value = false
}

type Plan = 'company' | 'individual' | 'supporter'

const result = computed<Plan>(() => {
  const scores: Record<Plan, number> = { company: 0, individual: 0, supporter: 0 }
  answers.value.forEach((answerIdx, qIdx) => {
    if (answerIdx === -1) return
    const scoreMap = questions[qIdx].scores[answerIdx] as Partial<Record<Plan, number>>
    for (const [plan, pts] of Object.entries(scoreMap) as [Plan, number][]) {
      scores[plan] += pts
    }
  })
  return (Object.entries(scores) as [Plan, number][]).reduce((a, b) => b[1] > a[1] ? b : a)[0]
})

const resultData = computed(() => {
  const map: Record<Plan, { title: string; desc: string; color: string; badge: string }> = {
    company: {
      title: t('join.quiz.resultCompanyTitle'),
      desc: t('join.quiz.resultCompanyDesc'),
      color: '#f59e0b',
      badge: t('join.company.price'),
    },
    individual: {
      title: t('join.quiz.resultIndividualTitle'),
      desc: t('join.quiz.resultIndividualDesc'),
      color: 'var(--gradient-1)',
      badge: t('join.individual.price'),
    },
    supporter: {
      title: t('join.quiz.resultSupporterTitle'),
      desc: t('join.quiz.resultSupporterDesc'),
      color: 'var(--gradient-2)',
      badge: t('join.supporter.price'),
    },
  }
  return map[result.value]
})

function onOverlayClick(e: MouseEvent) {
  if ((e.target as HTMLElement).classList.contains('quiz-overlay')) {
    emit('close')
  }
}

function applyNow() {
  emit('apply', result.value)
}

const progressPct = computed(() =>
  showResult.value ? 100 : Math.round((currentStep.value / totalSteps) * 100)
)
</script>

<template>
  <Teleport to="body">
    <div class="quiz-overlay" @click="onOverlayClick">
      <div class="quiz-modal" role="dialog" aria-modal="true">

        <button class="quiz-modal-close" @click="emit('close')" :aria-label="t('join.quiz.close')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M18 6 6 18M6 6l12 12"/>
          </svg>
        </button>

        <div class="quiz-modal-header">
          <h2 class="quiz-modal-title">{{ t('join.quiz.modalTitle') }}</h2>
          <div class="quiz-progress-bar">
            <div class="quiz-progress-fill" :style="{ width: progressPct + '%' }"></div>
          </div>
          <p class="quiz-step-label" v-if="!showResult">
            {{ t('join.quiz.step', { current: currentStep + 1, total: totalSteps }) }}
          </p>
        </div>

        <!-- Question -->
        <Transition name="quiz-slide" mode="out-in">
          <div v-if="!showResult" :key="currentStep" class="quiz-question-block">
            <p class="quiz-question-text">{{ t(`join.quiz.${currentQuestion.key}`) }}</p>
            <div class="quiz-options">
              <button
                v-for="(_, idx) in currentQuestion.scores"
                :key="idx"
                class="quiz-option"
                :class="{ selected: selectedAnswer === idx }"
                @click="selectedAnswer = idx"
              >
                <span class="quiz-option-indicator">
                  <svg v-if="selectedAnswer === idx" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                    <path d="M20 6 9 17l-5-5"/>
                  </svg>
                </span>
                {{ t(`join.quiz.${currentQuestion.key}${['a','b','c'][idx]}`) }}
              </button>
            </div>
          </div>

          <!-- Result -->
          <div v-else key="result" class="quiz-result-block">
            <p class="quiz-result-label">{{ t('join.quiz.resultTitle') }}</p>
            <p class="quiz-result-desc">{{ t('join.quiz.resultDesc') }}</p>
            <div class="quiz-result-card" :style="{ '--result-color': resultData.color }">
              <div class="quiz-result-badge">{{ resultData.badge }} / {{ t('join.perYear') }}</div>
              <h3 class="quiz-result-tier">{{ resultData.title }}</h3>
              <p class="quiz-result-text">{{ resultData.desc }}</p>
            </div>
          </div>
        </Transition>

        <!-- Navigation -->
        <div class="quiz-nav">
          <button
            v-if="currentStep > 0 || showResult"
            class="quiz-nav-back"
            @click="back"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            {{ t('join.quiz.back') }}
          </button>
          <div v-else></div>

          <div class="quiz-nav-right" v-if="!showResult">
            <button
              class="quiz-nav-next"
              :disabled="!canProceed"
              @click="next"
            >
              {{ isLastQuestion ? t('join.quiz.seeResult') : t('join.quiz.next') }}
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </button>
          </div>

          <div class="quiz-nav-right" v-else>
            <button class="quiz-nav-retake" @click="retake">
              {{ t('join.quiz.retake') }}
            </button>
            <button class="quiz-nav-apply" @click="applyNow">
              {{ t('join.quiz.applyNow') }}
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </button>
          </div>
        </div>

      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.quiz-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(6px);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.quiz-modal {
  position: relative;
  background: var(--glass-bg);
  border: 1.5px solid var(--glass-border);
  border-radius: 2.4rem;
  backdrop-filter: blur(30px);
  padding: 4.8rem;
  width: 100%;
  max-width: 62rem;
  max-height: 90vh;
  overflow-y: auto;
}

.quiz-modal-close {
  position: absolute;
  top: 2rem;
  right: 2rem;
  width: 3.6rem;
  height: 3.6rem;
  border-radius: 50%;
  background: rgba(255,255,255,0.06);
  border: 1.5px solid var(--glass-border);
  color: var(--text-muted);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.quiz-modal-close:hover {
  background: rgba(255,255,255,0.12);
  color: var(--white);
}

.quiz-modal-close svg {
  width: 1.6rem;
  height: 1.6rem;
}

.quiz-modal-header {
  margin-bottom: 3.2rem;
}

.quiz-modal-title {
  font-size: 2.8rem;
  color: var(--white);
  text-transform: uppercase;
  letter-spacing: -0.03em;
  margin-bottom: 2rem;
}

.quiz-progress-bar {
  height: 4px;
  background: rgba(255,255,255,0.08);
  border-radius: 2px;
  overflow: hidden;
  margin-bottom: 1.2rem;
}

.quiz-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--gradient-1), var(--gradient-2));
  border-radius: 2px;
  transition: width 0.4s ease;
}

.quiz-step-label {
  font-size: 1.3rem;
  color: var(--text-muted);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.quiz-question-text {
  font-size: 2rem;
  color: var(--white);
  font-weight: 700;
  line-height: 1.4;
  margin-bottom: 2.4rem;
  letter-spacing: -0.02em;
}

.quiz-options {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.quiz-option {
  display: flex;
  align-items: center;
  gap: 1.6rem;
  padding: 1.6rem 2rem;
  background: rgba(255,255,255,0.04);
  border: 1.5px solid var(--glass-border);
  border-radius: 1.2rem;
  color: var(--text);
  font-family: inherit;
  font-size: 1.5rem;
  font-weight: 600;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s;
}

.quiz-option:hover {
  background: rgba(255,255,255,0.08);
  border-color: rgba(255,255,255,0.2);
  color: var(--white);
}

.quiz-option.selected {
  background: rgba(37, 99, 235, 0.15);
  border-color: var(--gradient-1);
  color: var(--white);
}

.quiz-option-indicator {
  flex-shrink: 0;
  width: 2.2rem;
  height: 2.2rem;
  border-radius: 50%;
  border: 2px solid var(--glass-border);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.quiz-option.selected .quiz-option-indicator {
  background: var(--gradient-1);
  border-color: var(--gradient-1);
}

.quiz-option-indicator svg {
  width: 1.2rem;
  height: 1.2rem;
  color: #fff;
}

/* Result */
.quiz-result-label {
  font-size: 1.2rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--gradient-1);
  margin-bottom: 0.8rem;
}

.quiz-result-desc {
  font-size: 1.6rem;
  color: var(--text-muted);
  margin-bottom: 2.4rem;
  line-height: 1.6;
}

.quiz-result-card {
  background: rgba(255,255,255,0.04);
  border: 1.5px solid var(--result-color, var(--glass-border));
  border-radius: 1.6rem;
  padding: 3.2rem;
}

.quiz-result-badge {
  font-size: 1.2rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--result-color, var(--gradient-1));
  margin-bottom: 1.2rem;
}

.quiz-result-tier {
  font-size: 2.8rem;
  color: var(--white);
  text-transform: uppercase;
  letter-spacing: -0.03em;
  margin-bottom: 1.6rem;
}

.quiz-result-text {
  font-size: 1.5rem;
  color: var(--text-muted);
  line-height: 1.7;
}

/* Navigation */
.quiz-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 3.2rem;
  gap: 1.2rem;
}

.quiz-nav-right {
  display: flex;
  align-items: center;
  gap: 1.2rem;
}

.quiz-nav-back {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1.2rem 2rem;
  background: transparent;
  border: 1.5px solid var(--glass-border);
  border-radius: 50px;
  color: var(--text-muted);
  font-family: inherit;
  font-size: 1.3rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  cursor: pointer;
  transition: all 0.2s;
}

.quiz-nav-back:hover {
  border-color: rgba(255,255,255,0.3);
  color: var(--white);
}

.quiz-nav-back svg {
  width: 1.4rem;
  height: 1.4rem;
}

.quiz-nav-next {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1.4rem 3.2rem;
  background: var(--gradient-1);
  border: 2px solid var(--gradient-1);
  border-radius: 50px;
  color: #fff;
  font-family: inherit;
  font-size: 1.4rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  cursor: pointer;
  transition: all 0.25s;
}

.quiz-nav-next:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.quiz-nav-next:not(:disabled):hover {
  background: #1d4ed8;
  border-color: #1d4ed8;
}

.quiz-nav-next svg {
  width: 1.4rem;
  height: 1.4rem;
  transition: transform 0.2s;
}

.quiz-nav-next:not(:disabled):hover svg {
  transform: translateX(4px);
}

.quiz-nav-retake {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1.4rem 2.4rem;
  background: transparent;
  border: 1.5px solid var(--glass-border);
  border-radius: 50px;
  color: var(--text-muted);
  font-family: inherit;
  font-size: 1.3rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  cursor: pointer;
  transition: all 0.2s;
}

.quiz-nav-retake:hover {
  border-color: rgba(255,255,255,0.3);
  color: var(--white);
}

.quiz-nav-apply {
  display: inline-flex;
  align-items: center;
  gap: 0.8rem;
  padding: 1.4rem 3.2rem;
  background: var(--gradient-1);
  border: 2px solid var(--gradient-1);
  border-radius: 50px;
  color: #fff;
  font-family: inherit;
  font-size: 1.4rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  cursor: pointer;
  transition: all 0.25s;
}

.quiz-nav-apply:hover {
  background: #1d4ed8;
  border-color: #1d4ed8;
}

.quiz-nav-apply svg {
  width: 1.4rem;
  height: 1.4rem;
  transition: transform 0.2s;
}

.quiz-nav-apply:hover svg {
  transform: translateX(4px);
}

/* Slide transition */
.quiz-slide-enter-active,
.quiz-slide-leave-active {
  transition: all 0.25s ease;
}

.quiz-slide-enter-from {
  opacity: 0;
  transform: translateX(24px);
}

.quiz-slide-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}

/* Responsive */
@media (max-width: 600px) {
  .quiz-modal {
    padding: 3.2rem 2.4rem;
  }

  .quiz-nav {
    flex-direction: column;
    align-items: stretch;
  }

  .quiz-nav-right {
    flex-direction: column;
  }

  .quiz-nav-back,
  .quiz-nav-next,
  .quiz-nav-retake,
  .quiz-nav-apply {
    width: 100%;
    justify-content: center;
  }
}
</style>
