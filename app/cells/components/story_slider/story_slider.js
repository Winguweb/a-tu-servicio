ATSB.Components['components/story-slider'] = Backbone.View.extend({
  initialize: function(options) {
    _.bindAll(
      this,
      'links',
    )
    this.links()
  },
  links: function() {
    var $parent = $(this.$el).find('>div')
    var $margin_bottom = parseInt($parent.find('article').css('margin-bottom'))
    $(this.$el).on('click', 'a[href^="#"]', function (event) {
        event.preventDefault();
        var $article = $($(this).attr('href'))
        $parent.animate({
            scrollTop: $article[0].offsetTop - $margin_bottom
        }, 500)
    });
  },
})
