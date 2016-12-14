// // Brunch automatically concatenates all files in your
// // watched paths. Those paths can be configured at
// // config.paths.watched in "brunch-config.js".
// //
// // However, those files will only be executed if
// // explicitly imported. The only exception are files
// // in vendor, which are never wrapped in imports and
// // therefore are always executed.

// // Import dependencies
// //
// // If you no longer want to use a dependency, remember
// // to also remove its path from "config.paths.watched".

// import $ from "jquery";
// import moment from "moment";
// import "moment/locale/zh-cn";

// // Import local files
// //
// // Local files can be imported directly using relative
// // paths "./socket" or full ones "web/static/js/socket".

// // import socket from "./socket"
import "phoenix_html";
import $ from "jquery";
import moment from "moment";
import "moment/locale/zh-cn";
import "./simditor";
import "./post/show";

(function() {
  function phoenix_moment_render(elem) {
    const from_now = moment($(elem).data('timestamp'), $(elem).data('format')).fromNow();
    $(elem).text(from_now);
    $(elem).removeClass('phoenix-moment').show();
  }

  function phoenix_moment_render_all() {
    $('.phoenix-moment').each(function() {
      phoenix_moment_render(this);
      if ($(this).data('refresh')) {
        (function(elem, interval) {
          setInterval(function() {
            phoenix_moment_render(elem)
          }, interval);
        })(this, $(this).data('refresh'));
      }
    })
  }

  $(document).ready(function() {
      phoenix_moment_render_all();
  });
})();

$(function() {
  // 消息框
  (function() {
    const $notification = $('.notification');

    if ($notification.length) {
      setTimeout(function() {
        $notification.fadeOut();
      }, 2000);

      $notification.find('.delete').on('click', function() {
        $notification.fadeOut();
      });
    };
  })();

  // Fix 重复提交
  (function() {
    $('button[type=submit]').on('click', function() {
      if ($(this).data('is-submited')) {
        return false;
      }
      $(this).data('is-submited', true);
    });
  })();
})
