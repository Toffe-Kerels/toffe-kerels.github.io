<script setup lang="ts">
defineProps<{
  title?: string
  description?: string
}>()
</script>

<template>
  <div class="og-image">
    <h1 style="font-size: 80px; margin-bottom: 40px; color: white;">{{ title }}</h1>
    <p style="font-size: 40px; color: #f59e0b;">{{ description }}</p>
  </div>
</template>

<style scoped>
.og-image {
  width: 1200px;
  height: 630px;
  background: #0f172a;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 100px;
  text-align: center;
}
</style>
