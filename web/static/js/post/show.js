import Vue from "vue/dist/vue.js";
import VueResource from "vue-resource";

Vue.use(VueResource);
Vue.http.headers.common["X-CSRF-TOKEN"] = $("meta[name=csrf]").attr("content");

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
        <i class="fa fa-heart" :class="[is_praise ? 'fa-heart' : 'fa-heart-o']"></i>
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
      console.log(newValue, oldValue)
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

if ($('#post-show').length > 0) {
  new Vue({
    el: '#post-show'
  });
}
