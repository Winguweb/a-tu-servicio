ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      branchId: 1,
      actions: {show: false},
      steps: options.steps,
      actualStep: 1,
      inputValue: "",
      showForm: true,
      clientId: 'ad45d163d93a957eb9a63f2958542fc21d738f7f392d660126621e97deaf5bf5'
    },
    created: function() {
      ATSB.pubSub.$on('vote:open', this.componentOpen)
      ATSB.pubSub.$on('vote:close', this.componentClose)
    },
    watch: {
      inputValue: function(val) {
        this.setAnswer(val)
      }
    },
    methods: {
      resetForm: function() {
        for(var i in this.steps) {
          this.steps[i].answer = null
        }
        this.actualStep = 1
      },
      backToProvider: function() {
        this.componentClose()
        ATSB.pubSub.$emit('all:slides:close')
        ATSB.pubSub.$emit('branch:detail:large:open')
        ATSB.pubSub.$emit('branch:detail:large:fetch', this.branchId)
        ATSB.pubSub.$emit('branch:selected', [this.branchId])
        ATSB.pubSub.$emit('branch:compare:set', this.branchId)
        ATSB.pubSub.$emit('branch:compare:button:show')
      },
      componentClose: function() {
        this.actions.show = false
        this.resetForm()
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
      getAnswerById: function(id) {
        var step = this.getActualStep()
        var answer = step.answers.filter(function(answer) {
          return answer.id == id
        })
        return answer && answer[0] || {}
      },
      getStepById: function(id) {
        var step = this.steps.filter(function(step) {
          return step.id == id
        })
        return step && step[0]
      },
      nextStep: function() {
        var _this = this
        var actualStep = this.getActualStep()
        var actualAnswerId = this.getActualAnswer()
        if (actualAnswerId == null) { return }

        client_id = this.clientId
        branch_id = this.branchId
        step_id = actualStep.id
        answer_id = isNaN(actualAnswerId) ? null : actualAnswerId
        answerString = this.getAnswerById(this.getActualStep().answer).value
        answer_value = this.inputValue ? this.inputValue : answerString
        question_value = this.getActualStep().question

        this.sendVote({
          client_id: client_id,
          branch_id: branch_id,
          step_id: step_id,
          answer_id: answer_id,
          question_value: question_value,
          answer_value: answer_value,
        })

        var nextStep = actualStep.next_step[actualAnswerId] || actualStep.id+1
        this.getStepById(nextStep).previous_step = actualStep.id
        this.inputValue = ""
        this.actualStep = +nextStep
        this.preloadInputValue()
        this.showForm = false
        setTimeout(function() {_this.showForm = true}, 300)
      },
      preloadInputValue: function() {
        this.inputValue = ""
        var actualStep = this.getActualStep()
        if(actualStep.answers && actualStep.answers[0].type == "input") {
          this.inputValue = actualStep.answer
        }
      },
      previousStep: function() {
        var _this = this
        var actualStep = this.getActualStep()
        var previousStep = actualStep.previous_step
        if (previousStep) { this.actualStep = +previousStep }
        this.preloadInputValue()
        this.showForm = false
        setTimeout(function() {_this.showForm = true}, 300)
      },
      selectAnswer: function(id) {
        this.getStepById(this.actualStep).answer = id
        this.nextStep()
      },
      sendVote: function(vote) {
        ATSB.pubSub.$emit('vote:send', vote)
      },
      setAnswer: function() {
        var actualStep = this.getActualStep()
        if(actualStep.answers && actualStep.answers[0].type == "input") {
          this.getStepById(this.actualStep).answer = this.inputValue
        }
      },
    }
  })
}
