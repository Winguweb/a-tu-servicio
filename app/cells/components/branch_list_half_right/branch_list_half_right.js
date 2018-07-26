ATSB.Components['components/branch-list-half-right'] = function(options) {
  new Vue({
    el: '.branch-list-half-right-cell',
    data: {
      branches: [],
      searchQuery: "",
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:half-right:open', this.componentOpen)
    },
    watch: {
      searchQuery: _.debounce(function(){this.searchQueryChanged()}, 300)
    },
    methods: {
      branchClicked: function(id) {
        this.componentClose()
        ATSB.pubSub.$emit('branch:detail:half-right:open')
        ATSB.pubSub.$emit('branch:detail:half-right:fetch', id)
        ATSB.pubSub.$emit('branch:compare:set', id)
        ATSB.pubSub.$emit('branch:compare:button:hide')
      },
      branchesFetchSuccess: function(response) {
        this.branches = response.data
      },
      branchesFetchError: function() {
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
      },
    }
  })
}
