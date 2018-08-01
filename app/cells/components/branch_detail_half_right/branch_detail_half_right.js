ATSB.Components['components/branch-detail-half-right'] = function(options) {
  new Vue({
    el: '.branch-detail-half-right-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:half-right:open', this.componentOpen)
      ATSB.pubSub.$on('branch:detail:half-right:fetch', this.branchFetch)
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
        console.log(response.data)
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
      }
    }
  })
}
