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
      console.log('here!')
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
        /* This prevents errors for algolia and pg data differences */
        if (this.baseGeometryFeature.getLayers().length == 0) { return }
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
          var size = branch.featured ? {width: 35, height: 35} : {width: 25, height: 25}
          var marker = new L.Marker(branch.coordinates, {
            icon: new L.divIcon({
              html: '<div class="reference-map--marker ' + featured + '"><i></i></div>',
              iconAnchor: [size.width, size.height],
              iconSize: [size.width, size.height],
            }),
            id: branch.id,
            slug: branch.slug
          })
          this.addEvents(marker)
          this.baseGeometryFeature.addLayer(marker)
        }.bind(this))
      },
      getSelectedBranch: function(branch) {
        var selectedBranchesSlugs = this.selectedBranch
        return selectedBranchesSlugs.indexOf(branch.slug) > -1
      },
      setSelectedBranch: function(slugs) {
        this.selectedBranch = slugs
        this.clearReferences()
        this.showReferences()
        this.centerMap()
      },
      addEvents: function(marker) {
        var _this = this
        marker.on('click', function (evt) {
          var slug = evt.target.options.slug
          window.history.pushState(null, '', '/mapa-de-servicios/' + slug)
          ATSB.pubSub.$emit('all:slides:close')
          ATSB.pubSub.$emit('branch:detail:large:open')
          ATSB.pubSub.$emit('branch:detail:large:fetch', slug)
          ATSB.pubSub.$emit('branch:selected', [slug])
          ATSB.pubSub.$emit('branch:compare:set', slug)
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
