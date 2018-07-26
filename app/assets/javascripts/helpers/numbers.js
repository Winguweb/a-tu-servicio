/**
* Url Helper by @mjlescano
* Helper to manipulate or work with the url
*/
;(function(){
  ATSB.Helpers.numbers = {
    toPercentage: function(value) {
      return value * 10000 / 100
    },
    toNOfTen: function(value) {
      return Math.max(0,Math.min(10, Math.round(value*100/10)))
    },
    toNOfTenReverse: function(value) {
      return Math.max(0,Math.min(10, 10-Math.round(value*100/10)))
    }
  }
})()
