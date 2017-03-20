var _cmoncur$local_history$Native = function() {
  function get(key, stuff) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      var raw   = sessionStorage.getItem(key),
          stuff = raw ? JSON.parse(raw) : stuff;
      callback(_elm_lang$core$Native_Scheduler.succeed(stuff));
    });
  }

  function push(key, stuff) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      sessionStorage.setItem(key, JSON.stringify(stuff));
      callback(_elm_lang$core$Native_Scheduler.succeed(key));
    });
  }

  function remove(key) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      sessionStorage.removeItem(key);
      callback(_elm_lang$core$Native_Scheduler.succeed(key));
    });
  }

  return {
    get    : F2(get),
    push   : F2(push),
    remove : remove
  }
}();
