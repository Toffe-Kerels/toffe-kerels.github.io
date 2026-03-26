<script setup lang="ts">
import { useI18n } from 'vue-i18n'
const { t } = useI18n()
const localePath = useLocalePath()
</script>

<template>
  <footer class="app-footer">
    <div class="container footer-grid">
      <div class="footer-col">
        <h3 class="logo-brand is-light has-orange">TOFFE<span>KERELS</span></h3>
        <p>{{ t('footer.description') }}</p>
      </div>
      
      <div class="footer-col">
        <h4>{{ t('footer.navigation') }}</h4>
        <ul>
          <li><NuxtLink :to="localePath('/')">{{ t('nav.home') }}</NuxtLink></li>
          <li><NuxtLink :to="localePath('/showcase')">{{ t('nav.showcase') }}</NuxtLink></li>
          <li><NuxtLink :to="localePath('/contact')">{{ t('nav.contact') }}</NuxtLink></li>
          <li><NuxtLink :to="localePath('/meedoen')">{{ t('nav.join') }}</NuxtLink></li>
        </ul>
      </div>
      
      <div class="footer-col">
        <h4>{{ t('footer.contact') }}</h4>
        <p>{{ t('footer.email') }}</p>
        <p>{{ t('footer.phone') }}</p>
        <p>{{ t('footer.address') }}</p>
        <p>{{ t('footer.location') }}</p>
      </div>
    </div>
    <div class="container footer-bottom">
      <p>&copy; {{ new Date().getFullYear() }} Toffe Kerels. All rights reserved.</p>
    </div>
  </footer>
</template>

<style scoped>
.app-footer {
  background-color: var(--footer-bg);
  color: var(--white);
  padding: 8rem 0 4rem;
}

.footer-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 8rem;
  margin-bottom: 6rem;
}

.footer-col h3 {
  margin-bottom: 2rem;
}

.footer-col h4 {
  font-size: 1.8rem;
  margin-bottom: 2rem;
  color: var(--accent);
}

.footer-col p {
  color: #ccc;
  font-size: 1.4rem;
}

.footer-col ul {
  list-style: none;
}

.footer-col ul li {
  margin-bottom: 1rem;
}

.footer-col ul a {
  color: #ccc;
  font-size: 1.4rem;
}

.footer-bottom {
  padding-top: 4rem;
  border-top: 1px solid #444;
  text-align: center;
  color: #888;
  font-size: 1.2rem;
}

@media (max-width: 768px) {
  .footer-grid {
    grid-template-columns: 1fr;
    gap: 4rem;
  }
}
</style>
