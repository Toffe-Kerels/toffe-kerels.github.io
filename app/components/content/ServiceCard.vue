<script setup lang="ts">
defineProps<{
  icon?: string
  title?: string
}>()
</script>

<template>
  <div class="service-card">
    <div v-if="icon" class="service-icon">{{ icon }}</div>
    <h3 v-if="title">{{ title }}</h3>
    <slot />
  </div>
</template>

<style scoped>
.service-card {
  background: linear-gradient(135deg, rgba(79,70,229,0.04) 0%, rgba(236,72,153,0.04) 100%);
  border: 1px solid rgba(0,0,0,0.06);
  border-radius: 1.6rem;
  padding: 2.8rem 2.4rem;
  display: flex;
  flex-direction: column;
  gap: 1.6rem;
  transition: transform 0.25s, box-shadow 0.25s;
}

.service-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(79,70,229,0.12);
}

.service-icon {
  font-size: 2.8rem;
  line-height: 1;
}

h3 {
  font-size: 1.6rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text, #0f172a);
  margin: 0;
}

:deep(p) {
  font-size: 1.6rem;
  color: var(--text-muted, #64748b);
  line-height: 1.6;
  margin: 0;
}
</style>
