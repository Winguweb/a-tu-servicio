ATSB.Components['components/general-info'] = function(options) {
  new Vue({
    el: '.general-info-cell',
    data: {
      actions: {show: true}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
    },
    methods: {
      componentClose: function() {
        this.actions.show = false
        ATSB.pubSub.$emit('map:centered', true)
        $('body').removeClass('small-reference-map')
      },
      componentOpen: function() {
        this.actions.show = true
        ATSB.pubSub.$emit('map:centered', false)
        ATSB.pubSub.$emit('map:offset', 0.61803398875)
        ATSB.pubSub.$emit('header:action:set', 'back')
      },
      actionClicked: function() {
        ATSB.pubSub.$emit([['all:slides:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']])
      }
    }
  })
}
