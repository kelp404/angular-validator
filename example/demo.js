(function() {
  var a;

  a = angular.module('app', ['validator']);

  a.config(function($validatorProvider) {
    return $validatorProvider.register('backendWatch', {
      invoke: ['watch'],
      validator: function($injector, value) {
        var $http, h;
        $http = $injector.get('$http');
        console.log(value);
        h = $http.get('example/data.json');
        return h.success(function(data) {
          return console.log(data);
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
