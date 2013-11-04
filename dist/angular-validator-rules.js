(function() {
  var a, config;

  a = angular.module('validator.rules', ['validator']);

  config = function($validatorProvider) {
    return $validatorProvider.register('required', {
      invoke: 'watch',
      validator: RegExp("^.+$"),
      error: 'This field is required.'
    });
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
