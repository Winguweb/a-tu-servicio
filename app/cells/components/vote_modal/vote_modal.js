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
      clientId: null,
      recaptchaSitekey: options.recaptchaSitekey
    },
    created: function() {
      var _this = this
      var NEEDS_RECAPTCHA = true
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
      isFirstStep: function() {
        return this.getActualStep().id === 1
      },
      getAnswerById: function(id) {
        var step = this.getActualStep()
        var answer = step.answers.filter(function(answer) {
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
      nextStep: function(needsRecaptcha) {
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
        this.showForm = false

        this.sendVote({
          client_id: client_id,
          branch_id: branch_id,
          step_id: step_id,
          answer_id: answer_id,
          question_value: question_value,
          answer_value: answer_value,
        }, needsRecaptcha, function success() {
          var nextStep = actualStep.next_step[actualAnswerId] || actualStep.id+1
          _this.getStepById(nextStep).previous_step = actualStep.id
          _this.inputValue = ""
          _this.actualStep = +nextStep
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
        var needsRecaptcha = this.isFirstStep()
        this.nextStep(needsRecaptcha)
      },
      sendVote: function(vote, needsRecaptcha, fnSuccess, fnFail) {
        ATSB.pubSub.$emit('vote:send', vote, needsRecaptcha, fnSuccess, fnFail)
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
