(function() {
  var a, config;

  a = angular.module('validator.rules', ['validator']);

  config = function($validatorProvider) {
    $validatorProvider.register('required', {
      filter: function(input) {
        if (input == null) {
          input = '';
        }
        if (input.length > 5) {
          return false;
        }
        return input;
      },
      invoke: 'watch',
      validator: /^.+$/,
      error: 'This field is required.'
    });
    $validatorProvider.register('number', {
      invoke: 'watch',
      validator: /^[-+]?[0-9]*[\.]?[0-9]*$/,
      error: 'This field should be number.'
    });
    return $validatorProvider.register('email', {
      invoke: 'blur',
      validator: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
      error: 'This field should be email.'
    });
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
