<script setup lang="ts">
import { onMounted, ref, } from 'vue';

const props = defineProps(['provider']);
const container = ref(null);

onMounted(() => {
  window.ownid('start', {
    ...props.provider,
    container: container.value,
  });
});
</script>

<template>
  <div ref="container"></div>
</template>
