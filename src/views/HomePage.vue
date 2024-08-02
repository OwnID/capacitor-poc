<template>
  <ion-page>
    <OwnidInit :config="{ appId: 'xotvc7yff9clvn', env: 'dev' }"/>

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

      <div class="container" v-if="!showOwnid">
        <h1>OwnID Demo</h1>
        <strong>OwnID enables your users to create a digital identity on their phone to instantly login to your websites or apps.</strong>
        <p>Passwords are finally gone</p>
        <ion-button @click.prevent="toggleOwnid()">Sign In</ion-button>
      </div>

      <div class="ownid-container" v-if="showOwnid">
        <OwnidElite :provider="ownidProvider"></OwnidElite>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { IonContent, IonHeader, IonPage, IonTitle, IonToolbar, IonButton } from '@ionic/vue';
import { OwnidElite, OwnidInit } from '@ownid/vue';

import auth from "@/services/auth.service";
import { useRouter } from "vue-router";
import { ref } from "vue";

const router = useRouter();
let showOwnid = ref(false)

const toggleOwnid = () => {
  showOwnid.value = !showOwnid.value;
}

const ownidProvider = {
  language: 'en',
  onNewAccount: async (props: any, done: () => void) => {
    await auth.register({
      email: props.loginId,
      password: window.ownid('generateOwnIDPassword', 12),
      name: props.profile.firstName,
      data: props.ownIdData,
    });
  },
  onAuthenticated: async (data: any) => {
    await auth.onLogin(data);
  },
  onLogin: () => {
    showOwnid.value = false;
    router.push('/account');
  }
};
</script>

<style scoped>
.container {
  text-align: center;

  position: absolute;
  left: 0;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
}

.ownid-container {
  padding: 0 20px;
}
</style>
