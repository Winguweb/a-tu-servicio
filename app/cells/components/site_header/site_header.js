ATSB.Components['components/site-header'] = Backbone.View.extend({
  initialize: function(options) {
    _.bindAll(this, 'menuClicked')

    this.menuButton = this.$el.find('')
  },
  events: {
    'click .site-menu-button': 'menuClicked',
  },
  menuClicked: function() {
    ATSB.pubSub.trigger('branch:list:large:toggle')
  },
})
