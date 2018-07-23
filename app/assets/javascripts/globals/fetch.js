ATSB.Models['models/branch'] = Backbone.Collection.extend({
  initialize: function(options) {
    this.query = options ? options.query : ''
  },
  url: function() {return "/api/v1/branches?q="+this.query},
})
