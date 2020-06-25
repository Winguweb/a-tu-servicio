ATSB.Components['components/map-services'] = function(options) {
  new Vue({
    el: '.map-services-cell',
    created: function() {
      const query = window.location.pathname.split('/mapa-de-servicios')
      const slug = query[1].split('/')
      if (query && query.length > 1 && slug[1] && slug[1].length > 0) {
        this.slug = slug[1]
      }
    },
    data: {
      slug: null
    },
    mounted: function(){
      ATSB.pubSub.$on('branch:detail:large:created', this.detailReady)
      ATSB.pubSub.$on('general:info:created', this.generalInfoReady)
    },
    methods: {
      detailReady: function() {
        if (this.slug) {
          ATSB.pubSub.$emit('all:slides:close')
          ATSB.pubSub.$emit('branch:detail:large:open')
          ATSB.pubSub.$emit('branch:detail:large:fetch', this.slug)
          ATSB.pubSub.$emit('branch:selected', [this.slug])
          ATSB.pubSub.$emit('branch:compare:set', this.slug)
          ATSB.pubSub.$emit('branch:compare:button:show')
        }
      },
      generalInfoReady: function() {        
        if (!this.slug) {
          ATSB.pubSub.$emit('general:info:open')        
        }
      }
    }
  })
}
