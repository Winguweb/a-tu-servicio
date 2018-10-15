ATSB.Components['components/branch-list-large'] = function(options) {
  new Vue({
    el: '.branch-list-large-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false},
      suggestions: "",
      page: 0,
      perform_search: false,
      perform_lazy: false,
      end_of_lazy: false,
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:list:large:close', this.componentClose)
      ATSB.pubSub.$emit('fetch:branch:search', this.searchParams(this.searchQuery, this.page), this.branchesFetchSuccess, this.branchesFetchError)
    },
    watch: {
      searchQuery: _.debounce(function(){
        this.page = 0
        this.end_of_lazy = false
        this.searchQueryChanged()
      }, 200)
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
      clearSearchClicked: function() {
        this.searchQuery = ''
      },
      branchesFetchSuccess: function(response) {
        this.branches = this.transformHitsToResults(response.hits)
        this.suggestions = response.data.suggestions
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
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
        ATSB.pubSub.$emit('map:centered', true)
      },
      componentOpen: function() {
        if (this.actions.show) return
        this.actions.show = true
        ATSB.pubSub.$emit('map:centered', false)
        ATSB.pubSub.$emit('map:activearea', "small")
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
        this.focusSearch()
      },
      focusSearch: function() {
        this.actions.show && this.$nextTick(function() {this.$refs.search.focus()}.bind(this))
      },
      searchQueryChanged: function(append) {
        var branchesFetchSuccess = append ? this.branchesFetchSuccessAppend : this.branchesFetchSuccess
        // var query = this.searchQuery + "&page=" + this.page
        ATSB.pubSub.$emit('fetch:branch:search', this.searchParams(this.searchQuery, this.page), branchesFetchSuccess, this.branchesFetchError)
        this.perform_search = !append
        this.perform_lazy = append
      },
      getBranchesIds: function() {
        return this.branches.map(function(branch) {return branch.id})
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
      searchParams: function(query, page){
        return {
          query: query,
          highlightPreTag: '<search-highlight>',
          highlightPostTag: '</search-highlight>',
          getRankingInfo: true,
          facets: [ "specialities_names" ],
          page: page
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
