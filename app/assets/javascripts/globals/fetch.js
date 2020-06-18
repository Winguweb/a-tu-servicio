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
      voteSend: function(vote, needsReacaptcha, success, fail) {
        var payload = {vote: vote}
        if (needsReacaptcha) {
          grecaptcha.ready(function() {
            console.log(ATSB, token, payload)
            grecaptcha.execute(ATSB.recaptchaSitekey, {action: 'action_name'})
            .then(function(token) {
              payload.token = token
              axios.post("/api/v1/surveys", payload).then(success).catch(fail)
            })
          })
        } else {
          axios.post("/api/v1/surveys", payload).then(success).catch(fail)
        }
      },
    }
  })
})();
