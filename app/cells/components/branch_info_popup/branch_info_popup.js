ATSB.Components['components/branch-info-popup'] = function(options) {
  new Vue({
    el: '.branch-info-popup-cell',
    data: {
      branch: {},
      position: {},
      actions: {show: false},
      hideTimer: null
    },
    created: function() {
      ATSB.pubSub.$on('branch:hover:open', this.componentOpen)
      ATSB.pubSub.$on('branch:hover:close', this.componentClose)
    },
    methods: {
      componentClose: function() {
        var _this = this
        this.hideTimer = setTimeout(function() {_this.actions.show = false }, 300)
      },
      componentOpen: function(info) {
        this.branch = info.branch
        this.position = this.positionToCss(info.position)
        this.actions.show = true
        clearTimeout(this.hideTimer)
      },
      positionToCss: function(position) {
        return {left: `${position.left}px`, top: `${position.top}px`}
      }
    }
  })
}
