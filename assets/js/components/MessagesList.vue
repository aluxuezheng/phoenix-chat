<template>
  <div id="messages-list">
    <ul>
      <!-- <transition-group name="message-appear"> -->
      <li v-for="item in messages">
        <div class="username">{{ item.name }}:</div>
        <div class="message">{{ item.message }}</div>
      </li>
      <!-- </transition-group> -->
    </ul>
  </div>
</template>

<script>
export default {
  computed: {
    messages() {
      return this.$store.state.messages
    },
  },
}
</script>
<style lang="scss" scoped>
#messages-list {
  ul {
    list-style: none;
    text-align: left;
  }
  li {
    margin-bottom: 5px;
    .username {
      font-weight: bold;
      font-size: 18px;
      margin-right: 10px;
      margin-bottom: 5px;
    }
  }
}
</style>
