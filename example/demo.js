(function() {
  var a;

  a = angular.module('app', ['validator']);

  a.controller('HomeController', function($scope) {
    return $scope.name = 'name';
  });

}).call(this);
