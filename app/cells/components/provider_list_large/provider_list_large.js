ATSB.Components['components/provider-list-large'] = Backbone.View.extend({
  initialize: function(options) {
    el = this.el
    _.bindAll(this, 'providersFetch', 'providersFetchSuccess')

    ATSB.pubSub.on({
      'providersFetch:fetch': this.providersFetch,
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
  }
})
