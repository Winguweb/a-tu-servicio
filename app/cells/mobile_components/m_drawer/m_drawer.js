ATSB.Components['mobile-components/m-drawer'] = function(options) {
  new Vue({
    el: '.m-drawer-cell',
    data: {
      actions: {show: false},
    },
    created: function() {
      ATSB.pubSub.$on('drawer:open', this.componentOpen)
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
    },
    methods: {
      componentOpen: function() {
        this.actions.show = true
      },
      componentClose: function() {
        this.actions.show = false
      },
      backgroundClick: function() {
        ATSB.pubSub.$emit([['all:slides:close'], ['branch:compare:button:hide'], ['header:action:set', 'menu']])
      },
    }
  })
}
