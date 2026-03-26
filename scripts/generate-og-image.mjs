import sharp from 'sharp'

const svg = `<svg xmlns='http://www.w3.org/2000/svg' width='1200' height='630'>
  <rect width='1200' height='630' fill='#0f172a'/>
  <text x='600' y='260' font-family='Arial, sans-serif' font-size='80' font-weight='bold' fill='white' text-anchor='middle'>Toffe Kerels</text>
  <text x='600' y='360' font-family='Arial, sans-serif' font-size='36' fill='#f59e0b' text-anchor='middle'>Showcase voor de tofste bedrijven</text>
  <text x='600' y='430' font-family='Arial, sans-serif' font-size='28' fill='#94a3b8' text-anchor='middle'>toffekerels.nl</text>
</svg>`

await sharp(Buffer.from(svg)).png().toFile('public/og-image.png')
console.log('Generated public/og-image.png')
