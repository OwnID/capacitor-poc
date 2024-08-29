<template>
  <ion-page>
    <OwnIdInit :config="{ appId: 'xotvc7yff9clvn', env: 'dev' }"/>

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
        <OwnId :config="{ providers, flow }"></OwnId>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { IonContent, IonHeader, IonPage, IonTitle, IonToolbar, IonButton } from '@ionic/vue';
import OwnId from '../ownid/OwnId.vue';
import OwnIdInit from '../ownid/OwnIdInit.vue';

import auth from "@/services/auth.service";
import { useRouter } from "vue-router";
import { ref } from "vue";

const router = useRouter();
let showOwnid = ref(false)

const toggleOwnid = () => {
  showOwnid.value = !showOwnid.value;
}

const providers = {
  session: {
    create: async (data: any) => {
      try {
        await auth.onLogin(data);

        return { status: 'logged-in' };
      } catch (error) {
        console.error(error);
        return { status: 'fail', reason: 'Failed to create session' };
      }
    },
  },
  account: {
    register: async (account: any) => {
      const regData = {
        email: account.loginId,
        password: window.ownid('generateOwnIDPassword', 12),
        name: account.profile.firstName,
        ownIdData: account.ownIdData,
      };
      try {
        await auth.register(regData);

        return { status: 'logged-in' };
      } catch (error) {
        return { status: 'fail', reason: error };
      }
    },
  },
};
const flow = {
  events: {
    onFinish: () => {
      showOwnid.value = false;
      router.push('/account');
    },
  },
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
