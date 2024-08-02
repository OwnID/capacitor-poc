import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.ownid.demo.custom',
  appName: 'CapPoC',
  webDir: 'dist',
  server: {
    hostname: 'dev.ownid.com'
  }
};

export default config;
