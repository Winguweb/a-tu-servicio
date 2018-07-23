;(function(){
  ATSB.apiFetch = new Vue({
    created: function() {
      ATSB.pubSub.$on('fetch:branch:search', this.branchAll)
    },
    methods: {
      branchAll: function(query, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        axios.get("/api/v1/branches?q=" + query).then(cb).catch(err)
      },
    }
  })
})();
