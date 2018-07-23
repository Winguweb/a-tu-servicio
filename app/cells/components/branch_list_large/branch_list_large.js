ATSB.Components['components/branch-list-large'] = function(options) {
  new Vue({
    el: '.branch-list-large-cell',
    data: {
      branches: options.branches,
      searchQuery: "",
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
    },
    watch: {
      searchQuery: _.debounce(function(){this.searchQueryChanged()}, 300)
    },
    methods: {
      branchClicked: function() {
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:detail:half-right:open')
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
  // initialize: function(options) {
  //   el = this.el
  //   _self = this
  //   _.bindAll(this, 'branchesFetch', 'branchesFetchSuccess', 'componentShow', 'componentHide', 'componentToggle')



  //   this.branchesFetch()
  // },
  // branchesFetch: function(data) {
  //   var branches = new ATSB.Models['models/branch'](data)
  //   branches.fetch({success: this.branchesFetchSuccess})
  // },
  // branchesFetchSuccess: function(data) {
  //   var branches = data.toJSON()
  //   this.component.branches = branches
  // },
  // searchQueryChanged: function(query) {
  //   ATSB.pubSub.trigger('branchesFetch:fetch', {query: query})
  // },
  // componentShow: function() {
  //   $(this.component.$el).addClass('show')
  // },
  // componentHide: function() {
  //   $(this.component.$el).removeClass('show')
  // },
  // componentToggle: function() {
  //   $(this.component.$el).toggleClass('show')
  // },
