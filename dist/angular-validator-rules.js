(function() {
  var a, config;

  a = angular.module('validator.rules', ['validator']);

  config = function($validatorProvider) {
    $validatorProvider.register('required', {
      invoke: 'watch',
      validator: RegExp("^.+$"),
      error: 'This field is required.'
    });
    return $validatorProvider.register('number', {
      invoke: 'watch',
      validator: RegExp("^[-+]?[0-9]*[\.]?[0-9]*$"),
      error: 'This field should be number.'
    });
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
