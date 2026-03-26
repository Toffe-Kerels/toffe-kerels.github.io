import { defineNuxtConfig } from 'nuxt/config'
import fs from 'node:fs'
import path from 'node:path'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2026-03-24',
  compatibilityVersion: 4,
  ssr: true,

  devtools: { enabled: true },

  app: {
    head: {
      htmlAttrs: {
        lang: 'nl'
      },
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ]
    }
  },

  css: ['~/assets/css/main.css'],

  modules: [
    '@nuxt/content',
    '@nuxtjs/i18n',
    '@nuxtjs/seo',
    '@vite-pwa/nuxt'
  ],

  content: {
    // Content v3 configuration
  },

  ogImage: {
    defaults: {
      renderer: 'satori'
    }
  },

  i18n: {
    locales: [
      { code: 'nl', file: 'nl.json', name: 'Nederlands' },
      { code: 'en', file: 'en.json', name: 'English' }
    ],
    lazy: true,
    defaultLocale: 'nl',
    strategy: 'prefix_except_default',
    detectBrowserLanguage: false
  },

  site: {
    url: 'https://toffekerels.nl',
    name: 'Toffe Kerels',
    description: 'Showcase voor de tofste bedrijven. Moderne websites voor lokale ondernemers.',
    defaultLocale: 'nl'
  },

  seo: {
    fallbackTitle: false
  },

  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'Toffe Kerels',
      short_name: 'ToffeKerels',
      theme_color: '#4f46e5',
      icons: [
        {
          src: 'favicon.svg',
          sizes: '512x512',
          type: 'image/svg+xml'
        }
      ]
    },
    workbox: {
      navigateFallback: null,
      globPatterns: ['**/*.{js,css,html,png,svg,ico,webp,woff,woff2}'],
      maximumFileSizeToCacheInBytes: 4000000
    }
  },

  nitro: {
    prerender: {
      crawlLinks: true,
      routes: ['/'],
      autoSubfolderIndex: true
    }
  },

  routeRules: {
    '/': { prerender: true },
    '/_nuxt/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
    '/images/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } },
    '/fonts/**': { headers: { 'cache-control': 'public, max-age=31536000, immutable' } }
  },

  experimental: {
    inlineStyles: true
  },

  hooks: {
    'build:before': () => {
      const mediaDir = path.resolve(process.cwd(), 'public/images/media')
      if (fs.existsSync(mediaDir)) {
        const files = fs.readdirSync(mediaDir)
        const mediaList = files
          .filter(file => /\.(jpg|jpeg|png|webp|mp4|webm)$/i.test(file))
          .map(file => {
            const name = path.parse(file).name
            return {
              url: `/images/media/${file}`,
              alt: name.replace(/[_-]/g, ' '),
              type: /\.(mp4|webm)$/i.test(file) ? 'video' : 'image'
            }
          })
        fs.writeFileSync(
          path.resolve(process.cwd(), 'public/media-list.json'),
          JSON.stringify(mediaList, null, 2)
        )
      }
    }
  }
})
