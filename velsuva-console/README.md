# Vel’Suva Control Panel (Vite + React + Tailwind)

## Quick Start (Codespaces or local)
1) Paste your **canvas ControlPanelApp** into `src/ControlPanelApp.tsx`.
2) Install & run:
   ```bash
   npm install
   npm run dev
   ```

### Build & preview
```bash
npm run pages:build
npm run preview
```

## Deploy (GitHub Pages + Actions)

- Push to the `main` branch — the `gh-pages.yml` Action builds with:
  ```bash
  cross-env VITE_BASE=/$npm_package_name/ vite build
  ```
  and deploys `dist/` to Pages automatically.

- Live URL: `https://<user>.github.io/<repo>/`

If your repo name differs from `package.json` `"name"`, adjust `pages:build` in `package.json` or set `VITE_BASE="/<repo>/"`.

---

## Notes

- No local install needed if using **GitHub Codespaces**.
- You can still use your console’s **Single-File Export** for quick shares.
- This project is best for ongoing growth: more panels, charts, presets, etc.
