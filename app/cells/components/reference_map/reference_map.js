ATSB.Components['components/reference-map'] = function(options) {
  new Vue({
    el: '.reference-map-cell',
    data: {
      branches: options.branches,
      centered: false,
      style: options.defaults.style,
      zoom: options.defaults.zoom,
      token: options.token,
      selectedBranch: [],
      isMobile: $('body').hasClass('mobile')
    },
    created: function() {
      ATSB.pubSub.$on('branch:selected', this.setSelectedBranch)
      ATSB.pubSub.$on('map:centered', this.setCentered)
      ATSB.pubSub.$on('map:activearea', this.setMapActiveArea)
    },
    mounted: function() {
      this.setAccessToken()
      this.createMap()
      this.showReferences()
      this.centerMap()
      this.addMapEvents()
    },
    methods: {
      setMapActiveArea: function(name) {
        if (this.isMobile) return
        this.map.setActiveArea("map-active-area " + name)
      },
      centerMap: function() {
        this.map.fitBounds(this.baseGeometryFeature.getBounds(), {animate: true});
      },
      createMap: function() {
        var southWest = L.latLng(4.456638, -74.794551),
        northEast = L.latLng(4.867143, -73.370018),
        bounds = L.latLngBounds(southWest, northEast);
        var minZoom = this.isMobile ? 10 : 12

        this.map = L.mapbox.map('map_container', this.style, {maxBounds: bounds, minZoom: minZoom, zoomDelta: 0.5, zoomSnap: 0.5})
        this.setMapActiveArea('medium')
        this.baseGeometryFeature = new L.MarkerClusterGroup({
          spiderfyOnMaxZoom: true,
          zoomToBoundsOnClick: true,
          animateAddingMarkers: false,
          animate: false,
          maxClusterRadius: 30,
          showCoverageOnHover: false,
          spiderLegPolylineOptions: {opacity: 0},
          iconCreateFunction: function(cluster) {
            return L.divIcon({ html: '<div class="reference-map--cluster"><span>' + cluster.getChildCount() + '</span></div>' });
          }
        })
        this.map.addLayer(this.baseGeometryFeature)
        window.map = this.map
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
          var featured = branch.featured ? 'marker-featured' : ''
          var marker = new L.Marker(branch.coordinates, {
            icon: new L.divIcon({
              html: '<div class="reference-map--marker ' + featured + '"><i></i></div>',
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
        var _this = this
        marker.on('click', function (evt) {
          var id = evt.target.options.id
          ATSB.pubSub.$emit('all:slides:close')
          ATSB.pubSub.$emit('branch:detail:large:open')
          ATSB.pubSub.$emit('branch:detail:large:fetch', id)
          ATSB.pubSub.$emit('branch:selected', [id])
          ATSB.pubSub.$emit('branch:compare:set', id)
          ATSB.pubSub.$emit('branch:compare:button:show')
          ATSB.pubSub.$emit('branch:hover:close')
        })
        marker.on('mouseover', function (evt) {
          var branch = _this.getBranchById(evt.target.options.id)
          var info = {
            branch: branch,
            position: {left: evt.containerPoint.x, top: evt.containerPoint.y}
          }
          ATSB.pubSub.$emit('branch:hover:open', info)
        })
        marker.on('mouseout', function (evt) {
          ATSB.pubSub.$emit('branch:hover:close')
        })
      },
      addMapEvents: function() {
        var _this = this
        this.map.on('click', function(evt) {
          if (_this.selectedBranch.length == 1) {
            ATSB.pubSub.$emit('all:slides:close')
            ATSB.pubSub.$emit('branch:list:large:open')
            ATSB.pubSub.$emit('branch:compare:button:hide')
            ATSB.pubSub.$emit('header:action:set', 'close')
          }
        })
      },
      getBranchById: function(id) {
        branch = this.branches.filter(function(branch) {
          return branch.id == id
        })
        return branch && branch[0]
      },
      setCentered: function(value) {
        this.centered = value
      }
    }
  })
}
