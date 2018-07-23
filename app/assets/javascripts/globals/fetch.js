;(function(){
  ATSB.apiFetch = new Vue({
    created: function() {
      ATSB.pubSub.$on('fetch:branch:search', this.branchAll)
      ATSB.pubSub.$on('fetch:branch:id', this.branchId)
    },
    methods: {
      branchAll: function(query, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        axios.get("/api/v1/branches?q=" + query).then(cb).catch(err)
      },
      branchId: function(id, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        axios.get("/api/v1/branches/" + id).then(cb).catch(err)
      },
    }
  })
})();
