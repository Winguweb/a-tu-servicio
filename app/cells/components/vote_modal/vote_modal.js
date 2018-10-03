ATSB.Components['components/vote-modal'] = function(options) {
  new Vue({
    el: '.vote-modal-cell',
    data: {
      branchId: 1,
      actions: {show: false},
      steps: [
        {
          question: "¿Qué tipo de usuario eres?",
          answers: [
            {
              id: 1, text: "No asegurado"
            },
            {
              id: 2, text: "Subsidiado"
            },
            {
              id: 3, text: "Contributivo"
            },
            {
              id: 4, text: "Particular"
            },
          ],
          answer: null
        },
        {
          question: "Selecciona el servicio para el cual solicitaste la cita?",
          answers: [
            {
              id: 1, text: "Pediatría"
            },
            {
              id: 2, text: "Medicina Interna"
            },
            {
              id: 3, text: "Odontología"
            },
            {
              id: 4, text: "Medicina General"
            },
            {
              id: 5, text: "Ginecología"
            },
            {
              id: 6, text: "Obstetricia"
            },
            {
              id: 7, text: "Cirujía General"
            },
            {
              id: 8, text: "Laboratorio"
            },
            {
              id: 9, text: "Radiología"
            },

          ],
          answer: null
        }
      ],
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
