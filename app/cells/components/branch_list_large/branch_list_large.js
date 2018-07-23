ATSB.Components['components/branch-list-large'] = function(options) {
  new Vue({
    el: '.branch-list-large-cell',
    data: {
      branches: options.branches,
      searchQuery: "",
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('branchesFetch:fetch', this.branchesFetch)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
    },
    watch: {
      searchQuery: _.debounce(this.searchQueryChanged, 300)
    },
    methods: {
      branchClicked: function() {
        this.componentClose()
        ATSB.pubSub.$emit('branch:detail:half-right:open')
      },
      branchesFetch: function() {
        console.log('branchesFetch Event')
      },
      componentOpen: function() {
        this.actions.show = true
      },
      componentClose: function() {
        this.actions.show = false
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
