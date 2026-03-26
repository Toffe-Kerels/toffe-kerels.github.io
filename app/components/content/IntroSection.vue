<script setup lang="ts">
defineProps<{
  stat?: string
  statLabel?: string
  statIcon?: string
}>()
</script>

<template>
  <section class="intro-section">
    <div class="container intro-grid" :class="{ 'intro-grid--no-visual': !stat }">
      <div v-if="stat" class="intro-visual">
        <div class="blob-wrapper floating">
          <div class="blob blob-1"></div>
          <div class="blob blob-2"></div>
          <div class="blob blob-3"></div>
        </div>
        <div class="experience-card glass floating">
          <div class="card-icon">{{ statIcon ?? '✨' }}</div>
          <div class="card-content">
            <span class="card-number">{{ stat }}</span>
            <span class="card-label">{{ statLabel ?? 'Passie' }}</span>
          </div>
        </div>
      </div>
      <div class="intro-content reveal-on-scroll active">
        <slot />
      </div>
    </div>
  </section>
</template>

<style scoped>
.intro-section {
  padding: var(--section-padding) 0;
  overflow: hidden;
  background: radial-gradient(circle at 10% 10%, rgba(79, 70, 229, 0.05) 0%, transparent 40%),
              radial-gradient(circle at 90% 90%, rgba(236, 72, 153, 0.05) 0%, transparent 40%);
}

.intro-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  gap: 10rem;
}

.intro-content {
  position: relative;
  z-index: 2;
}

:deep(h2) {
  margin-bottom: 4rem;
  font-size: clamp(4rem, 6vw, 7rem);
  background: linear-gradient(135deg, var(--primary) 0%, var(--gradient-1) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

:deep(p) {
  font-size: 2.2rem;
  color: var(--text);
  line-height: 1.6;
  opacity: 0.9;
}

.intro-visual {
  position: relative;
  height: 60rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.blob-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
}

.blob {
  position: absolute;
  border-radius: 40% 60% 70% 30% / 40% 50% 60% 50%;
  filter: blur(60px);
  opacity: 0.4;
}

.blob-1 {
  width: 40rem;
  height: 40rem;
  background: var(--gradient-1);
  top: 5%;
  left: 5%;
  animation: blob-morph 10s ease-in-out infinite alternate;
}

.blob-2 {
  width: 35rem;
  height: 35rem;
  background: var(--gradient-2);
  bottom: 10%;
  right: 5%;
  animation: blob-morph 8s ease-in-out infinite alternate-reverse;
}

.blob-3 {
  width: 25rem;
  height: 25rem;
  background: var(--gradient-3);
  top: 40%;
  left: 30%;
  animation: blob-morph 12s ease-in-out infinite alternate;
}

.experience-card {
  position: absolute;
  top: 20%;
  right: 10%;
  padding: 3rem;
  border-radius: 3rem;
  display: flex;
  align-items: center;
  gap: 2rem;
  border: 1px solid var(--glass-border);
  box-shadow: 0 20px 40px rgba(0,0,0,0.05);
  z-index: 10;
}

.card-icon {
  font-size: 4rem;
  background: white;
  width: 7rem;
  height: 7rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 2rem;
  box-shadow: 0 10px 20px rgba(0,0,0,0.05);
}

.card-content {
  display: flex;
  flex-direction: column;
}

.card-number {
  font-size: 3rem;
  font-weight: 900;
  color: var(--text);
  line-height: 1;
}

.card-label {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

@keyframes blob-morph {
  0% { border-radius: 40% 60% 70% 30% / 40% 50% 60% 50%; }
  100% { border-radius: 60% 40% 30% 70% / 50% 60% 40% 60%; }
}

.intro-grid--no-visual {
  grid-template-columns: 1fr;
}

.intro-grid--no-visual .intro-content {
  max-width: 80rem;
}

@media (max-width: 1024px) {
  .intro-grid {
    grid-template-columns: 1fr;
    gap: 8rem;
    text-align: center;
  }
  
  .intro-visual {
    height: 40rem;
    order: 2;
  }

  .experience-card {
    top: auto;
    bottom: 10%;
    right: 50%;
    transform: translateX(50%);
  }
}
</style>
