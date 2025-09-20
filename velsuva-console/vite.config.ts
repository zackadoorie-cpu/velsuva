import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// DEV (local/Codespaces): base="/" via default
// PAGES build: sets VITE_BASE to "/<repo>/" via npm script
const base = process.env.VITE_BASE ?? "/"

export default defineConfig({
  plugins: [react()],
  base,
})
