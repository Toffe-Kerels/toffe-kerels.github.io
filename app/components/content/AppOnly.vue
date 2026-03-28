<script setup lang="ts">
const { isAppMode } = useAppMode()
</script>

<template>
  <slot v-if="isAppMode" />
</template>
