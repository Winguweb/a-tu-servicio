ATSB.Components['components/branch-list-half-right'] = function(options) {
  new Vue({
    el: '.branch-list-half-right-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false},
      suggestions: "",
      page: 1,
      perform_search: true,
      perform_lazy: false,
      end_of_lazy: true,
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:half-right:open', this.componentOpen)
      ATSB.pubSub.$emit('fetch:branch:search', { query: this.searchQuery }, this.branchesFetchSuccess, this.branchesFetchError)
    },
    watch: {
      searchQuery: _.debounce(function(){
        this.page = 1
        this.end_of_lazy = false
        this.searchQueryChanged()
      }, 200)
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
      clearSearchClicked: function() {
        this.searchQuery = ''
      },
      branchesFetchSuccess: function(response) {
        this.branches = this.transformHitsToResults(response.hits)
        this.suggestions = response.data.suggestions
        this.perform_search = false
        this.focusSearch()
      },
      branchesFetchSuccessAppend: function(response) {
        var results = this.transformHitsToResults(response.hits)
        if (results.length == 0) {
          this.end_of_lazy = true
          this.perform_lazy = false
          return
        }
        this.branches = this.branches.concat(results)
        this.suggestions = response.data.suggestions
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
        this.perform_search = false
        this.perform_lazy = false
        this.focusSearch()
      },
      branchesFetchError: function() {
        this.perform_search = false
        this.perform_lazy = false
        this.focusSearch()
        console.warn()
      },
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function() {
        this.actions.show = true
        this.focusSearch()
      },
      focusSearch: function() {
        this.actions.show && this.$nextTick(function() {this.$refs.search.focus()}.bind(this))
      },
      searchQueryChanged: function(append) {
        var branchesFetchSuccess = append ? this.branchesFetchSuccessAppend : this.branchesFetchSuccess
        // var query = this.searchQuery + "&page=" + this.page
        ATSB.pubSub.$emit('fetch:branch:search', { query: this.searchQuery, page: this.page }, branchesFetchSuccess, this.branchesFetchError)
        this.perform_search = !append
        this.perform_lazy = append
      },
      scrollEnd: function(evt) {
        var element = evt.currentTarget
        if(element.offsetHeight + element.scrollTop > element.scrollHeight - 10) {
          if (this.perform_lazy || this.end_of_lazy) return
          _.debounce(function(){
            this.page++
            this.searchQueryChanged(true)
            this.$nextTick(function() {element.scrollTop = element.scrollHeight}.bind(this))
          }.bind(this), 100)()
        }
      },
      transformHitsToResults: function(hits){
        return _(hits).map(function(hitData){
          var coordinates = [ hitData._geoloc.lat, hitData._geoloc.lng ]
          return {
            id: hitData.objectID,
            name: hitData.name,
            provider_name: hitData.provider_name,
            coordinates: coordinates
          }
        })
      }
    }
  })
}
