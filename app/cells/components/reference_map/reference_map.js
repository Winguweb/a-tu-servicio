ATSB.Components['components/reference-map'] = function(options) {
  new Vue({
    el: '.reference-map-cell',
    data: {
      branches: options.branches,
      center: options.defaults.center,
      style: options.defaults.style,
      zoom: options.defaults.zoom,
      token: options.token,
      selectedBranch: []
    },
    created: function() {
      ATSB.pubSub.$on('branch:selected', this.setSelectedBranch)
    },
    mounted: function() {
      this.setAccessToken()
      this.createMap()
      this.centerMap()
      this.showReferences()
    },
    methods: {
      centerMap: function() {
        this.map.setView([this.center.lat, this.center.lng], this.zoom)
      },
      createMap: function() {
        this.map = L.mapbox.map('map_container', this.style)
        this.baseGeometryFeature = new L.FeatureGroup()
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
          new L.Marker(branch.coordinates, {
            icon: new L.divIcon({
              html: '<div class="reference-map--marker"><i></i><p>' + branch.name + '</p></div><!-- Icon made by [https://www.facebook.com/theflaticon] from www.flaticon.com -->',
              iconAnchor: [8, 15],
              iconSize: [15, 15],
            })
          }).addTo(this.baseGeometryFeature)
        }.bind(this))
      },
      getSelectedBranch: function(branch) {
        return this.selectedBranch.indexOf(branch.id) > -1
      },
      setSelectedBranch: function(ids) {
        this.selectedBranch = ids
        this.clearReferences()
        this.showReferences()
      }
    }
  })
}
