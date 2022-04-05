import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login'
import PmidQuery from '../views/PmidQuery'
import { SESSION_STORAGE_KEY_TOKEN } from '../assets/js/constants'

const routes = [
  {
    path: '/',
    alias: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/citation',
    name: 'PmidQuery',
    component: PmidQuery
  },
  //{
  //  path: '/about',
  //  name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
  // component: function () {
     // return import(/* webpackChunkName: "about" */ '../views/About.vue')
    //}
  //}
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  const token = sessionStorage.getItem(SESSION_STORAGE_KEY_TOKEN)
  if (!token) {
    if (to.path !== '/') {
      next('/')
    } else {
      next()
    }
  }
  next()
})

export default router
