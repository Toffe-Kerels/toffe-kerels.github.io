<script setup lang="ts">
const { locale } = useI18n()
const t = (nl: string, en: string) => locale.value === 'en' ? en : nl

const props = defineProps<{
  name?: string
  tagline?: string
  phone?: string
  email?: string
  website?: string
  address?: string
  whatsapp?: boolean
  kvk?: string
  instagram?: string
  linkedin?: string
  facebook?: string
  x?: string
  tiktok?: string
  youtube?: string
}>()

const page = useState<any>('currentPage')

const name = computed(() => props.name ?? page.value?.title)
const tagline = computed(() => props.tagline ?? page.value?.description)
const phone = computed(() => props.phone ?? page.value?.contact?.phone)
const email = computed(() => props.email ?? page.value?.contact?.email)
const website = computed(() => props.website ?? page.value?.contact?.website)
const address = computed(() => props.address ?? page.value?.contact?.address)
const whatsapp = computed(() => props.whatsapp ?? page.value?.contact?.whatsapp)
const kvk = computed(() => props.kvk ?? page.value?.contact?.kvk)
const instagram = computed(() => props.instagram ?? page.value?.contact?.socials?.instagram)
const linkedin = computed(() => props.linkedin ?? page.value?.contact?.socials?.linkedin)
const facebook = computed(() => props.facebook ?? page.value?.contact?.socials?.facebook)
const x = computed(() => props.x ?? page.value?.contact?.socials?.x)
const tiktok = computed(() => props.tiktok ?? page.value?.contact?.socials?.tiktok)
const youtube = computed(() => props.youtube ?? page.value?.contact?.socials?.youtube)

const whatsappHref = (phone: string) => {
  const digits = phone.replace(/\D/g, '')
  const intl = digits.startsWith('0') ? '31' + digits.slice(1) : digits
  return `https://wa.me/${intl}`
}
</script>

<template>
  <section class="bc-section">
    <div class="container">
      <div class="bc-card">

        <!-- Left: identity -->
        <div class="bc-identity">
          <div class="bc-logo-wrap">
            <slot name="logo">
              <div class="bc-logo-placeholder">
                {{ (name ?? '?').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase() }}
              </div>
            </slot>
          </div>
          <div class="bc-name-block">
            <h2 class="bc-name">{{ name }}</h2>
            <p v-if="tagline" class="bc-tagline">{{ tagline }}</p>
          </div>
        </div>

        <!-- Divider -->
        <div class="bc-divider" />

        <!-- Right: contact details -->
        <div class="bc-details">
          <a v-if="phone" :href="`tel:${phone}`" class="bc-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 9.91a16 16 0 0 0 6.16 6.16l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            <span>{{ phone }}</span>
          </a>

          <a v-if="whatsapp && phone" :href="whatsappHref(phone)" target="_blank" rel="noopener" class="bc-row bc-row--whatsapp">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413z"/></svg>
            <span>WhatsApp</span>
          </a>

          <a v-if="email" :href="`mailto:${email}`" class="bc-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
            <span>{{ email }}</span>
          </a>

          <a v-if="website" :href="website" target="_blank" rel="noopener" class="bc-row">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
            <span>{{ website.replace(/^https?:\/\//, '') }}</span>
          </a>

          <div v-if="address" class="bc-row bc-row--static">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/></svg>
            <span>{{ address }}</span>
          </div>

          <div v-if="kvk" class="bc-row bc-row--static">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/></svg>
            <span>KvK: {{ kvk }}</span>
          </div>
        </div>

        <!-- Socials -->
        <div v-if="instagram || linkedin || facebook || x || tiktok || youtube" class="bc-socials">
          <a v-if="instagram" :href="instagram" target="_blank" rel="noopener" class="bc-social" :aria-label="t('Instagram', 'Instagram')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
          </a>
          <a v-if="linkedin" :href="linkedin" target="_blank" rel="noopener" class="bc-social" :aria-label="t('LinkedIn', 'LinkedIn')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"/><rect x="2" y="9" width="4" height="12"/><circle cx="4" cy="4" r="2"/></svg>
          </a>
          <a v-if="facebook" :href="facebook" target="_blank" rel="noopener" class="bc-social" :aria-label="t('Facebook', 'Facebook')">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
          </a>
          <a v-if="x" :href="x" target="_blank" rel="noopener" class="bc-social" :aria-label="t('X (Twitter)', 'X (Twitter)')">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.737-8.835L1.254 2.25H8.08l4.253 5.622zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
          </a>
          <a v-if="tiktok" :href="tiktok" target="_blank" rel="noopener" class="bc-social" :aria-label="t('TikTok', 'TikTok')">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M19.59 6.69a4.83 4.83 0 0 1-3.77-4.25V2h-3.45v13.67a2.89 2.89 0 0 1-2.88 2.5 2.89 2.89 0 0 1-2.89-2.89 2.89 2.89 0 0 1 2.89-2.89c.28 0 .54.04.79.1V9.01a6.33 6.33 0 0 0-.79-.05 6.34 6.34 0 0 0-6.34 6.34 6.34 6.34 0 0 0 6.34 6.34 6.34 6.34 0 0 0 6.33-6.34V8.69a8.18 8.18 0 0 0 4.78 1.52V6.75a4.85 4.85 0 0 1-1.01-.06z"/></svg>
          </a>
          <a v-if="youtube" :href="youtube" target="_blank" rel="noopener" class="bc-social" :aria-label="t('YouTube', 'YouTube')">
            <svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
          </a>
        </div>

      </div>
    </div>
  </section>
</template>

<style scoped>
.bc-section {
  padding: var(--section-padding, 8rem) 0;
}

.bc-card {
  display: grid;
  grid-template-columns: auto 1px 1fr auto;
  align-items: center;
  gap: 4rem;
  background: rgba(255, 255, 255, 0.06);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 2rem;
  padding: 3.5rem 4rem;
  border: 1px solid rgba(255, 255, 255, 0.12);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

/* Identity */
.bc-identity {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.bc-logo-wrap {
  flex-shrink: 0;
}

.bc-logo-placeholder {
  width: 7rem;
  height: 7rem;
  border-radius: 1.6rem;
  background: linear-gradient(135deg, var(--primary, #4f46e5), var(--gradient-1, #ec4899));
  color: #fff;
  font-size: 2.4rem;
  font-weight: 900;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: 0.05em;
}

.bc-name {
  font-size: clamp(1.8rem, 2.5vw, 2.6rem);
  font-weight: 900;
  color: #fff;
  margin: 0 0 0.4rem;
  line-height: 1.1;
}

.bc-tagline {
  font-size: 1.4rem;
  color: rgba(255, 255, 255, 0.6);
  margin: 0;
  font-style: italic;
}

/* Divider */
.bc-divider {
  width: 1px;
  height: 8rem;
  background: rgba(255, 255, 255, 0.12);
  align-self: center;
}

/* Details */
.bc-details {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.bc-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 1.5rem;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  transition: color 0.2s;
}

.bc-row:not(.bc-row--static):hover {
  color: #fff;
}

.bc-row svg {
  width: 1.6rem;
  height: 1.6rem;
  flex-shrink: 0;
  opacity: 0.7;
}

.bc-row--whatsapp {
  color: #4ade80;
}

.bc-row--whatsapp svg {
  opacity: 1;
}

.bc-row--static {
  cursor: default;
  color: rgba(255, 255, 255, 0.5);
}

/* Socials */
.bc-socials {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  align-items: center;
}

.bc-social {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3.8rem;
  height: 3.8rem;
  border-radius: 1rem;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.7);
  transition: background 0.2s, color 0.2s;
  text-decoration: none;
}

.bc-social:hover {
  background: var(--primary, #4f46e5);
  color: #fff;
}

.bc-social svg {
  width: 1.8rem;
  height: 1.8rem;
}

/* Responsive */
@media (max-width: 1024px) {
  .bc-card {
    grid-template-columns: 1fr;
    gap: 2.4rem;
    padding: 3rem;
  }

  .bc-divider {
    width: 100%;
    height: 1px;
  }

  .bc-socials {
    flex-direction: row;
    justify-content: flex-start;
  }
}

@media (max-width: 640px) {
  .bc-card {
    padding: 2.4rem;
    border-radius: 1.6rem;
  }

  .bc-identity {
    gap: 1.6rem;
  }
}
</style>
