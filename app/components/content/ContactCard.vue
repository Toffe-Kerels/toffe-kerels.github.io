<script setup lang="ts">
const { locale } = useI18n()
const t = (nl: string, en: string) => locale.value === 'en' ? en : nl

const props = defineProps<{
  item: any
  whatsappHref: (phone: string) => string
}>()
</script>

<template>
  <div class="biz-card">

    <!-- Header: logo/image + name + tags -->
    <div class="biz-header">
      <div class="biz-avatar">
        <img v-if="item.image" :src="item.image" :alt="item.title" loading="lazy">
        <div v-else class="biz-avatar-placeholder">
          {{ item.title.split(' ').map((n: string) => n[0]).join('').slice(0, 2).toUpperCase() }}
        </div>
      </div>
      <div class="biz-title-block">
        <h3 class="biz-name">{{ item.title }}</h3>
        <div class="biz-tags">
          <span v-for="tag in item.tags?.slice(0, 3)" :key="tag" class="biz-tag">#{{ tag }}</span>
        </div>
      </div>
    </div>

    <!-- Description -->
    <p class="biz-desc">{{ item.description }}</p>

    <!-- Contact rows -->
    <div v-if="item.contact?.phone || item.contact?.email || item.contact?.address || item.contact?.website" class="biz-contact">

      <!-- Phone -->
      <a v-if="item.contact?.phone" :href="`tel:${item.contact.phone}`" class="biz-row">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 9.91a16 16 0 0 0 6.16 6.16l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        <span>{{ item.contact.phone }}</span>
      </a>

      <!-- WhatsApp (only when whatsapp: true) -->
      <a v-if="item.contact?.whatsapp === true && item.contact?.phone" :href="whatsappHref(item.contact.phone)" target="_blank" rel="noopener" class="biz-row biz-row--whatsapp">
        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413z"/></svg>
        <span>WhatsApp</span>
      </a>

      <!-- Email -->
      <a v-if="item.contact?.email" :href="`mailto:${item.contact.email}`" class="biz-row">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>
        <span>{{ item.contact.email }}</span>
      </a>

      <!-- Address -->
      <div v-if="item.contact?.address" class="biz-row biz-row--static">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"/><circle cx="12" cy="10" r="3"/></svg>
        <span>{{ item.contact.address }}</span>
      </div>

      <!-- Website -->
      <a v-if="item.contact?.website" :href="item.contact.website" target="_blank" rel="noopener" class="biz-row">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
        <span>{{ item.contact.website.replace(/^https?:\/\//, '') }}</span>
      </a>

    </div>

    <!-- Socials + TK profile link -->
    <div class="biz-footer">
      <div class="biz-socials">

        <!-- Instagram -->
        <a v-if="item.contact?.socials?.instagram" :href="item.contact.socials.instagram" target="_blank" rel="noopener" class="biz-social" :aria-label="t('Instagram', 'Instagram')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
        </a>

        <!-- LinkedIn -->
        <a v-if="item.contact?.socials?.linkedin" :href="item.contact.socials.linkedin" target="_blank" rel="noopener" class="biz-social" :aria-label="t('LinkedIn', 'LinkedIn')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z"/><rect x="2" y="9" width="4" height="12"/><circle cx="4" cy="4" r="2"/></svg>
        </a>

        <!-- Facebook -->
        <a v-if="item.contact?.socials?.facebook" :href="item.contact.socials.facebook" target="_blank" rel="noopener" class="biz-social" :aria-label="t('Facebook', 'Facebook')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
        </a>

        <!-- X / Twitter -->
        <a v-if="item.contact?.socials?.twitter" :href="item.contact.socials.twitter" target="_blank" rel="noopener" class="biz-social" :aria-label="t('X / Twitter', 'X / Twitter')">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L1.254 2.25H8.08l4.253 5.622zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
        </a>

      </div>

      <!-- TK logo → profile link -->
      <NuxtLink :to="item.path" class="biz-profile-link" :aria-label="t('Bekijk profiel', 'View profile')">
        <span class="biz-tk-badge">TK</span>
      </NuxtLink>
    </div>

  </div>
</template>

<style scoped>
.biz-card {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  height: 100%;
}

/* ── Header ── */
.biz-header {
  display: flex;
  align-items: center;
  gap: 1.6rem;
}

.biz-avatar {
  width: 6.4rem;
  height: 6.4rem;
  border-radius: 1.2rem;
  overflow: hidden;
  flex-shrink: 0;
  background: rgba(15, 23, 42, 0.06);
}

.biz-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.biz-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1e3a5f, #2563eb);
  font-size: 2rem;
  font-weight: 900;
  color: #fff;
  letter-spacing: -0.04em;
}

.biz-title-block {
  flex: 1;
  min-width: 0;
}

.biz-name {
  font-size: 1.8rem;
  font-weight: 900;
  color: #0f172a;
  letter-spacing: -0.03em;
  text-transform: uppercase;
  line-height: 1.1;
  margin-bottom: 0.6rem;
}

.biz-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.biz-tag {
  font-size: 1.1rem;
  font-weight: 800;
  color: #2563eb;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

/* ── Description ── */
.biz-desc {
  font-size: 1.4rem;
  color: #64748b;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ── Contact rows ── */
.biz-contact {
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
  border-top: 1.5px solid rgba(15, 23, 42, 0.08);
  border-bottom: 1.5px solid rgba(15, 23, 42, 0.08);
  padding: 1.6rem 0;
  flex: 1;
}

.biz-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 1.4rem;
  font-weight: 600;
  color: #0f172a;
  text-decoration: none;
  transition: color 0.2s;
  line-height: 1.3;
}

a.biz-row:hover {
  color: #2563eb;
}

.biz-row svg {
  width: 1.5rem;
  height: 1.5rem;
  flex-shrink: 0;
  color: #2563eb;
}

.biz-row--static {
  color: #64748b;
  cursor: default;
}

.biz-row--static svg {
  color: #64748b;
}

.biz-row--whatsapp svg {
  color: #25d366;
}

.biz-row--whatsapp:hover {
  color: #25d366 !important;
}

/* ── Footer: socials + TK badge ── */
.biz-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1.2rem;
  margin-top: auto;
}

.biz-socials {
  display: flex;
  gap: 1rem;
}

.biz-social {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3.6rem;
  height: 3.6rem;
  border-radius: 50%;
  border: 1.5px solid rgba(15, 23, 42, 0.1);
  color: #64748b;
  text-decoration: none;
  transition: all 0.2s;
}

.biz-social svg {
  width: 1.6rem;
  height: 1.6rem;
}

.biz-social:hover {
  border-color: #2563eb;
  color: #2563eb;
  background: rgba(37, 99, 235, 0.06);
}

/* ── TK badge profile link ── */
.biz-profile-link {
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  flex-shrink: 0;
  transition: transform 0.2s;
}

.biz-profile-link:hover {
  transform: scale(1.08);
}

.biz-tk-badge {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 4rem;
  height: 4rem;
  border-radius: 50%;
  background: linear-gradient(135deg, #1e3a5f, #2563eb);
  color: #fff;
  font-size: 1.2rem;
  font-weight: 900;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}
</style>
