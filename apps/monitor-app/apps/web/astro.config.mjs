import node from '@astrojs/node';
import { defineConfig } from 'astro/config';
import { loadConfigEnv } from './scripts/load-env.mjs';

const fileEnv = loadConfigEnv();
const env = { ...process.env, ...fileEnv };
const publicDefines = Object.fromEntries(
  Object.entries(env)
    .filter(([key]) => key.startsWith('PUBLIC_'))
    .map(([key, value]) => [`import.meta.env.${key}`, JSON.stringify(value)]),
);

export default defineConfig({
  output: 'server',
  adapter: node({ mode: 'standalone' }),
  server: {
    host: env.APP_HOST || '127.0.0.1',
    port: Number(env.APP_PORT || 4005),
  },
  vite: {
    define: publicDefines,
    envPrefix: 'PUBLIC_',
    server: {
      proxy: {
        '/api': {
          target: 'http://127.0.0.1:8005',
          changeOrigin: true,
          rewrite: (requestPath) => requestPath.replace(/^\/api/, ''),
        },
      },
    },
  },
});
