<script setup lang="ts">
const { isAppMode } = useAppMode()
</script>

<template>
  <div class="web-only-wrapper" v-show="!isAppMode">
    <slot />
  </div>
</template>
