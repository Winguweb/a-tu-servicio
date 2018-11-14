ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
      showStatuses: {},
      barColors: {
        users_types: "#3fa6c9",
        waiting_times: {
          1: "#FF3E25",
          2: "#ff9425",
          3: "#FFC649",
          4: "#c7d83d",
          5: "#92c461"
        },
        explanations: {
          bad: "#ff9425",
          good: "#c7d83d",
        }
      },
      labels: {
        1: {
          1: 'Contributivo', 2: 'Subsidiado', 3: 'No asegurado', 4: 'Particular'
        },
        2: {
          1: "Medicina General",
          2: "Odontología General",
          3: "Medicina Interna",
          4: "Enfermería",
          5: "Pediatría",
          6: "Ginecología",
          7: "Obstetricia",
          8: "Cirugía General",
          9: "Ortopedia",
          10: "Oftalmología",
          11: "Psiquiatría",
          12: "Gastroenterología",
          13: "Radiología",
          14: "Urgencias (Triage 2)",
          15: "Toma de muestras en laboratorio"
        },
        5: {
          1: 'Malo', 2: 'Aceptable', 3: 'Bueno'
        },
        7: {
          1: 'Malo', 2: 'Muy malo', 3: 'Aceptable', 4: 'Bueno', 5: 'Muy bueno'
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
          3: "Personal de enfermería",
          4: "Médico(a)",
          5: "Médico(a) especialista",
          6: "Odontología",
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
          1: 'Malo', 2: 'Muy malo', 3: 'Aceptable', 4: 'Bueno', 5: 'Muy bueno'
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
      componentClose: function() {
        this.actions.show = false
      },
      componentOpen: function(id) {
        this.actions.show = true
      },
      branchData: function(branch) {
        this.branch = branch
      },
      showMoreDetails: function(name) {
        if (this.showStatuses[name] === undefined) {
          this.$set(this.showStatuses, name, false)
        }
        this.showStatuses[name] = !this.showStatuses[name]
      }
    }
  })
}
