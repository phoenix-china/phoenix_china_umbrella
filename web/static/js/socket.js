import {Socket} from "phoenix"

var $ = require("jquery");

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

// export default Room

$.fn.scrollUnique = function() {
    return $(this).each(function() {
        var eventType = 'mousewheel';
        if (document.mozHidden !== undefined) {
            eventType = 'DOMMouseScroll';
        }
        $(this).on(eventType, function(event) {
            // 一些数据
            var scrollTop = this.scrollTop,
                scrollHeight = this.scrollHeight,
                height = this.clientHeight;

            var delta = (event.originalEvent.wheelDelta) ? event.originalEvent.wheelDelta : -(event.originalEvent.detail || 0);

            if ((delta > 0 && scrollTop <= delta) || (delta < 0 && scrollHeight - height - scrollTop <= -1 * delta)) {
                // IE浏览器下滚动会跨越边界直接影响父级滚动，因此，临界时候手动边界滚动定位
                this.scrollTop = delta > 0? 0: scrollHeight;
                // 向上滚 || 向下滚
                event.preventDefault();
            }
        });
    });
};

class Notification {
  static init() {
    var that = this;
    var $user_meta = $("meta[name=user-id]");

    if ($user_meta.length == 0) {
      return false;
    }

    let socket = new Socket("/socket", {})

    socket.connect()

    var channel = socket.channel("notifications:" + $user_meta.attr("content"), {guardian_token: $('meta[name="guardian_token"]').attr('content')})

    channel.join()
      .receive("ok", resp => { console.log("Notification Joined successfully", resp) })
      .receive("error", resp => { console.log("Notification Unable to join", resp) })

    channel.on(":msg", msg => {
      $("#notification ul").prepend(`<li>${msg.body}</li>`);
      this.showCount(1);
    })

    this.loadData($("#notification ul"));

    $(".notification-wraper").scrollUnique();

    $(".notification-wraper").on("scroll", function() {
      var $child = $(this).find("ul");

      if ($child.height() - $(this).scrollTop() == $(this).height()) {
        that.loadData($("#notification ul"));
      }
    });

    this.showCount();

    $("#notification").on("click", function() {
        that.hideCount();
    });
  }

  static hideCount() {
    $.ajax({
      headers: {
        "X-CSRF-TOKEN": $("meta[name=csrf]").attr("content")
      },
      type: "put",
      url: "/notifications/readall",
      success: function() {
        var $count = $("#notifications-count");
        var count = 0;
        $count.data("count", count);
        $count.html(count);
        $count.hide();
      }
    })
  }

  static showCount(inc) {
    var inc = inc || 0;
    var $count = $("#notifications-count");
    var count = parseInt($count.data("count")) + inc;
    $count.data("count", count);
    $count.html(count);
    if (count > 0) {
      $count.show();
    }
  }

  static loadData(wraper) {
    var pagination = wraper.data('pagination') || {has_next: true, page_number: 0};

    if (pagination.has_next) {
      $.ajax({
        url: "/notifications/default?page=" + (pagination.page_number + 1),
        success: function(res) {
          var html = [];

          if (res.data.length > 0) {
            $.each(res.data, function(_, entry) {
              html.push(`<li>${entry.html}</li>`);
            });
          }
          else {
            html.push('<li>还没有任何通知</li>');
          }

          wraper.data('pagination', res.pagination);
          wraper.append(html.join(''));
        }
      })
    }
  }
}

$(() => Notification.init())
