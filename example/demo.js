(function() {
  var a;

  a = angular.module('app', ['validator']);

  a.controller('DemoController', function($scope) {
    return $scope.formWatch = {
      required: ''
    };
  });

}).call(this);
