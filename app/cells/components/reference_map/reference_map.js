ATSB.Components['components/reference-map'] = Backbone.View.extend({
  initialize: function(options) {
    _.bindAll(
      this,
      'createMap',
    )

    this.setAccessToken(options.token)
    this.setMapContainer('#map-container')
    this.loadDefaults(options)
    this.createMap()
    this.centerMap(this.center)
    this.showReference(this.features)
  },
  centerMap: function(center) {
    this.map.setView([center.lat, center.lng], this.zoom)
  },
  createMap: function() {
    this.map = L.mapbox.map(this.mapContainer[0], this.style)
    this.baseGeometryFeature = new L.FeatureGroup()
    this.map.addLayer(this.baseGeometryFeature)
  },
  loadDefaults: function(options) {
    this.center = options.defaults.center
    this.features = options.features
    this.style = options.defaults.style
    this.zoom = options.defaults.zoom
  },
  setAccessToken: function(token) {
    L.mapbox.accessToken = token
  },
  setMapContainer: function(selector) {
    this.mapContainer = this.$el.find(selector)
  },
  showReference: function(markers) {
    markers.forEach(function(marker) {
      new L.Marker(marker.coordinates, {
        icon: new L.divIcon({
          html: '<div class="reference-map--marker"><i></i><p>' + marker.name + '</p></div><!-- Icon made by [author link] from www.flaticon.com -->',
          iconAnchor: [8, 15],
          iconSize: [15, 15],
        })
      }).addTo(this.baseGeometryFeature)
    }.bind(this))
  },
})
