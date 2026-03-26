<script setup lang="ts">
defineProps<{
  title?: string
}>()
</script>

<template>
  <section class="services-section">
    <div class="container">
      <h2 v-if="title" class="services-title">{{ title }}</h2>
      <div class="services-grid">
        <slot />
      </div>
    </div>
  </section>
</template>

<style scoped>
.services-section {
  padding: var(--section-padding) 0;
  background: var(--white, #fff);
}

.services-title {
  font-size: clamp(2rem, 3vw, 2.8rem);
  font-weight: 800;
  text-align: center;
  margin-bottom: 4rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text, #0f172a);
  opacity: 0.5;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(28rem, 1fr));
  gap: 3rem;
}

/* Service cards rendered via slot — style :deep children */
:deep(.service-card) {
  background: linear-gradient(135deg, rgba(79,70,229,0.04) 0%, rgba(236,72,153,0.04) 100%);
  border: 1px solid rgba(0,0,0,0.06);
  border-radius: 1.6rem;
  padding: 2.8rem 2.4rem;
  display: flex;
  flex-direction: column;
  gap: 1.6rem;
  transition: transform 0.25s, box-shadow 0.25s;
}

:deep(.service-card:hover) {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(79,70,229,0.12);
}

:deep(.service-icon) {
  font-size: 2.8rem;
  line-height: 1;
}

:deep(.service-card h3) {
  font-size: 1.6rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text, #0f172a);
  margin: 0;
}

:deep(.service-card p) {
  font-size: 1.6rem;
  color: var(--text-muted, #64748b);
  line-height: 1.6;
  margin: 0;
}

@media (max-width: 640px) {
  .services-grid {
    grid-template-columns: 1fr;
  }
}
</style>
