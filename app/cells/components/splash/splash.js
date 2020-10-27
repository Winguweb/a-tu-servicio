ATSB.Components['components/splash'] = function(options) {
  new Vue({
    el: '.splash-cell',
    data: {
      actions: {show: true},
      displacement: 0,
      isMobile: $('body').hasClass('mobile'),
      // from search
      branches: [],
      searchQuery: "",
      page: 0,
      performingSearch: false,
      showList: false,
      performLazy: false,
      endOfLazy: false,
      performSearchDebounceTime: 100
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:list:large:close', this.componentClose)

      // if (this.isMobile) {this.moveCity()}

      this.$watch('searchQuery', _.debounce(function() {
        this.page = 0
        this.endOfLazy = false
        this.searchQueryChanged()
      }, this.performSearchDebounceTime))      
    },
    methods: {
      closeClicked: function(id) {
        this.actions.show = false
      },
      handleOrientation: function(event) {
        this.displacement = Math.round(event.gamma)
      },
      moveCity: function() {
        window.addEventListener("deviceorientation", this.handleOrientation, true);
      },
      branchClicked: function(slug) {
        window.location.href = window.location.origin + '/mapa-de-servicios/' + slug
      },
      branchesFetchSuccess: function(response) {      
        const branches = this.transformHitsToResults(response.hits).filter((obj, index) => index < 5)
        this.branches = branches
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
        this.performingSearch = false
        this.showList = true
        this.focusSearch()
      },
      branchesFetchSuccessAppend: function(response) {
        var results = this.transformHitsToResults(response.hits).filter((obj, index) => index < 5)
        if (results.length == 0) {
          this.endOfLazy = true
          this.performLazy = false
          return
        }
        this.branches = this.branches.concat(results)
        ATSB.pubSub.$emit('branch:selected', this.getBranchesIds())
        this.performingSearch = false
        this.showList = true
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
        this.showList = false
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
        if (this.searchQuery.length == 0) {
          this.showList = false
          return false
        }

        var branchesFetchSuccess = append ? this.branchesFetchSuccessAppend : this.branchesFetchSuccess
        ATSB.pubSub.$emit('fetch:branch:search', this.searchParams(this.searchQuery, this.page), branchesFetchSuccess, this.branchesFetchError)
        this.performingSearch = !append
        this.performLazy = append
      },
      getBranchesIds: function() {
        return this.branches.map(function(branch) {return branch.id})
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
