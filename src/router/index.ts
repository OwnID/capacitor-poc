import { createRouter, createWebHistory } from '@ionic/vue-router';
import { RouteRecordRaw } from 'vue-router';
import HomePage from '@/views/HomePage.vue'
import AccountPage from '@/views/AccountPage.vue';
import auth from '@/services/auth.service';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    redirect: '/home'
  },
  {
    path: '/home',
    name: 'Home',
    component: HomePage,
    beforeEnter: () => auth.isLoggedIn() ? '/account' : true,
  },
  {
    path: '/account',
    name: 'Account',
    component: AccountPage,
    beforeEnter: () => auth.isLoggedIn() ? true : '/sign-in',
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
