ATSB.Components['mobile-components/m-site-header'] = function(options) {
  new Vue({
    el: '.m-site-header-cell',
    data: {
      action: 'menu',
      events: {
        menu: [['drawer:open'], ['header:action:set', 'close']],
        search: [['all:slides:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']],
        close: [['all:slides:close'], ['branch:compare:button:hide'], ['header:action:set', 'menu']],
        back: [['branch:detail:large:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']]
      }
    },
    created: function() {
      ATSB.pubSub.$on('header:action:set', this.actionChange)
    },
    methods: {
      actionClicked: function() {
        console.log(this.action)
        console.log(this.events[this.action])
        ATSB.pubSub.$emit(this.events[this.action])
      },
      searchClicked: function() {
        ATSB.pubSub.$emit(this.events['search'])
      },
      actionChange: function(action) {
        this.action = action
      }
    }
  })
}
