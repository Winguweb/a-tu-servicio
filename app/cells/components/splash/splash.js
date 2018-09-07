ATSB.Components['components/splash'] = function(options) {
  new Vue({
    el: '.splash-cell',
    data: {
      actions: {show: false},
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:list:large:close', this.componentClose)
    },
    methods: {
      closeClicked: function(id) {

      },
    }
  })
}
