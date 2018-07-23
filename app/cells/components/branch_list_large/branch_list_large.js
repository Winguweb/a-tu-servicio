ATSB.Components['components/branch-list-large'] = Backbone.View.extend({
  initialize: function(options) {
    el = this.el
    _.bindAll(this, 'branchesFetch', 'branchesFetchSuccess', 'componentShow', 'componentHide', 'componentToggle')

    ATSB.pubSub.on({
      'branchesFetch:fetch': this.branchesFetch,
      'branch:list:large:toggle': this.componentToggle,
    })

    this.component = new Vue({
      el: el,
      data: {
        branches: [],
        searchQuery: "",
      },
      watch: {
        searchQuery: _.debounce(this.searchQueryChanged, 300)
      }
    })

    this.branchesFetch()
  },
  branchesFetch: function(data) {
    var branches = new ATSB.Models['models/branch'](data)
    branches.fetch({success: this.branchesFetchSuccess})
  },
  branchesFetchSuccess: function(data) {
    var branches = data.toJSON()
    this.component.branches = branches
  },
  searchQueryChanged: function(query) {
    ATSB.pubSub.trigger('branchesFetch:fetch', {query: query})
  },
  componentShow: function() {
    $(this.component.$el).addClass('show')
  },
  componentHide: function() {
    $(this.component.$el).removeClass('show')
  },
  componentToggle: function() {
    $(this.component.$el).toggleClass('show')
  },

})
