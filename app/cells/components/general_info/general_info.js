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
      },
      componentOpen: function() {
        this.actions.show = true
        ATSB.pubSub.$emit('map:centered', false)
        ATSB.pubSub.$emit('header:action:set', 'back')
      }
    }
  })
}
