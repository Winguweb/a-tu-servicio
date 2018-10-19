ATSB.Components['components/branch-detail-large'] = function(options) {
  new Vue({
    el: '.branch-detail-large-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:detail:large:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:large:fetch', this.branchFetch)
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
      },
      branchFetchError: function() {
        console.warn('Cant reach branch')
      },
      componentClose: function() {
        this.actions.show = false
        ATSB.pubSub.$emit('map:centered', true)
      },
      componentOpen: function() {
        this.$el.scrollTop = 0
        this.actions.show = true
        ATSB.pubSub.$emit('map:centered', false)
        ATSB.pubSub.$emit('map:activearea', "small")
        ATSB.pubSub.$emit('header:action:set', 'back')
      },
      openVoteModal: function() {
        ATSB.pubSub.$emit('vote:open', this.branch.id)
      },
    }
  })
}
