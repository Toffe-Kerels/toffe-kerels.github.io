<template>
  <div class="layout-default">
    <AppHeader />
    <main class="main-content">
      <slot />
    </main>
    <AppFooter />
  </div>
</template>

<style scoped>
.layout-default {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: var(--bg);
}

.main-content {
  flex: 1;
}
</style>
