ATSB.Models['models/provider'] = Backbone.Collection.extend({
  initialize: function(options) {
    this.query = options ? options.query : ''
  },
  url: function() {return "/api/v1/providers?q="+this.query},
})
