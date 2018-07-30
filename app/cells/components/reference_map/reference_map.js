ATSB.Components['components/reference-map'] = function(options) {
  new Vue({
    el: '.reference-map-cell',
    data: {
      branches: options.branches,
      centered: true,
      style: options.defaults.style,
      zoom: options.defaults.zoom,
      token: options.token,
      selectedBranch: []
    },
    created: function() {
      ATSB.pubSub.$on('branch:selected', this.setSelectedBranch)
      ATSB.pubSub.$on('map:centered', this.setCentered)
    },
    mounted: function() {
      this.setAccessToken()
      this.createMap()
      this.showReferences()
      this.centerMap()
      this.addMapEvents()
    },
    methods: {
      centerMap: function() {
        var targetLatLng = this.baseGeometryFeature.getBounds().getCenter()
        var padding = this.centered ? [0, 0] : [100, 100]
        this.map.fitBounds(this.baseGeometryFeature.getBounds(),{animate: false, padding: padding});
        var zoom = this.map.getZoom()
        var targetPoint = this.map.project(targetLatLng, zoom)
        if (!this.centered) targetPoint = targetPoint.add([791 / 2, 0])
        var targetLatLng = this.map.unproject(targetPoint, zoom)
        this.map.setView(targetLatLng, zoom, {animate: false})
      },
      createMap: function() {
        this.map = L.mapbox.map('map_container', this.style)
        this.baseGeometryFeature = new L.MarkerClusterGroup({
          spiderfyOnMaxZoom: true,
          zoomToBoundsOnClick: true,
          animateAddingMarkers: false,
          animate: false,
          maxClusterRadius: 45,
          showCoverageOnHover: false,
          spiderLegPolylineOptions: {opacity: 0},
          iconCreateFunction: function(cluster) {
            return L.divIcon({ html: '<div class="reference-map--cluster"><span>' + cluster.getChildCount() + '</span></div>' });
          }

        })

        this.map.addLayer(this.baseGeometryFeature)
      },
      setAccessToken: function() {
        L.mapbox.accessToken = this.token
      },
      clearReferences: function() {
        this.baseGeometryFeature.clearLayers()
      },
      showReferences: function() {
        var branches = this.branches
        var filtered = this.selectedBranch.length ? branches.filter(this.getSelectedBranch) : branches
        filtered.forEach(function(branch) {
          var marker = new L.Marker(branch.coordinates, {
            icon: new L.divIcon({
              html: '<div class="reference-map--marker"><i></i><p>' + branch.name + '</p></div><!-- Icon made by [https://www.facebook.com/theflaticon] from www.flaticon.com -->',
              iconAnchor: [8, 15],
              iconSize: [15, 15],
            }),
            id: branch.id
          })
          this.addEvents(marker)
          this.baseGeometryFeature.addLayer(marker)
        }.bind(this))
      },
      getSelectedBranch: function(branch) {
        return this.selectedBranch.indexOf(branch.id) > -1
      },
      setSelectedBranch: function(ids) {
        this.selectedBranch = ids
        this.clearReferences()
        this.showReferences()
        this.centerMap()
      },
      addEvents: function(marker) {
        marker.on('click', function (evt) {
          var id = evt.target.options.id
          ATSB.pubSub.$emit('all:slides:close')
          ATSB.pubSub.$emit('branch:detail:large:open')
          ATSB.pubSub.$emit('branch:detail:large:fetch', id)
          ATSB.pubSub.$emit('branch:selected', [id])
          ATSB.pubSub.$emit('branch:compare:set', id)
          ATSB.pubSub.$emit('branch:compare:button:show')
        })
      },
      addMapEvents: function() {
        this.map.on('click', function(evt) {
          ATSB.pubSub.$emit('all:slides:close')
        })
      },
      setCentered: function(value) {
        this.centered = value
      }
    }
  })
}
