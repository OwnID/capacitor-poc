<script setup lang="ts">
import { onMounted, ref, } from 'vue';

const props = defineProps(['config']);
const container = ref(null);

onMounted(() => {
  window.ownid('start', {
    ...props.config,
    container: container.value,
  });
});
</script>

<template>
  <div ref="container"></div>
</template>
