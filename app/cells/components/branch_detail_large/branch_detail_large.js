ATSB.Components['components/branch-detail-large'] = function(options) {
  new Vue({
    el: '.branch-detail-large-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      slug: null
    },
    created: function() {      
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:detail:large:close', this.componentClose)
      ATSB.pubSub.$on('branch:detail:large:fetch', this.branchFetch)      
    },
    mounted: function(){
      //component is ready to use
      ATSB.pubSub.$emit('branch:detail:large:created')
    },
    methods: {
      toPercentage: ATSB.Helpers.numbers.toPercentage,
      toNOf: ATSB.Helpers.numbers.toNOf,
      toNOfTen: ATSB.Helpers.numbers.toNOfTen,
      toNOfReverse: ATSB.Helpers.numbers.toNOfReverse,
      toNOfTenReverse: ATSB.Helpers.numbers.toNOfTenReverse,
      branchFetch: function(slug) {
        this.slug = slug
        ATSB.pubSub.$emit('fetch:branch:slug', slug, this.branchFetchSuccess, this.branchFetchError)
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
      openDetailsModal: function() {
        ATSB.pubSub.$emit('branch:full:detail:data', this.branch)
        ATSB.pubSub.$emit('branch:full:detail:open')
        ATSB.pubSub.$emit('header:action:set', 'closeDetails')
      },
      openVoteModal: function() {
        console.log(this.branch)
        ATSB.pubSub.$emit('vote:open', {
          branchId: this.branch.id,
          branchSlug: this.slug,
          branchSpecialities: this.branch.initial_source
        })
      },
      hasSpecialitiesInformationToShow: function(source) {
        return this.hasInformationToShow(source, 'has_specialities_information')
      },
      hasSatisfactionInformationToShow: function(source) {
        return this.hasInformationToShow(source, 'has_satisfaction_information')
      },
      hasWaitingTimesInformationToShow: function(source) {
        return this.hasInformationToShow(source, 'has_waiting_times_information')
      },
      hasInformationToShow: function(source, type) {
        var source = this.branch[source][type]
        return source
      }
    }
  })
}
