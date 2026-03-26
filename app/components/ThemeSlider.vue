<template>
  <div class="theme-slider-container">
    <div class="slider-wrapper glass">
      <button 
        class="reset-btn" 
        @click="resetToDefault" 
        title="Reset to Default Theme"
        aria-label="Reset to Default Theme"
      >
        <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"></path><polyline points="3 4 3 8 7 8"></polyline></svg>
      </button>
      <input
        type="range"
        min="0"
        max="360"
        v-model="hue"
        class="theme-slider"
        aria-label="Change Background Hue"
        @input="updateTheme"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const hue = ref(145) // Default to 145 (Deep blue/slate)
const hueCookie = useCookie('theme-hue', {
  maxAge: 60 * 60 * 24 * 365, // 1 year
  default: () => '145'
})

const resetToDefault = () => {
  hue.value = 145
  updateTheme()
}

const updateTheme = () => {
  if (typeof document === 'undefined') return

  const root = document.documentElement
  
  // 0 is explicitly "White/Classic" mode
  if (parseInt(hue.value.toString()) === 0) {
    root.classList.remove('is-dark')
    root.style.setProperty('--bg', '#ffffff')
    root.style.setProperty('--bg-alt', '#f8fafc')
    root.style.setProperty('--glass-bg', 'rgba(255, 255, 255, 0.7)')
    root.style.setProperty('--glass-border', 'rgba(255, 255, 255, 0.3)')
    root.style.setProperty('--hue', '243')
  } else {
    root.classList.add('is-dark')
    
    // Mancave palette: deep, rich, dark
    // 1-120: Purple/Indigo (260-290)
    // 121-240: Blue/Slate (210-240)
    // 241-360: Orange/Rust (20-40)
    
    let filteredHue = 0
    const val = parseInt(hue.value.toString())
    if (val <= 120) {
      filteredHue = 260 + ((val - 1) / 119) * 30
    } else if (val <= 240) {
      filteredHue = 210 + ((val - 121) / 119) * 30
    } else {
      filteredHue = 20 + ((val - 241) / 119) * 20
    }

    // Mancave look: low lightness (8-12%) and rich saturation (40-60%)
    const bg = `hsl(${filteredHue}, 45%, 10%)`
    const bgAlt = `hsl(${filteredHue}, 40%, 14%)`
    const glassBg = `hsla(${filteredHue}, 45%, 10%, 0.7)`
    const glassBorder = `hsla(${filteredHue}, 45%, 20%, 0.3)`
    
    root.style.setProperty('--bg', bg)
    root.style.setProperty('--bg-alt', bgAlt)
    root.style.setProperty('--glass-bg', glassBg)
    root.style.setProperty('--glass-border', glassBorder)
    root.style.setProperty('--hue', filteredHue.toString())
  }
  
  hueCookie.value = hue.value.toString()
}

onMounted(() => {
  const savedHue = hueCookie.value
  if (savedHue !== null && savedHue !== undefined) {
    hue.value = parseInt(savedHue)
  } else {
    hue.value = 145
  }
  updateTheme()
})
</script>

<style scoped>
.theme-slider-container {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.slider-wrapper {
  padding: 0.5rem 1rem;
  border-radius: 2rem;
  display: flex;
  align-items: center;
  gap: 0.8rem;
  backdrop-filter: blur(10px);
}

.reset-btn {
  background: none;
  border: none;
  padding: 0.4rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
  cursor: pointer;
  opacity: 0.6;
  transition: var(--transition-fast);
  border-radius: 50%;
}

.reset-btn:hover {
  opacity: 1;
  background: rgba(255, 255, 255, 0.1);
  transform: rotate(-30deg);
}

html:not(.is-dark) .reset-btn {
  color: var(--primary);
}

.theme-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 90px;
  height: 4px;
  background: linear-gradient(to right, 
    #ccc, 
    hsl(275, 50%, 40%), 
    hsl(225, 50%, 40%), 
    hsl(30, 50%, 40%)
  );
  outline: none;
  border-radius: 2px;
  cursor: pointer;
}

.theme-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 14px;
  height: 14px;
  background: var(--white);
  border: 2px solid var(--primary);
  border-radius: 50%;
  cursor: pointer;
  transition: var(--transition-fast);
}

.theme-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
}

.theme-slider::-moz-range-thumb {
  width: 14px;
  height: 14px;
  background: var(--white);
  border: 2px solid var(--primary);
  border-radius: 50%;
  cursor: pointer;
  transition: var(--transition-fast);
}

@media (max-width: 768px) {
  .theme-slider {
    width: 130px;
  }
}
</style>
