<script setup lang="ts">
const props = defineProps(['config']);
const config = { ...props.config };

addSdkScript(config);

window.ownid('init', config);

function addSdkScript(config: any) {
  // @ts-ignore
  if (window.ownid) {
    return;
  }

  window.ownid = function () {
    (window.ownid.q = window.ownid.q || []).push(arguments);
    return Promise.resolve({ error: null, data: null });
  }

  const env = config.env && config.env !== 'prod' ? `${config.env}.` : '';
  const script = document.createElement('script');

  script.src = `https://cdn.${env}ownid.com/sdk/${config.appId}`
  script.async = true;
  document.head.appendChild(script);
}
</script>

<template>{{}}</template>
