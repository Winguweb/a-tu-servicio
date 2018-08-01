ATSB.Components['components/branch-detail-half-left'] = function(options) {
  new Vue({
    el: '.branch-detail-half-left-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      colors: {
        beds: null,
        waiting_times: null,
        satisfactions: null,
      }
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:half-left:open', this.componentOpen)
      ATSB.pubSub.$on('branch:detail:half-left:fetch', this.branchFetch)
      ATSB.pubSub.$on('branch:compare:colors', this.changeColors)
    },
    methods: {
      toPercentage: ATSB.Helpers.numbers.toPercentage,
      toNOfTen: ATSB.Helpers.numbers.toNOfTen,
      toNOfTenReverse: ATSB.Helpers.numbers.toNOfTenReverse,
      branchFetch: function(id) {
        ATSB.pubSub.$emit('fetch:branch:id', id, this.branchFetchSuccess, this.branchFetchError)
      },
      branchFetchSuccess: function(response) {
        this.branch = response.data
        this.branch.loaded = true
        ATSB.pubSub.$emit('branch:compare:load:left', this.branch)
        console.log(response.data)
      },
      branchFetchError: function() {
        console.warn('Cant reach branch')
      },
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function() {
        this.actions.show = true
        ATSB.pubSub.$emit('header:action:set', 'close')
      },
      changeColors: function(compared) {
        c = ['red', 'blue', 'green']
        this.colors = {
          satisfactions: c[ATSB.Utils.compare(compared.left.satisfaction,compared.right.satisfaction)+1],
          waiting_times: c[ATSB.Utils.compare(compared.right.waiting_times_percentage_from_worst,compared.left.waiting_times_percentage_from_worst)+1],
        }
      },
    }
  })
}
