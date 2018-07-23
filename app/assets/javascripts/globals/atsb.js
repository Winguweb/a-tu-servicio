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
    pubSub: new Vue(),
    Views: {},
    Routers: {},
    Models: {},
  })

  // Send token on every ajax call that is not a GET
  ATSB.CSRFtoken = $('meta[name="csrf-token"]').attr('content')
  if( typeof ATSB.CSRFtoken !== 'string' || !ATSB.CSRFtoken.length ) {
    ATSB.CSRFtoken = null
  } else {
    $.ajaxPrefilter(function(options, originalOptions, jqXHR) {
      if( ATSB.Helpers.url.isSameDomain(options.url) ) {
        jqXHR.setRequestHeader('X-CSRF-Token', ATSB.CSRFtoken)
      }

      jqXHR.promise().fail(function(xhr){
        var url = xhr.responseJSON.url
        if( xhr.status === 302 && !_.isEmpty(url)){
          window.location.href = url
        }
      })
    })
  }
})();
