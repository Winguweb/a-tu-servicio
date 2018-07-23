ATSB.Components['components/branch-detail-half-right'] = function(options) {
  new Vue({
    el: '.branch-detail-half-right-cell',
    data: {
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branchFetch:fetch', this.branchFetch)
      ATSB.pubSub.$on('branch:detail:half-right:open', this.componentOpen)
    },
    methods: {
      branchFetch: function() {
        console.log('branchFetch Event')
      },
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function() {
        this.actions.show = true
      },
    }
  })
}
