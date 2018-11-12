ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      barColors: {users_types: "#3fa6c9"},
    },
    created: function() {
      ATSB.pubSub.$on('branch:full:detail:open', this.componentOpen)
      ATSB.pubSub.$on('branch:full:detail:close', this.componentClose)
      ATSB.pubSub.$on('branch:full:detail:data', this.branchData)
    },
    methods: {
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function(id) {
        this.actions.show = true
      },
      branchData: function(branch) {
        this.branch = branch
      },
    }
  })
}
