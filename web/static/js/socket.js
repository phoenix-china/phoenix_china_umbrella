import {Socket} from "phoenix"


class Room {
  static init(){
    let socket = new Socket("/socket", {})

    socket.connect()
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")
    var channel = socket.channel("rooms:lobby", {"user": $username.val()})

    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    $input.on("keypress", event => {
      if(event.keyCode === 13){
        if (!$input.val()) {
          alert("请输入一些内容吧")
          return false
        }

        channel.push("new_msg", {username: $username.val(), body: $input.val()});
        $input.val("");
      }
    })

    channel.on("new_msg", msg => {
      $messages.append(this.messageTemplate(msg))
      $('body').animate({scrollTop: $('body').height()}, 100);
    })

    channel.on("user:entered", msg => {
      var username = this.sanitize(msg.user || "匿名用户")
      $messages.append(`<p><i>[${Date()} ${username}]: 进入聊天室</i></p>`)
    })
  }

  static sanitize(html){ return $("<div/>").text(html).html() }

  static messageTemplate(msg){
    let username = this.sanitize(msg.username || "匿名用户")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='javascript:void(0);'>[${Date()} ${username}]</a>&nbsp; ${body}</p>`)
  }
}

if ($('.room').length > 0) {
  $(() => Room.init())
}

export default Room
