ATSB.Components['components/branch-full-detail'] = function(options) {
  new Vue({
    el: '.branch-full-detail-cell',
    data: {
      branch: {loaded: false},
      actions: {show: false},
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
          1: 'Pediatría',
          2: 'Medicina General',
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
          7: 'No había disponibilidad de camilla de observación ni sillones reclinables'
        },
        10: {
          1: 'El tiempo de espera hasta que me evaluaron fue corto',
          2: 'La sala de espera se encontraba en condiciones óptimas',
          3: 'El tiempo entre la evaluación previa y la atención fue corto',
          4: 'La atención médica fue resolutiva',
          5: 'El personal médico y/o de enfermería prestó un servicio que cumplió o superó mis espectativas'
        }
      }
    },
    created: function() {
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
        branch.details = {
          "1": {
            "answers": {
              "1": { "counter": 0, "percentage": 10 },
              "2": { "counter": 0, "percentage": 10 },
              "3": { "counter": 0, "percentage": 20 },
              "4": { "counter": 0, "percentage": 15 }
            }
          },
          "2": {
            "1": {
              "counter": 0,
              "percentage": 0,
              "detail": {
                "5": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 60 },
                    "3": { "counter": 0, "percentage": 30 }
                  }
                },
                "7": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 50 }
                  }
                },
                "9": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 10 },
                    "6": { "counter": 0, "percentage": 10 },
                    "7": { "counter": 0, "percentage": 30 }
                  }
                },
                "10": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 10 },
                    "5": { "counter": 0, "percentage": 10 }
                  }
                }
              }
            },
            "2": {
              "counter": 0,
              "percentage": 0,
              "detail": {
                "5": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 20 },
                    "2": { "counter": 0, "percentage": 75 },
                    "3": { "counter": 0, "percentage": 5 }
                  }
                },
                "7": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 50 }
                  }
                },
                "9": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 10 },
                    "5": { "counter": 0, "percentage": 10 },
                    "6": { "counter": 0, "percentage": 10 },
                    "7": { "counter": 0, "percentage": 40 }
                  }
                },
                "10": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 10 },
                  }
                }
              }
            }
          },
          "11": {
            "1": {
              "counter": 0,
              "percentage": 0,
              "detail": {
                "12": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 50 }
                  }
                },
                "13": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 10 },
                    "5": { "counter": 0, "percentage": 10 },
                    "6": { "counter": 0, "percentage": 10 },
                    "7": { "counter": 0, "percentage": 40 }
                  }
                },
                "14": {
                  "answers": {
                    "1": { "counter": 0, "percentage": 10 },
                    "2": { "counter": 0, "percentage": 10 },
                    "3": { "counter": 0, "percentage": 10 },
                    "4": { "counter": 0, "percentage": 20 },
                    "5": { "counter": 0, "percentage": 10 },
                    "6": { "counter": 0, "percentage": 10 },
                    "7": { "counter": 0, "percentage": 30 }
                  }
                }
              }
            }
          }
        }
      },
    }
  })
}
