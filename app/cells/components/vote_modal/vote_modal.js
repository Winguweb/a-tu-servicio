ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      actions: {show: false},
      actualStepId: 1,
      branchId: 1,
      clientId: null,
      inputValue: "",
      inputValueSizeLimit: 200,
      recaptchaSitekey: options.recaptchaSitekey,
      showForm: true,
      steps: options.steps,
    },
    created: function() {
      var _this = this
      ATSB.recaptchaSitekey = this.recaptchaSitekey
      ATSB.pubSub.$on('vote:open', this.componentOpen)
      ATSB.pubSub.$on('vote:close', this.componentClose)
      this.getClientId(options.client_id)
    },
    watch: {
      inputValue: function(val) {
        this.setAnswer(val)
      }
    },
    computed: {
      inputValueLength: function () {
        return this.inputValueSizeLimit - this.inputValue.length
      },
    },
    methods: {
      resetForm: function() {
        for(var i in this.steps) {
          this.steps[i].answer = null
        }
        this.actualStepId = 1
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
      clearDataBetweenLooped: function(loopStartId, loopEndId) {
        var _this = this
        var actualStep = this.getStepById(loopStartId)
        var nextSteps = actualStep.next_step
        actualStep.answer = null
        Object.keys(nextSteps).forEach(function(index) {
          var actualStepId = nextSteps[index]
          if (actualStepId == loopEndId) return
          if (_this.getStepById(actualStepId).answer == null) return
          _this.clearDataBetweenLooped(actualStepId, loopEndId)
        })
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
        actualStep = this.getActualStep().answer
        return isNaN(actualStep) ? 1 : actualStep
      },
      getActualStep: function() {
        return this.getStepById(this.actualStepId)
      },
      getActualStepAnswers: function() {
        var actualStep = this.getActualStep()
        var answers = actualStep.depends_on
          ? this.getDependentAnswer(actualStep.answers, actualStep.depends_on)
          : actualStep.answers
        return answers
      },
      getDependentAnswer: function(answers, depends_on) {
        var _this = this
        return answers.filter(function(answer) {
          return _this.getStepById(depends_on).answer == answer.depends_on_id
        })[0].answers
      },
      getAnswerById: function(id) {
        var answers = this.getActualStepAnswers()
        var answer = answers.filter(function(answer) {
          return answer.id == id
        })
        return answer && answer[0] || {}
      },
      getClientId: function(client_id) {
        this.clientId = localStorage.getItem('client_id') || client_id
        localStorage.setItem('client_id', this.clientId)
      },
      getStepById: function(id) {
        var step = this.steps.filter(function(step) {
          return step.id == id
        })
        return step && step[0]
      },
      goToLoop: function() {
        var loopStartId = this.getStepById(this.actualStepId).loop_from
        var loopEndId = this.getActualStep().next_step['1']
        this.nextStep({loopTo: loopStartId})
        this.clearDataBetweenLooped(loopStartId, loopEndId)
      },
      isFirstStep: function() {
        return this.getActualStep().id === 1
      },
      isInputComponent: function() {
        var actualStep = this.getActualStep()
        var inputs = ["input", "text", "number"]
        return actualStep.answers && inputs.indexOf(actualStep.answers[0].type) > -1
      },
      isMultiResponse: function() {
        return !!this.getStepById(this.actualStepId).multi_response
      },
      nextStep: function(options) {
        var _this = this
        var options = options || {}
        var needsRecaptcha = this.isFirstStep()
        var loopTo = options.loopTo
        var actualStep = this.getActualStep()
        var actualAnswerId = this.getActualAnswer()
        if (actualAnswerId == null) { return }

        var client_id = this.clientId
        var branch_id = this.branchId
        var step_id = actualStep.id
        var answer_id = actualAnswerId
        var answerString = this.getAnswerById(actualAnswerId).value
        var answer_value = this.inputValue ? this.inputValue : answerString
        var question_value = this.getActualStep().question

        this.showForm = false

        this.sendVote({
          client_id: client_id,
          branch_id: branch_id,
          step_id: step_id,
          answer_id: answer_id,
          question_value: question_value,
          answer_value: answer_value,
          multi_response: this.isMultiResponse(),
        }, needsRecaptcha, function success() {
          var nextStep = loopTo || actualStep.next_step[actualAnswerId] || actualStep.id+1
          _this.getStepById(nextStep).previous_step = actualStep.id
          _this.inputValue = ""
          _this.actualStepId = +nextStep
          _this.preloadInputValue()
          setTimeout(function() {_this.showForm = true}, 300)
        }, function fail() {
          alert('error en recaptcha')
          setTimeout(function() {_this.showForm = true}, 300)
        })
      },
      preloadInputValue: function() {
        this.inputValue = ""
        var actualStep = this.getActualStep()
        if(this.isInputComponent()) {
          this.inputValue = actualStep.answer || ""
        }
      },
      previousStep: function() {
        var _this = this
        var actualStep = this.getActualStep()
        var previousStep = actualStep.previous_step
        if (previousStep) { this.actualStepId = +previousStep }
        this.preloadInputValue()
        this.showForm = false
        setTimeout(function() {_this.showForm = true}, 300)
      },
      selectAnswer: function(id) {
        this.getStepById(this.actualStepId).answer = id
        var actualAnswer = this.getAnswerById(id)
        if (actualAnswer.auto_submit == false) { return }
        this.nextStep()
      },
      sendVote: function(vote, needsRecaptcha, fnSuccess, fnFail) {
        ATSB.pubSub.$emit('vote:send', vote, needsRecaptcha, fnSuccess, fnFail)
      },
      setAnswer: function() {
        var actualStep = this.getActualStep()
        if(this.isInputComponent()) {
          this.getStepById(this.actualStepId).answer = this.inputValue
        }
      },
      stepIsLooped: function() {
        return !!this.getStepById(this.actualStepId).loop_from
      },
    }
  })
}
