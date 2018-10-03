ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      branchId: 1,
      actions: {show: false},
      steps: options.steps,
      actualStep: 0
    },
    created: function() {
      ATSB.pubSub.$on('vote:open', this.componentOpen)
      ATSB.pubSub.$on('vote:close', this.componentClose)
    },
    methods: {
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function(id) {
        this.branchId = id
        this.actions.show = true
      },
      selectAnswer: function(id) {
        this.steps[this.actualStep].answer = id
      },
      nextStep: function() {
        (this.actualStep == this.steps.length - 1) || this.actualStep++
      },
      previousStep: function() {
        this.actualStep == 0 || this.actualStep--
      }
    }
  })
}
