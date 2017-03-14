var _cmoncur$local_history$Native = function() {
  function yeah(stuff) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      sessionStorage.setItem("yeah", stuff)
      callback(_elm_lang$core$Native_Scheduler.succeed("yeah"));
    });
  }

  return {
    yeah: yeah
  }
}();
