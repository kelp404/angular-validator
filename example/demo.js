(function() {
  var a,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  a = angular.module('app', ['validator', 'validator.rules']);

  a.config(function($validatorProvider) {
    return $validatorProvider.register('backendWatch', {
      invoke: ['watch'],
      validator: function(value, element, attrs, $injector) {
        var $http, h;
        $http = $injector.get('$http');
        h = $http.get('example/data.json');
        return h.then(function(data) {
          var x;
          if (data && data.status < 400 && data.data) {
            if (__indexOf.call((function() {
              var _i, _len, _ref, _results;
              _ref = data.data;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                x = _ref[_i];
                _results.push(x.name);
              }
              return _results;
            })(), value) >= 0) {
              return false;
            }
            return true;
          } else {
            return false;
          }
        });
      },
      error: "do not use 'Kelp' or 'x'"
    });
  });

  a.controller('DemoController', function($scope) {
    return $scope.formWatch = {
      required: '',
      http: ''
    };
  });

}).call(this);
