<template>
  <div id="app">
    <div class="container" v-if="dataReady">
      <h1 class="title">Phoenix Chat</h1>
      <div class="button button-begin" v-if="!connect" @click="beginChat">
        开始聊天
      </div>
      <div class="main" v-else>
        <div class="messages-wrap">
          <p class="system-tip" v-if="!someoneConnect && !someoneLeave">
            连线中...
          </p>
          <p class="system-tip" v-if="someoneConnect && !someoneLeave">
            连接成功，开始聊天咯～
          </p>
          <ul class="messages-list" v-if="messages.length > 0">
            <transition-group name="message-appear">
              <li
                v-for="(item, index) in messages"
                :key="index"
                v-bind:class="{ right: item.messageType === 1 }"
              >
                <div class="time">{{ item.receivedAt }}</div>
                <div class="con">
                  <div class="text">{{ item.body }}</div>
                </div>
              </li>
            </transition-group>
          </ul>
          <div class="messages-header">
            <p v-show="someoneLeave" class="system-tip">
              对方已经离开，请点击离开按钮，重新连接
            </p>
          </div>
        </div>
        <!-- <messages-list /> -->
        <div class="row send-message">
          <div class="column-10 button-send button" @click="closeConnect">
            离开
          </div>
          <div class="column">
            <input
              type="text"
              id="msg"
              class="form-control"
              placeholder="Your Message"
              v-model="message"
              autofocus
              v-on:keyup.13="sendMessage"
            />
          </div>
          <button
            class="column-10 button-send button"
            :disabled="!someoneConnect || someoneLeave"
            @click="sendMessage"
          >
            发送
          </button>
        </div>
      </div>
    </div>
    <div class="loading" v-else>
      加载中。。。。
    </div>
  </div>
</template>

<script>
import { Socket } from 'phoenix'
export default {
  name: 'word',
  props: {
    // msg: String
  },
  components: {},
  data() {
    return {
      socket: null,
      channel: null,
      connect: false,
      message: '',
      name: '',
      enterName: true,
      roomId: '',
      room: null,
      dataReady: false,
      someoneLeave: false,
      someoneConnect: false,
    }
  },
  mounted() {
    this.userToken = window.userToken
    this.connectToChat()
    window.addEventListener('beforeunload', e => this.beforeunloadHandler(e))
  },
  computed: {
    messages() {
      return this.$store.state.messages
    },
  },
  methods: {
    sendMessage() {
      const message = this.message
      if (message.length > 0) {
        this.room.push('new_msg', { body: message })
        this.message = ''
      }
    },
    connectToChat() {
      this.socket = new Socket('/socket', {
        params: { token: this.userToken },
      })
      this.socket.connect()
      this.channel = this.socket.channel('room:lobby', {})

      this.channel.join()
      this.channel.on('rooms:connected', ({ roomId }) => {
        this.roomId = roomId
        this.room = this.socket.channel(`room:${roomId}`, {})
        this.room.join()
        this.someoneLeave = false
        this.$store.commit('addRoomId', this.roomId)
        this.dataReady = true
        this.room.on('new_msg', payload => {
          this.$store.commit('addMessage', payload)
        })
        this.room.on('someone_connect', () => {
          this.someoneConnect = true
        })
        this.room.on('someone_leave', () => {
          this.someoneLeave = true
        })
      })
      this.channel.push('fetch:room')
      // this.channel.leave(); 断开频道
    },
    beginChat() {
      this.connect = true
      if (this.someoneLeave && !this.someoneConnect) {
        this.connectToChat()
      }
    },
    closeConnect() {
      this.room.push('someone_leave')
      this.room.leave()
      this.connect = false
      this.someoneConnect = false
      this.someoneLeave = true
      this.$store.commit('addMessage', null)
    },
    beforeunloadHandler() {
      this.room.push('someone_leave')
      this.room.leave()
      setTimeout(() => {
        this.connect = false
        this.someoneConnect = false
        this.someoneLeave = true
        this.$store.commit('addMessage', null)
      }, 2000)
    },
  },
  updated() {
    this.$nextTick(function() {
      let st = document.documentElement.scrollTop || document.body.scrollTop
      if (st > 0) {
        document.documentElement.scrollTop = document.querySelector(
          'body',
        ).clientHeight
        document.body.scrollTop = document.querySelector('body').clientHeight
      }
    })
  },
  destroyed() {
    window.removeEventListener('beforeunload', e => this.beforeunloadHandler(e))
  },
}
</script>

<style scoped lang="scss">
#app {
  .loading {
    text-align: center;
    font-size: 2rem;
    color: #000;
    padding-top: 10rem;
  }
  .begin-button-wrap {
    width: 100vmin;
    height: 100vh;
    text-align: center;
    display: flex;
    justify-content: center;
    flex-direction: column;
  }
  .title {
    padding-top: 4rem;
    text-align: center;
    margin-bottom: 4rem;
  }
  .button-begin {
    display: block;
    width: 20rem;
    margin: 0 auto;
  }
  .messages-wrap {
    min-height: 10rem;
    border: 1px solid #ddd;
    border-radius: 0.5rem;
    padding: 1rem;
    margin: 0 -1rem 1rem;
    .system-tip {
      text-align: center;
    }
  }
  .messages-list {
    list-style: none;
    li {
      display: flex;
      flex-direction: column;
      &.right {
        align-items: flex-end;
        .con {
          .text {
            background-color: #c6e4ff;
          }
        }
      }
      .time {
        font-size: 85%;
        color: #6f7882;
      }
      .con {
        .text {
          background-color: #e3e7eb;
          color: #000;
          display: inline-block;
          padding: 0.5rem 1rem;
          margin: 0.5rem 0 1rem 0;
          border-radius: 0.5rem;
          word-break: break-word;
        }
      }
      .con-ex {
        background-color: #e4e7ec;
      }
    }
  }
  .button[disabled] {
    background-color: #666;
    border-color: #333;
  }

  .message-appear-enter-active {
    transition: all 0.3s;
  }
  .message-appear-leave-active {
    transition: all 0.3s;
  }
  .message-appear-enter,
  .message-appear-leave-to {
    opacity: 0;
    transform: translateY(10px);
  }
  .send-message {
  }
}
</style>
