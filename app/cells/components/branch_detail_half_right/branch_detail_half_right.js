ATSB.Components['components/branch-detail-half-right'] = function(options) {
  new Vue({
    el: '.branch-detail-half-right-cell',
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
      ATSB.pubSub.$on('branch:detail:half-right:open', this.componentOpen)
      ATSB.pubSub.$on('branch:detail:half-right:fetch', this.branchFetch)
      ATSB.pubSub.$on('branch:compare:colors', this.changeColors)
    },
    methods: {
      toPercentage: ATSB.Helpers.numbers.toPercentage,
      toNOf: ATSB.Helpers.numbers.toNOf,
      toNOfTen: ATSB.Helpers.numbers.toNOfTen,
      toNOfReverse: ATSB.Helpers.numbers.toNOfReverse,
      toNOfTenReverse: ATSB.Helpers.numbers.toNOfTenReverse,
      branchFetch: function(id) {
        ATSB.pubSub.$emit('fetch:branch:id', id, this.branchFetchSuccess, this.branchFetchError)
      },
      branchFetchSuccess: function(response) {
        this.branch = response.data
        this.branch.loaded = true
        ATSB.pubSub.$emit('branch:compare:load:right', this.branch)
      },
      branchFetchError: function() {
        console.warn('Cant reach branch')
      },
      componentClose: function() {
        this.actions.show = false
        this.normalLayout()
      },
      componentOpen: function() {
        this.actions.show = true
        this.comparingLayout()
      },
      comparingLayout: function() {
        $('body').addClass('comparing')
      },
      normalLayout: function() {
        $('body').removeClass('comparing')
      },
      changeColors: function(compared) {
        c = ['red', 'blue', 'green']
        this.colors = {
          satisfactions: c[ATSB.Utils.compare(compared.right.satisfaction,compared.left.satisfaction)+1],
          waiting_times: c[ATSB.Utils.compare(compared.left.waiting_times_percentage_from_worst,compared.right.waiting_times_percentage_from_worst)+1],
        }
      },
    }
  })
}
