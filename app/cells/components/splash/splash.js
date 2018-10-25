ATSB.Components['components/splash'] = function(options) {
  new Vue({
    el: '.splash-cell',
    data: {
      actions: {show: true},
      displacement: 0,
      isMobile: $('body').hasClass('mobile')
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:list:large:open', this.componentOpen)
      ATSB.pubSub.$on('branch:list:large:close', this.componentClose)

      if (this.isMobile) {this.moveCity()}
    },
    methods: {
      closeClicked: function(id) {
        this.actions.show = false
      },
      handleOrientation: function(event) {
        this.displacement = Math.round(event.gamma)
      },
      moveCity: function() {
        window.addEventListener("deviceorientation", this.handleOrientation, true);
      },
    }
  })
}
