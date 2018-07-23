ATSB.Components['components/branch-detail-half-right'] = function(options) {
  new Vue({
    el: '.branch-detail-half-right-cell',
    data: {
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('branchFetch:fetch', this.branchFetch)
      ATSB.pubSub.$on('branch:detail:half-right:open', this.componentOpen)
    },
    watch: {
      searchQuery: _.debounce(this.searchQueryChanged, 300)
    },
    methods: {
      branchFetch: function() {
        console.log('branchFetch Event')
      },
      componentOpen: function() {
        this.actions.show = true
      },
      componentClose: function() {
        this.actions.show = false
      },
    }
  })
}
