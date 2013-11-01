(function() {
  var a;

  a = angular.module('validator.directive', []);

  a.directive('validator', function() {});

}).call(this);

(function() {
  angular.module('validator', ['validator.provider', 'validator.directive']);

}).call(this);

(function() {
  var a;

  a = angular.module('validator.provider', []);

}).call(this);
