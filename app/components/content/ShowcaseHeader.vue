<script setup lang="ts">
const { locale } = useI18n()
</script>
<template>
  <div class="section-header text-center reveal-on-scroll active">
    <h2>{{ locale === 'en' ? 'Our' : 'Onze' }} <span class="accent-text">{{ locale === 'en' ? 'Members' : 'Leden' }}</span></h2>
    <p class="section-sub">{{ locale === 'en' ? 'A unique mix of driven companies and passionate individuals.' : 'Een uniek mix van gedreven bedrijven en gepassioneerde personen.' }}</p>
  </div>
</template>

<style scoped>
.section-header {
  padding-top: 6rem;
}

.section-sub {
  font-size: 2rem;
  color: var(--text-muted);
  margin: 2.5rem auto 0;
  max-width: 60rem;
}

@media (max-width: 768px) {
  .section-header {
    padding-top: var(--section-padding-mobile, 10rem);
  }
}
</style>
