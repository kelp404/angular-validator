(function() {
  var a, config;

  a = angular.module('validator.rules', ['validator']);

  config = function($validatorProvider) {
    $validatorProvider.register('required', {
      invoke: ['watch'],
      validator: RegExp("^.+$"),
      error: 'This field is required.'
    });
    return $validatorProvider.register('trim', {
      filter: function(input) {
        return input.trim();
      }
    });
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
