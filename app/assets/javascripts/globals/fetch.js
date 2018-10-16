;(function(){
  ATSB.apiFetch = new Vue({
    created: function() {
      ATSB.pubSub.$on('fetch:branch:search', this.branchAll)
      ATSB.pubSub.$on('fetch:branch:id', this.branchId)
      ATSB.pubSub.$on('vote:send', this.voteSend)
    },
    methods: {
      branchAll: function(searchParams, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        ATSB.Indexes.branch.search(searchParams).then(cb).catch(err)
      },
      branchId: function(id, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        axios.get("/api/v1/branches/" + id).then(cb).catch(err)
      },
      voteSend: function(vote, cb, err) {
        var cb = cb || ATSB.Utils.fn
        var err = err || ATSB.Utils.out
        payload = {vote: vote}
        axios.post("/api/v1/surveys", payload).then(cb).catch(err)
      },
    }
  })
})();
