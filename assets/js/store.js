import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

// root state object.
// each Vuex instance is just a single state tree.
/* eslint no-shadow: ["error", { "allow": ["state"] }] */
const state = {
  users: [],
  messages: [],
  roomId: '',
}

// mutations are operations that actually mutates the state.
// each mutation handler gets the entire state tree as the
// first argument, followed by additional payload arguments.
// mutations must be synchronous and can be recorded by plugins
// for debugging purposes.
const mutations = {
  addUsers(state, { users }) {
    state.users = users
  },
  addMessage(state, payload) {
    if (payload === null) {
      state.messages = []
    } else {
      payload.receivedAt = new Date().toLocaleTimeString()
      state.messages.push(payload)
    }
  },
  addRoomId(state, roomId) {
    state.roomId = roomId
  },
}

// actions are functions that causes side effects and can involve
// asynchronous operations.
const actions = {}

// getters are functions
const getters = {}

// A Vuex instance is created by combining the state, mutations, actions,
// and getters.
export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations,
})
