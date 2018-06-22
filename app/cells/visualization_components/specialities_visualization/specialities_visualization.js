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
      publicPercentage.push(publicSpecialities[index][1])
      privatePercentage.push(privateSpecialities[index][1])
    })
    var mainLabels = totalSpecialities.map(function(item){return item[0].toLowerCase()})

    this.chartData = {
      labels: mainLabels,
      datasets: [{
          data: publicPercentage,
          label: 'Público',
          backgroundColor: "#3fa6c922",
          borderColor: "#3fa6c9",
          pointBorderColor: "#FFFFFF",
          pointBackgroundColor: "#3fa6c9",
      }, {
          data: privatePercentage,
          label: 'Privado',
          backgroundColor: "#FF3E2522",
          borderColor: "#FF3E25",
          pointBorderColor: "#FFFFFF",
          pointBackgroundColor: "#FF3E2522",
      }]
    }
    this.chartOptions = {

    };
  },
  initChart: function() {
    var ctx = this.$el.find("#myChart")
    var myRadarChart = new Chart(ctx, {
      type: 'radar',
      data: this.chartData,
      options: this.chartOptions
    });


  },
})
