ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      showStatuses: {},
      barColors: {
        users_types: "#3FA6C9",
        waiting_times: {
          1: "#FF3E25",
          2: "#FF9425",
          3: "#FFC649",
          4: "#C7D83D",
          5: "#92C461"
        },
        explanations: {
          bad: "#FF9425",
          good: "#C7D83D",
        }
      },
      labels: {
        1: {
          1: 'No asegurado', 2: 'Subsidiado', 3: 'Contributivo', 4: 'Particular', 5: 'Prepagada', 6: 'No Sabe'
        },
        2: {
          4: "Medicina General",
          3: "Odontología General",
          2: "Medicina Interna",
          11: "Enfermería",
          1: "Pediatría",
          5: "Ginecología",
          6: "Obstetricia",
          7: "Cirugía General",
          12: "Ortopedia",
          13: "Oftalmología",
          14: "Psiquiatría",
          15: "Gastroenterología",
          9: "Radiología",
          10: "Urgencias",
          8: "Toma de muestras en laboratorio"
        },
        5: {
          1: 'Malo', 2: 'Aceptable', 3: 'Bueno'
        },
        7: {
          1: 'Muy Malo', 2: 'Malo', 3: 'Aceptable', 4: 'Bueno', 5: 'Muy Bueno'
        },
        9: {
          1: 'El tiempo de espera hasta que me evaluaron fue excesivamente largo',
          2: 'No había donde sentarse en la sala de espera',
          3: 'El tiempo entre la evaluación previa y la atención fue exesivamente largo',
          4: 'No encontré solución para mi motivo de consulta',
          5: 'El personal médico y de enfermería no prestó un servicio adecuado',
          6: 'El personal administrativo no prestó un servicio adecuado',
          7: 'No había disponibilidad de camilla de observación ni sillones reclinables',
          8: 'Otro'
        },
        10: {
          1: 'El tiempo de espera hasta que me evaluaron fue corto',
          2: 'La sala de espera se encontraba en condiciones óptimas',
          3: 'El tiempo entre la evaluación previa y la atención fue corto',
          4: 'La atención médica fue resolutiva',
          5: 'El personal médico y/o de enfermería prestó un servicio que cumplió o superó mis espectativas',
          6: 'Otro'
        },
        11: {
          1: "Personal de apoyo",
          2: "Personal administrativo",
          3: "Enfermero(a)",
          4: "Médico(a)",
          5: "Médico(a) especialista",
          7: "Odontólogo(a)",
          8: "Psicólogo(a)",
          9: "Fisioterapeuta",
          10: "Terapeuta Ocupacional",
          11: "Fonoaudiólogo(a)",
          12: "Bacteriólogo(a)",
          13: "Nutricionista"
        },
        12: {
          1: "Muy Mala", 2: "Mala", 3: "Aceptable", 4: "Buena", 5: "Muy Buena"
        },
        13: {
          1: "No se presentó amabilidad y calidéz por parte de los funcionarios",
          2: "No le demostraron interés o voluntad en ayudarlo",
          3: "No tuvo privacidad para contar su caso",
          4: "La explicación o información que le brindaron no fue confiable",
          5: "Otros"
        },
        14: {
          1: "Se presentó amabilidad y calidéz por parte de los funcionarios",
          2: "Le demostraron interés y voluntad en ayudarlo",
          3: "La privacidad para contar su caso",
          4: "La explicación o información que le brindaron fue confiable",
          5: "Otros"
        },
        15: {
          1: 'Muy Mala', 2: 'Mala', 3: 'Aceptable', 4: 'Buena', 5: 'Muy Buena'
        },
        16: {
          1: "No hubo coherencia o relación entre la atención y su necesidad",
          2: "No hay tranquilidad y comodidad del punto de atención",
          3: "No hubo respeto a la dignidad y la condición humana",
          4: "No se resolvió su necesidad",
          5: "Otros"
        },
        17: {
          1: "Hubo coherencia o relación entre la atención y su necesidad",
          2: "Hubo tranquilidad y comodidad del punto de atención",
          3: "Hubo respeto a la dignidad y condición humana",
          4: "Se resolvió su necesidad",
          5: "Otros"
        },
      }
    },
    created: function() {
      ATSB.pubSub.$on('all:slides:close', this.componentClose)
      ATSB.pubSub.$on('branch:full:detail:open', this.componentOpen)
      ATSB.pubSub.$on('branch:full:detail:close', this.componentClose)
      ATSB.pubSub.$on('branch:full:detail:data', this.branchData)
    },
    methods: {
      branchData: function(branch) {
        this.branch = branch
      },
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function(id) {
        this.actions.show = true
      },
      getColor: function(position, totalOptions){
        // I'm harcoding the totalColors amount because seems that it's
        // not necessary to calculate it each time
        var totalColors = 5 // _(this.barColors.waiting_times).size()
        if( totalOptions === totalColors ){
          return this.barColors.waiting_times[position]
        }
        var newColorPosition = Math.floor(totalColors/totalOptions * position)
        return this.barColors.waiting_times[newColorPosition]
      },
      reversedVersion: function(answers){
        var keys = _(answers).keys()
        var reversedKeys = keys.slice().reverse()
        var reversedAnswers = {}
        for(var i in reversedKeys) {
          reversedAnswers[keys[i]] = answers[reversedKeys[i]]
        }
        return reversedAnswers
      },
      showMoreDetails: function(name) {
        if (this.showStatuses[name] === undefined) {
          this.$set(this.showStatuses, name, false)
        }
        this.showStatuses[name] = !this.showStatuses[name]
      },
      totalCounter: function(answers) {
        return Object.keys(answers).reduce(function(sum, next) {
          return sum + answers[next].counter
        }, 0)
      },
      totalCounterNested: function(answers) {
        return Object.keys(answers).reduce(function(sum, next) {
          return sum + answers[next].counter
        }, 0)
      }
    }
  })
}
