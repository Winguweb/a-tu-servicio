;(function(){
  ATSB.pubSub = new Vue()
  ATSB.pubSub._$emit = ATSB.pubSub.$emit
  ATSB.pubSub.$emit = function() {
      var params = typeof arguments[0] == 'string' ? [Array.prototype.slice.call(arguments)] : Array.prototype.slice.call(arguments).shift()
      for (var e in params) {
        this._$emit.apply(this, params[e])
      }
  }
})();
