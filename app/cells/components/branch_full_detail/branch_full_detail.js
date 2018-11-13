ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      barColors: {
        users_types: "#3fa6c9",
        waiting_times: {
          very_bad: "#FF3E25",
          bad: "#ff9425",
          acceptable: "#FFC649",
          good: "#c7d83d",
          very_good: "#92c461"
        },
        explanations: {
          bad: "#ff9425",
          good: "#c7d83d",
        }
      },
      legends: {
        very_bad: 'Muy malo',
        bad: 'Malo',
        acceptable: 'Aceptable',
        good: 'Bueno',
        very_good: 'Muy bueno',
      }
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
