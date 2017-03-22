var _cmoncur$local_history$Native = function() {
  function get(key, stuff, persistent = false) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      var raw   = persistent
                    ? localStorage.getItem(key)
                    : sessionStorage.getItem(key)
        , stuff = raw ? JSON.parse(raw) : stuff;
      callback(_elm_lang$core$Native_Scheduler.succeed(stuff));
    });
  }

  function push(key, stuff, persistent = false) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      persistent
        ? localStorage.setItem(key, JSON.stringify(stuff))
        : sessionStorage.setItem(key, JSON.stringify(stuff));
      callback(_elm_lang$core$Native_Scheduler.succeed(key));
    });
  }

  function remove(key, persistent = false) {
    return _elm_lang$core$Native_Scheduler
    .nativeBinding(function(callback) {
      persistent
        ? localStorage.removeItem(key)
        : sessionStorage.removeItem(key);
      callback(_elm_lang$core$Native_Scheduler.succeed(key));
    });
  }

  return {
    get    : F3(get),
    push   : F3(push),
    remove : F2(remove)
  }
}();
