<template>
  <header class="app-header" :class="{ 'is-scrolled': isScrolled }">
    <nav class="container nav-container">
      <NuxtLink 
        :to="localePath('/')" 
        class="logo-brand has-gradient"
        :class="{ 'is-light': !isScrolled || isDarkTheme || true }"
      >
        TOFFE<span>KERELS</span>
      </NuxtLink>
      
      <div class="nav-links glass">
        <NuxtLink 
          v-for="link in navLinks" 
          :key="link.path" 
          :to="localePath(link.path)"
          class="nav-link"
        >
          {{ t(link.name) }}
        </NuxtLink>
      </div>

      <div class="header-actions">
        <ThemeSlider />
        <div class="locale-switcher glass">
          <NuxtLink 
            v-for="loc in locales" 
            :key="loc.code" 
            :to="switchLocalePath(loc.code)"
            :class="{ active: locale === loc.code }"
          >
            {{ loc.code.toUpperCase() }}
          </NuxtLink>
        </div>
        <button 
          class="mobile-menu-btn" 
          aria-label="Menu"
          @click="isMenuOpen = !isMenuOpen"
          :class="{ 'is-active': isMenuOpen }"
        >
          <span></span>
          <span></span>
          <span></span>
        </button>
      </div>
    </nav>

    <!-- Mobile Menu Overlay -->
    <Transition name="menu-reveal">
      <div v-if="isMenuOpen" class="mobile-menu-overlay">
        <div class="menu-reveal-bg"></div>
        <div class="mobile-menu-content container">
          <div class="mobile-nav-links">
            <NuxtLink 
              v-for="(link, index) in navLinks" 
              :key="link.path" 
              :to="localePath(link.path)"
              class="mobile-nav-link"
              :style="{ '--index': index }"
              @click="isMenuOpen = false"
            >
              {{ t(link.name) }}
            </NuxtLink>
          </div>
          
          <div class="mobile-footer">
            <ThemeSlider />
            <div class="mobile-locales">
              <NuxtLink 
                v-for="loc in locales" 
                :key="loc.code" 
                :to="switchLocalePath(loc.code)"
                class="mobile-locale-link"
                :class="{ active: locale === loc.code }"
                @click="isMenuOpen = false"
              >
                {{ loc.name }}
              </NuxtLink>
            </div>
            <p class="mobile-copyright">&copy; {{ new Date().getFullYear() }} Toffe Kerels</p>
          </div>
        </div>
      </div>
    </Transition>
  </header>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
const { t, locales, locale } = useI18n()
const localePath = useLocalePath()
const switchLocalePath = useSwitchLocalePath()
const route = useRoute()

const isScrolled = ref(false)
const isMenuOpen = ref(false)
const isDarkTheme = ref(false)

// Close menu when route changes
watch(() => route.path, () => {
  isMenuOpen.value = false
})

// Check if dark theme is active
const checkDarkTheme = () => {
  isDarkTheme.value = document.documentElement.classList.contains('is-dark')
}

// Watch for DOM changes to detect dark mode toggles from other components
onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  
  // Use MutationObserver to detect class changes on <html>
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        checkDarkTheme()
      }
    })
  })
  
  observer.observe(document.documentElement, { attributes: true })
  checkDarkTheme()
})

// Prevent scroll when menu is open
watch(isMenuOpen, (val) => {
  if (val) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})

const handleScroll = () => {
  isScrolled.value = window.scrollY > 50
}

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const navLinks = computed(() => [
  { name: 'nav.home', path: '/' },
  { name: 'nav.showcase', path: '/showcase' },
  { name: 'nav.map', path: '/map' },
  { name: 'nav.contact', path: '/contact' },
  { name: 'nav.join', path: '/meedoen' }
])
</script>

<style scoped>
.app-header {
  height: 12rem;
  display: flex;
  align-items: center;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  transition: var(--transition-smooth);
}

.app-header.is-scrolled {
  height: 9rem;
  background: var(--glass-bg);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid var(--glass-border);
}

.nav-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.nav-links {
  display: flex;
  gap: 1rem;
  padding: 0.8rem;
  border-radius: 100px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.is-scrolled .nav-links {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
}

.nav-link {
  font-size: 1.2rem;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--white);
  padding: 1.2rem 2.5rem;
  border-radius: 100px;
  transition: var(--transition-fast);
}

.is-scrolled .nav-link {
  color: var(--text);
}

.nav-link:hover,
.nav-link.router-link-active {
  background: var(--white);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  color: var(--gradient-1);
}

.is-scrolled .nav-link:hover,
.is-scrolled .nav-link.router-link-active {
  background: var(--primary);
  color: var(--white);
}

html.is-dark .is-scrolled .nav-link:hover,
html.is-dark .is-scrolled .nav-link.router-link-active {
  background: var(--white);
  color: #0f172a; /* Use original primary color for dark contrast if needed */
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 3rem;
}

@media (max-width: 1200px) {
  .header-actions :deep(.theme-slider-container) {
    display: none;
  }
}

.locale-switcher {
  display: flex;
  gap: 1rem;
  padding: 0.8rem 1.5rem;
  border-radius: 100px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.is-scrolled .locale-switcher {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
}

.locale-switcher a {
  font-size: 1.1rem;
  font-weight: 800;
  color: rgba(255, 255, 255, 0.6);
}

.is-scrolled .locale-switcher a {
  color: var(--text);
}

.locale-switcher a.active {
  color: var(--white);
}

.is-scrolled .locale-switcher a.active {
  color: var(--primary);
}

.mobile-menu-btn {
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  width: 5.4rem;
  height: 5.4rem;
  background: var(--white);
  border-radius: 50%;
  border: 1px solid rgba(0, 0, 0, 0.05);
  cursor: pointer;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  z-index: 2000;
  transition: var(--transition-smooth);
}

html.is-dark .mobile-menu-btn {
  background: #1e293b;
  border-color: rgba(255, 255, 255, 0.1);
}

.is-scrolled .mobile-menu-btn {
  background: var(--primary);
}
html.is-dark .is-scrolled .mobile-menu-btn {
  background: #1e293b;
}
html.is-dark .is-scrolled .mobile-menu-btn span {
  background-color: var(--white);
}

.mobile-menu-btn span {
  display: block;
  width: 2.2rem;
  height: 2px;
  background-color: var(--primary);
  border-radius: 10px;
  transition: var(--transition-smooth);
}

.is-scrolled .mobile-menu-btn span {
  background-color: var(--white);
}

/* Morph to X animation */
.mobile-menu-btn.is-active span:nth-child(1) {
  transform: translateY(0.7rem) rotate(45deg);
}

.mobile-menu-btn.is-active span:nth-child(2) {
  opacity: 0;
  transform: translateX(-1rem);
}

.mobile-menu-btn.is-active span:nth-child(3) {
  transform: translateY(-0.7rem) rotate(-45deg);
}

.mobile-menu-btn.is-active {
  background: var(--gradient-1) !important;
}

.mobile-menu-btn.is-active span {
  background-color: var(--white) !important;
}

/* Mobile Menu Overlay Styles */
.mobile-menu-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  z-index: 1500;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.menu-reveal-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: var(--bg);
  z-index: -1;
}

html:not(.is-dark) .menu-reveal-bg {
  background: var(--white);
}

.menu-reveal-bg::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: 
    radial-gradient(circle at 0% 0%, var(--gradient-1) 0%, transparent 50%),
    radial-gradient(circle at 100% 0%, var(--gradient-2) 0%, transparent 50%),
    radial-gradient(circle at 100% 100%, var(--gradient-3) 0%, transparent 50%),
    radial-gradient(circle at 0% 100%, #10b981 0%, transparent 50%);
  opacity: 0.15;
  filter: blur(100px);
  animation: gradient-shift 10s ease infinite alternate;
}

@keyframes gradient-shift {
  0% { transform: scale(1) translate(0, 0); }
  100% { transform: scale(1.2) translate(5%, 5%); }
}

.mobile-menu-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding-top: 15rem;
  padding-bottom: 5rem;
}

.mobile-nav-links {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  flex: 1;
}

.mobile-nav-link {
  font-size: 5rem;
  font-weight: 900;
  text-transform: uppercase;
  color: var(--primary);
  line-height: 1;
  letter-spacing: -0.05em;
  transition: var(--transition-smooth);
}

html.is-dark .mobile-nav-link {
  color: var(--white);
}

.mobile-nav-link:hover,
.mobile-nav-link.router-link-active {
  color: var(--gradient-1);
  transform: translateX(2rem);
}

.mobile-footer {
  margin-top: auto;
  border-top: 1px solid rgba(128, 128, 128, 0.2);
  padding-top: 4rem;
}

.mobile-locales {
  display: flex;
  gap: 3rem;
  margin-bottom: 3rem;
}

.mobile-locale-link {
  font-size: 1.6rem;
  font-weight: 800;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.mobile-locale-link.active {
  color: var(--gradient-1);
}

.mobile-copyright {
  font-size: 1.2rem;
  color: #999;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

/* Animations */
.menu-reveal-enter-active,
.menu-reveal-leave-active {
  transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}

.menu-reveal-enter-active .menu-reveal-bg,
.menu-reveal-leave-active .menu-reveal-bg {
  transition: all 0.8s cubic-bezier(0.16, 1, 0.3, 1);
}

.menu-reveal-enter-from {
  opacity: 0;
}

.menu-reveal-enter-from .menu-reveal-bg {
  transform: scale(0.5);
  border-radius: 100%;
  opacity: 0;
}

.menu-reveal-enter-to .menu-reveal-bg {
  transform: scale(1);
  border-radius: 0;
  opacity: 1;
}

.menu-reveal-leave-to {
  opacity: 0;
}

.menu-reveal-leave-to .menu-reveal-bg {
  transform: scale(1.5);
  opacity: 0;
}

.menu-reveal-enter-active .mobile-nav-link {
  transition: all 0.6s cubic-bezier(0.16, 1, 0.3, 1);
  transition-delay: calc(0.2s + var(--index) * 0.1s);
}

.menu-reveal-enter-from .mobile-nav-link {
  opacity: 0;
  transform: translateY(40px) skewY(5deg);
}

@media (max-width: 1024px) {
  .nav-links, .locale-switcher {
    display: none;
  }
  
  .mobile-menu-btn {
    display: flex;
  }
}
</style>
