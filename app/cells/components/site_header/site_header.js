ATSB.Components['components/site-header'] = function(options) {
  new Vue({
    el: '.site-header-cell',
    data: {},
    methods: {
      menuClicked: function() {
        ATSB.pubSub.$emit('branch:list:large:open')
      }
    }
  })
}
