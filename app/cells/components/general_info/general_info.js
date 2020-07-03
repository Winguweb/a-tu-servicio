ATSB.Components['components/general-info'] = function(options) {
  new Vue({
    el: '.general-info-cell',
    data: {
      actions: {show: false}
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('general:info:open', this.componentOpen)
    },
    mounted: function(){ 
      //component is ready to use
      ATSB.pubSub.$emit('general:info:created')
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
        ATSB.pubSub.$emit('map:activearea', "small")
        ATSB.pubSub.$emit('header:action:set', 'back')
        $('body').addClass('small-reference-map')
      },
      actionClicked: function() {
        ATSB.pubSub.$emit([['all:slides:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']])
      }
    }
  })
}
