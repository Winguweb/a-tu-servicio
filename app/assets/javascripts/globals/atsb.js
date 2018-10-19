;(function(){
  var root = this
  root.$window = $(window)
  root.$document = $(document)
  root.$body = $('body')
  root.$html = $('html')

  var ATSB = root.ATSB = root.ATSB || {}
  _.extend(ATSB, {
    Components: {},
    Helpers: {},
    mobile: root.$html.hasClass('mobile'),
    Views: {},
    Routers: {},
    Models: {},
    Indexes: {},
  })

  // Send token on every ajax call that is not a GET
  ATSB.CSRFtoken = $('meta[name="csrf-token"]').attr('content')
  if( typeof ATSB.CSRFtoken !== 'string' || !ATSB.CSRFtoken.length ) {
    ATSB.CSRFtoken = null
  } else {
    axios.defaults.headers.post['X-CSRF-Token'] = ATSB.CSRFtoken
  }
})();
