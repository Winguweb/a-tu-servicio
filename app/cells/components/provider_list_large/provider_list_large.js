ATSB.Components['components/provider-list-large'] = Backbone.View.extend({
  initialize: function(options) {
    el = this.el
    _.bindAll(this, 'providersFetch', 'providersFetchSuccess', 'componentShow', 'componentHide', 'componentToggle')

    ATSB.pubSub.on({
      'providersFetch:fetch': this.providersFetch,
      'provider:list:large:toggle': this.componentToggle,
    })

    this.component = new Vue({
      el: el,
      data: {
        providers: [],
        searchQuery: "",
      },
      watch: {
        searchQuery: _.debounce(this.searchQueryChanged, 300)
      }
    })

    this.providersFetch()
  },
  providersFetch: function(data) {
    var providers = new ATSB.Models['models/provider'](data)
    providers.fetch({success: this.providersFetchSuccess})
  },
  providersFetchSuccess: function(data) {
    var providers = data.toJSON()
    this.component.providers = providers
  },
  searchQueryChanged: function(query) {
    ATSB.pubSub.trigger('providersFetch:fetch', {query: query})
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
