ATSB.Components['components/site-header'] = function(options) {
  new Vue({
    el: '.site-header-cell',
    data: {
      action: 'open',
      events: {
        open: [['all:slides:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']],
        close: [['all:slides:close'], ['general:info:open'], ['branch:compare:button:hide'], ['header:action:set', 'open'], ['map:activearea']],
        back: [['branch:detail:large:close'], ['branch:list:large:open'], ['branch:compare:button:hide'], ['header:action:set', 'close']],
        closeDetails: [['branch:full:detail:close'], ['header:action:set', 'back']]
      }
    },
    created: function() {
      ATSB.pubSub.$on('header:action:set', this.actionChange)
    },
    methods: {
      actionClicked: function() {
        ATSB.pubSub.$emit(this.events[this.action])
      },
      actionChange: function(action) {
        this.action = action
      }
    }
  })
}
