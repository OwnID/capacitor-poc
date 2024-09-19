<template>
  <ion-page>
    <ion-header :translucent="true">
      <ion-toolbar>
        <ion-title>OwnID Capacitor POC</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content :fullscreen="true">
      <ion-header collapse="condense">
        <ion-toolbar>
          <ion-title size="large">OwnID Capacitor POC</ion-title>
        </ion-toolbar>
      </ion-header>

      <ion-card>
        <ion-card-header>
          <ion-card-title>{{ profile.name }}</ion-card-title>
          <ion-card-subtitle>Welcome</ion-card-subtitle>
        </ion-card-header>

        <ion-card-content>
          {{ profile.email }}

        </ion-card-content>

        <ion-button fill="clear" @click.prevent="onLogout()">Log out</ion-button>
      </ion-card>
    </ion-content>
  </ion-page>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import auth from "@/services/auth.service";
import { useRouter } from "vue-router";
import {
  IonButton,
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardSubtitle,
  IonCardTitle,
  IonContent,
  IonHeader,
  IonPage,
  IonTitle,
  IonToolbar
} from "@ionic/vue";

export default defineComponent({
  components: { IonButton, IonContent, IonHeader, IonPage, IonTitle, IonToolbar, IonCard, IonCardContent, IonCardHeader, IonCardSubtitle, IonCardTitle },
  data() {
    return {
      profile: {
        name: '',
        email: '',
      },
    };
  },
  created() {
    this.fetchData();
  },
  setup() {
    const router = useRouter();
    return { router };
  },
  methods: {
    async fetchData() {
      this.profile = await auth.getProfile();
    },
    async onLogout() {
      await auth.logout();

      await this.$router.push('/home')
    }
  }
});
</script>

<style scoped>
</style>
