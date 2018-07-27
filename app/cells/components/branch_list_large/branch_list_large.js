ATSB.Components['components/branch-list-large'] = function(options) {
  new Vue({
    el: '.branch-list-large-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false},
      suggestions: "",
      perform_search: true,
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$emit('fetch:branch:search', '', this.branchesFetchSuccess, this.branchesFetchError)
    },
    watch: {
      searchQuery: _.debounce(function(){this.searchQueryChanged()}, 300)
    },
    methods: {
      branchClicked: function(id) {
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:detail:large:open')
        ATSB.pubSub.$emit('branch:detail:large:fetch', id)
        ATSB.pubSub.$emit('branch:selected', [id])
        ATSB.pubSub.$emit('branch:compare:set', id)
        ATSB.pubSub.$emit('branch:compare:button:show')
      },
      suggestionClicked: function(suggestion) {
        this.searchQuery = suggestion
      },
      branchesFetchSuccess: function(response) {
        this.branches = response.data.results
        this.suggestions = response.data.suggestions
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
        this.perform_search = false
      },
      branchesFetchError: function() {
        this.perform_search = false
        console.warn()
      },
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function() {
        this.actions.show = true
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
      },
      searchQueryChanged: function() {
        ATSB.pubSub.$emit('fetch:branch:search', this.searchQuery, this.branchesFetchSuccess, this.branchesFetchError)
        this.perform_search = true
      },
      getBranchesIds: function() {
        return this.branches.map(function(branch) {return branch.id})
      }
    }
  })
}
