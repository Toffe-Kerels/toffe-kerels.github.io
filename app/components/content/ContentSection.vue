<template>
  <section class="content-section">
    <div class="container rich-text">
      <slot />
    </div>
  </section>
</template>

<style scoped>
.content-section {
  background-color: var(--white);
  --section-text: #0f172a;
  --section-primary: #0f172a;
  color: var(--section-text);
}

.rich-text {
  max-width: 80rem;
  margin: 0 auto;
}

:deep(h3) {
  margin-top: 4rem;
  margin-bottom: 2rem;
  color: var(--section-primary);
}

:deep(ul) {
  margin-left: 2rem;
  margin-bottom: 2rem;
}

:deep(li) {
  margin-bottom: 1rem;
}

:deep(p) {
  margin-bottom: 2rem;
}
</style>
