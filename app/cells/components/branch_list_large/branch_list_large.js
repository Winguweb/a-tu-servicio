ATSB.Components['components/branch-list-large'] = function(options) {
  new Vue({
    el: '.branch-list-large-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false},
      page: 0,
      performingSearch: false,
      performLazy: false,
      endOfLazy: false,
      performSearchDebounceTime: 100
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:list:large:close', this.componentClose)

      this.$watch('searchQuery', _.debounce(function() {
        this.page = 0
        this.endOfLazy = false
        this.searchQueryChanged()
      }, this.performSearchDebounceTime))
    },
    methods: {
      branchClicked: function(slug) {
        window.history.pushState(null, '', `/mapa-de-servicios/${slug}`)
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:detail:large:open')
        ATSB.pubSub.$emit('branch:detail:large:fetch', slug)
        ATSB.pubSub.$emit('branch:selected', [slug])
        ATSB.pubSub.$emit('branch:compare:set', slug)
        ATSB.pubSub.$emit('branch:compare:button:show')
      },
      branchesFetchSuccess: function(response) {
        this.branches = this.transformHitsToResults(response.hits)
        ATSB.pubSub.$emit('branch:selected', this.getBranchesSlugs())
        this.performingSearch = false
        this.focusSearch()
      },
      branchesFetchSuccessAppend: function(response) {
        var results = this.transformHitsToResults(response.hits)
        if (results.length == 0) {
          this.endOfLazy = true
          this.performLazy = false
          return
        }
        this.branches = this.branches.concat(results)
        ATSB.pubSub.$emit('branch:selected', this.getBranchesSlugs())
        this.performingSearch = false
        this.performLazy = false
        if(this.isMobile() == false) { this.focusSearch() }
      },
      branchesFetchError: function() {
        this.performingSearch = false
        this.performLazy = false
        this.focusSearch()
        console.warn()
      },
      clearSearchClicked: function() {
        this.$refs.search.value = this.searchQuery = ''
      },
      closeMobileKeyboard: function() {
        this.$refs.search.blur()
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
        ATSB.pubSub.$emit('fetch:branch:search', this.searchParams(this.searchQuery, this.page), this.branchesFetchSuccess, this.branchesFetchError)
        this.focusSearch()
      },
      focusSearch: function() {
        this.actions.show && this.$nextTick(function() {this.$refs.search.focus()}.bind(this))
      },
      isMobile: function() {
        return $('body').hasClass('mobile')
      },
      searchQueryChanged: function(append) {
        var branchesFetchSuccess = append ? this.branchesFetchSuccessAppend : this.branchesFetchSuccess
        // var query = this.searchQuery + "&page=" + this.page
        ATSB.pubSub.$emit('fetch:branch:search', this.searchParams(this.searchQuery, this.page), branchesFetchSuccess, this.branchesFetchError)
        this.performingSearch = !append
        this.performLazy = append
      },
      getBranchesIds: function() {
        return this.branches.map(function(branch) {return branch.id})
      },
      getBranchesSlugs: function() {
        return this.branches.map(function(branch) {return branch.slug})
      },
      performSearch: function(evt) {
        this.searchQuery = evt.target.value
      },
      scrollEnd: function(evt) {
        var element = evt.currentTarget
        if(element.offsetHeight + element.scrollTop > element.scrollHeight - 10) {
          if (this.performLazy || this.endOfLazy) return
          _.debounce(function() {
            this.page++
            this.searchQueryChanged(true)
            this.$nextTick(function() {element.scrollTop = element.scrollHeight}.bind(this))
          }.bind(this), 100)()
        }
      },
      searchParams: function(query, page) {
        return {
          query: query,
          highlightPreTag: '<em class="search-highlight">',
          highlightPostTag: '</em>',
          getRankingInfo: true,
          facets: [ "specialities_names" ],
          page: page,
          hitsPerPage: query == '' ? 9999 : 50
        }
      },
      suggestionClicked: function(suggestion) {
        this.searchQuery = suggestion
      },
      transformHitsToResults: function(hits) {
        return _(hits).map(function(hitData) {
          var coordinates = [ hitData._geoloc.lat, hitData._geoloc.lng ]
          var matched_specialties = _.compact(_(hitData._highlightResult.specialities_names).map(function(data) {
            if (data.matchLevel != 'none') {
              return data.value
            }
          }))
          return {
            id: hitData.objectID,
            slug: hitData.slug,
            name: hitData._highlightResult.name.value,
            provider_name: hitData._highlightResult.provider_name.value,
            coordinates: coordinates,
            matched_specialties: matched_specialties
          }
        })
      }
    }
  })
}
