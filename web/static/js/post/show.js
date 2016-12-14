import $ from "jquery";
import Vue from "vue/dist/vue.js";
import VueResource from "vue-resource";
import hljs from "highlight.js";

(function() {
  Vue.use(VueResource);
  Vue.http.headers.common["X-CSRF-TOKEN"] = $("meta[name=csrf]").attr("content");


  Vue.component('post-praise', {
    props: ['isPraise', 'praiseCount', 'postId'],
    data: function() {
      return {
        is_praise: this.isPraise,
        praise_count: this.praiseCount
      }
    },
    template: `
      <a class="button is-light is-small" @click="praise">
        <span class="icon is-small" :class="{'is-danger': is_praise}">
          <i class="fa" :class="[is_praise ? 'fa-heart' : 'fa-heart-o']"></i>
        </span>
        <span>{{ count }}</span>
      </a>
    `,
    created: function() {
      this.count = this.praiseCount > 0 ? this.praiseCount + "个赞" : "赞";
      this.http_method = this.isPraise ? "DELETE" : "POST";
      this.http_url = '/posts/'+ this.postId +'/praise';
    },
    watch: {
      praise_count: function(newValue, oldValue) {
        this.count = newValue > 0 ? this.praise_count + "个赞" : "赞";
      },
      is_praise: function(newValue, oldValue) {
        this.http_method = newValue ? "DELETE" : "POST";
      }
    },
    methods: {
      praise: function() {
        var options = {
          method: this.http_method,
          url: this.http_url
        }

        this.$http(options).then((response) => {
          response.json().then((res) => {
            this.is_praise = res.is_praise;
            this.praise_count = res.data.praise_count;
          })
        });
      }
    }
  });


  Vue.component('post-collect', {
    props: ['isCollect', 'postId'],
    data: function() {
      return {
        is_collect: this.isCollect
      }
    },
    template: `
      <a class="button is-light is-small" @click="collect">
        <span class="icon is-small" :class="{'is-danger': is_collect}">
          <i class="fa" :class="[is_collect ? 'fa-bookmark' : 'fa-bookmark-o']"></i>
        </span>
        <span>收藏</span>
      </a>
    `,
    created: function() {
      this.http_method = this.isCollect ? "DELETE" : "POST";
      this.http_url = '/posts/'+ this.postId +'/collect';
    },
    watch: {
      is_collect: function(newValue, oldValue) {
        this.http_method = newValue ? "DELETE" : "POST";
      }
    },
    methods: {
      collect: function() {
        var options = {
          method: this.http_method,
          url: this.http_url
        }

        this.$http(options).then((response) => {
          response.json().then((res) => {
            this.is_collect = res.is_collect;
          })
        });
      }
    }
  });


  Vue.component('comment-praise', {
    props: ['isPraise', 'praiseCount', 'commentId'],
    data: function() {
      return {
        is_praise: this.isPraise,
        praise_count: this.praiseCount
      }
    },
    template: `
      <a class="button is-link is-small" @click="praise">
        <span class="icon is-small" :class="{'is-danger': is_praise}">
          <i class="fa" :class="[is_praise ? 'fa-heart' : 'fa-heart-o']"></i>
        </span>
        <span>{{ count }}</span>
      </a>
    `,
    created: function() {
      this.count = this.praiseCount > 0 ? this.praiseCount + "个赞" : "赞";
      this.http_method = this.isPraise ? "DELETE" : "POST";
      this.http_url = '/comments/'+ this.commentId +'/praise';
    },
    watch: {
      praise_count: function(newValue, oldValue) {
        this.count = newValue > 0 ? this.praise_count + "个赞" : "赞";
      },
      is_praise: function(newValue, oldValue) {
        this.http_method = newValue ? "DELETE" : "POST";
      }
    },
    methods: {
      praise: function() {
        var options = {
          method: this.http_method,
          url: this.http_url
        }

        this.$http(options).then((response) => {
          response.json().then((res) => {
            this.is_praise = res.is_praise;
            this.praise_count = res.data.praise_count;
          })
        });
      }
    }
  });


  Vue.component('comment', {
    template: `
      <article class="media comment-entry" @mouseenter="show_btn" @mouseleave="hide_btn">
        <slot></slot>
      </article>
    `,
    methods: {
      show_btn: function() {
        $(this.$el).find('.comment-edit-btn').removeClass('is-hidden');
      },
      hide_btn: function() {
        $(this.$el).find('.comment-edit-btn').addClass('is-hidden');
      }
    }
  });

  function highlight_comment() {
    var hash = window.location.hash.slice(1);

    if (! hash) {return;}

    var $anchor = $('a[name='+ hash +']');
    var $comment = $anchor.parent();
    var animation_class = 'flash animated'
    var animation_end = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';

    setTimeout(function() {
      $comment.addClass(animation_class);
    }, 500);

    $comment.one(animation_end, function() {
      $(this).removeClass(animation_class)
    });
  }

  if ($('#post-show').length > 0) {
    new Vue({
      el: "#post-show"
    })

    highlight_comment() 
  }
  
  hljs.initHighlightingOnLoad();
})();



