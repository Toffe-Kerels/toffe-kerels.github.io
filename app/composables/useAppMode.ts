export const useAppMode = () => {
  const isAppMode = useState<boolean>('isAppMode', () => false)
  const config = useRuntimeConfig()

  if (import.meta.client) {
    const detected =
      !!config.public.forceAppMode ||
      window.matchMedia('(display-mode: standalone)').matches ||
      window.matchMedia('(display-mode: fullscreen)').matches ||
      (navigator as any).standalone === true ||
      !!(window as any).Capacitor?.isNative

    isAppMode.value = detected

    // Persist so the blocking <head> script can suppress the hero on the very next load
    // without waiting for JS to run (prevents flash-of-content on reload).
    try {
      localStorage.setItem('appMode', String(detected))
      if (detected) document.documentElement.classList.add('app-mode')
      else document.documentElement.classList.remove('app-mode')
    } catch (_) {}
  }

  return { isAppMode }
}
