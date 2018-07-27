ATSB.Components['components/branch-list-half-right'] = function(options) {
  new Vue({
    el: '.branch-list-half-right-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false},
      suggestions: "",
      perform_search: true,
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:half-right:open', this.componentOpen)
      ATSB.pubSub.$emit('fetch:branch:search', '', this.branchesFetchSuccess, this.branchesFetchError)
    },
    watch: {
      searchQuery: _.debounce(function(){this.searchQueryChanged()}, 300)
    },
    methods: {
      suggestionClicked: function(suggestion) {
        this.searchQuery = suggestion
      },
      branchClicked: function(id) {
        this.componentClose()
        ATSB.pubSub.$emit('branch:detail:half-right:open')
        ATSB.pubSub.$emit('branch:detail:half-right:fetch', id)
        ATSB.pubSub.$emit('branch:compare:set', id)
        ATSB.pubSub.$emit('branch:compare:button:hide')
      },
      branchesFetchSuccess: function(response) {
        this.branches = response.data.results
        this.suggestions = response.data.suggestions
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
      },
      searchQueryChanged: function() {
        ATSB.pubSub.$emit('fetch:branch:search', this.searchQuery, this.branchesFetchSuccess, this.branchesFetchError)
        this.perform_search = true
      },
    }
  })
}
