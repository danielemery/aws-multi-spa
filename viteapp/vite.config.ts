import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const basePath = process.env?.BASE_PATH ?? "/local";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: basePath,
  build: {
    outDir: `dist${basePath}`,
  },
});
