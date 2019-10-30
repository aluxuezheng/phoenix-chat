import 'phoenix_html'
import Vue from 'vue'
import App from './App.vue'
import store from './store'
import axios from 'axios'
import '../css/app.css'

Vue.prototype.$ajax = axios
/* eslint-disable no-new */
new Vue({
  store,
  el: '#app',
  render: h => h(App),
})
