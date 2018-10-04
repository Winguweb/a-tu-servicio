ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      branchId: 1,
      actions: {show: false},
      steps: options.steps,
      actualStep: 1,
      inputValue: ""
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
      getActualAnswer: function() {
        return this.getActualStep().answer
      },
      getActualStep: function() {
        return this.getStepById(this.actualStep)
      },
      getStepById: function(id) {
        var step = this.steps.filter(function(step) {
          return step.id == id
        })
        return step && step[0]
      },
      nextStep: function() {
        var actualStep = this.getActualStep()
        var actualAnswerId = this.getActualAnswer()
        if (actualAnswerId == null) { return }
        var nextStep = actualStep.next_step[actualAnswerId] || actualStep.id+1
        this.getStepById(nextStep).previous_step = actualStep.id
        this.inputValue = ""
        this.actualStep = +nextStep
        this.preloadInputValue()
      },
      preloadInputValue: function() {
        var actualStep = this.getActualStep()
        if(actualStep.answers[0].type == "input") {
          this.inputValue = actualStep.answer
        }
      },
      previousStep: function() {
        var actualStep = this.getActualStep()
        var previousStep = actualStep.previous_step
        if (previousStep) { this.actualStep = +previousStep }
        this.preloadInputValue()
      },
      selectAnswer: function(id) {
        this.getStepById(this.actualStep).answer = id
      },
      setAnswer: function() {
        this.getStepById(this.actualStep).answer = this.inputValue
      },
    }
  })
}
