ATSB.Components['visualization-components/specialities-visualization'] = Backbone.View.extend({
  initialize: function(options) {
    _.bindAll(
      this,
      'initChart',
    )
    this.commonInfo = options.common_info
    this.setChart()
    this.initChart()
  },
  setChart: function() {
    var totalSpecialities = this.commonInfo.specialities_count_by_type
    var publicSpecialities = this.commonInfo.public_specialities_count_of_type
    var privateSpecialities = this.commonInfo.private_specialities_count_of_type
    var publicPercentage = []
    var privatePercentage = []
    totalSpecialities.forEach(function(item, index) {
      publicPercentage.push(-publicSpecialities[index][1])
      privatePercentage.push(privateSpecialities[index][1])
    })
    var mainLabels = totalSpecialities.map(function(item){return item[0].toLowerCase()})

    this.chartData = {
      labels: mainLabels,
      datasets: [{
          data: publicPercentage,
          label: 'Público',
          backgroundColor: "#3fa6c9bb",
          hoverBackgroundColor: "#3fa6c9",
          borderColor: "#3fa6c9",
      }, {
          data: privatePercentage,
          label: 'Privado',
          backgroundColor: "#0B2F47bb",
          hoverBackgroundColor: "#0B2F47",
          borderColor: "#0B2F47",
      }]
    }
    this.chartOptions = {
      tooltips: {
        callbacks: {label: function(tooltipItem, data) {
          var datasetIndex = tooltipItem.datasetIndex
          var label = data.datasets[datasetIndex].label
          return Math.abs(tooltipItem.yLabel) + " Sedes con esta especialidad en el sector " + label.toLowerCase();
        }}
      },
      scales: {
        xAxes: [{stacked: true, gridLines: false, display: false }],
        yAxes: [{stacked: true, scaleOverride: true,
          ticks : {callback: function(value) {return Math.abs(value)}},
        }]
      }
    }
  },
  initChart: function() {
    var ctx = this.$el.find("#speciality_chart")
    var myRadarChart = new Chart(ctx, {
      type: 'bar',
      data: this.chartData,
      options: this.chartOptions
    })
  },
})
