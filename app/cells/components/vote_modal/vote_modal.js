ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      actions: {show: false},
      actualStepId: 1,
      branchId: null,
      clientId: null,
      inputValue: "",
      inputValueSizeLimit: 200,
      recaptchaSitekey: options.recaptchaSitekey,
      showForm: true,
      steps: options.form.steps,
      type: "",
      percentage: 100
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
        // I move this line here in order to fetch the information despite the fact
        // if the visitor did not end the vote process and at least started it.
        if( this.partiallyAnswered() ){
          ATSB.pubSub.$emit('branch:detail:large:fetch', this.branchId)
        }
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
      getQuestion: function(step) {
        var actualStep = this.getActualStep()
        var question = actualStep.question
        if( _.isArray(question) ){
          var depends_on = actualStep.depends_on
          var depends_on_answer_id = this.getStepById(depends_on).answer

          question = _(question).find(function(q){
            return _(q.depends_on_id).contains(depends_on_answer_id)
          }).label
        }

        this.type = actualStep.type
        return question
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
        console.log(this.steps)
        var options = options || {}
        var needsRecaptcha = this.isFirstStep()
        var actualStep = this.getActualStep()
        var actualAnswerId = this.getActualAnswer()
        if(this.type == 'urgency'){
          this.actualStepId = this.actualStepId + 1
          return
        }
        if (actualAnswerId == null) { return }

        var client_id = this.clientId
        var branch_id = this.branchId
        var step_id = actualStep.id
        var answer_id = actualAnswerId
        var answer_data = this.getAnswerById(actualAnswerId).data
            answer_data.value = this.inputValue || answer_data.value
        var question_value = this.getQuestion()
        this.loopTo = options.loopTo
        this.percentage = this.percentage - 7.69
        if (this.shouldSaveVote()) {
          console.log(actualStep)
          this.sendVote({
            client_id: client_id,
            branch_id: branch_id,
            step_id: step_id,
            answer_id: answer_id,
            question_value: question_value,
            answer_data: answer_data,
            // question_type: !!actualStep.question_type && actualStep.question_type,
            question_subtype: !!actualStep.question_subtype && actualStep.question_subtype,
            multi_response: this.isMultiResponse(),
          }, needsRecaptcha, this.sendVoteSuccess, this.sendVoteFail)
          return;
        }
        this.sendVoteSuccess()
      },
      partiallyAnswered: function() {
        return _(this.steps).some(function(step){ return !_.isNull(step.answer) })
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
        if (previousStep) { IdId = +previousStep }
        this.preloadInputValue()
        this.showForm = false
        setTimeout(function() {_this.showForm = true}, 300)
      },
      sendVoteFail: function() {
        var _this = this
        alert('error en recaptcha')
        setTimeout(function() {_this.showForm = true}, 300)
      },
      sendVoteSuccess: function() {
        var _this = this
        var actualStep = this.getActualStep()
        var actualAnswerId = this.getActualAnswer()
        var nextStep = this.loopTo || actualStep.next_step[actualAnswerId] || actualStep.id+1
        this.loopTo = null
        this.getStepById(nextStep).previous_step = actualStep.id
        this.inputValue = ""
        this.actualStepId = +nextStep
        this.preloadInputValue()
        setTimeout(function() {_this.showForm = true}, 300)
      },
      shouldSaveVote: function() {
        var actualAnswerId = this.getActualAnswer()
        var actualAnswer = this.getAnswerById(actualAnswerId)
        return !!actualAnswer.should_save
      },
      selectAnswer: function(id) {
        this.getStepById(this.actualStepId).answer = id
        var actualAnswer = this.getAnswerById(id)
        if (actualAnswer.auto_submit == false) { return }
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
