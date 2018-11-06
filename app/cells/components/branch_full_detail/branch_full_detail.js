ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      actions: {show: false},
    },
    created: function() {
      ATSB.pubSub.$on('vote:open', this.componentOpen)
      ATSB.pubSub.$on('vote:close', this.componentClose)
    },
    methods: {
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function(id) {
        this.actions.show = true
      },
    }
  })
}
