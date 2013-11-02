(function() {
  var a, validator;

  a = angular.module('validator.directive', []);

  validator = function($injector) {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attrs) {
        var $parse, $validator, model, validat;
        $validator = $injector.get('$validator');
        $parse = $injector.get('$parse');
        model = $parse(attrs.ngModel);
        validat = function(ruleName) {
          var rule;
          rule = $validator.rules[ruleName];
          if (!rule) {
            return true;
          }
          if (rule.filter) {
            model.assign(scope, rule.filter(model(scope)));
          }
          return true;
        };
        return scope.$watch(attrs.ngModel, function() {
          var match, name, regex, ruleNames, _i, _len;
          match = attrs.validator.match(RegExp('^/(.*)/$'));
          if (match) {
            regex = RegExp(match[1]);
            return;
          }
          match = attrs.validator.match(RegExp('^\\[(.*)\\]$'));
          if (match) {
            ruleNames = match[1].split(',');
            for (_i = 0, _len = ruleNames.length; _i < _len; _i++) {
              name = ruleNames[_i];
              name = name.trim();
              if (!validat(name)) {
                break;
              }
            }
          }
        });
      }
    };
  };

  validator.$inject = ['$injector'];

  a.directive('validator', validator);

}).call(this);

(function() {
  angular.module('validator', ['validator.provider', 'validator.directive', 'validator.rules']);

}).call(this);

(function() {
  var a;

  a = angular.module('validator.provider', []);

  a.provider('$validator', function() {
    var init,
      _this = this;
    this.rules = {};
    init = {
      all: function() {
        var x;
        for (x in this) {
          if (x !== 'all') {
            this[x]();
          }
        }
      }
    };
    this.register = function(name, object) {
      if (object == null) {
        object = {};
      }
      /*
      Register the rules.
      @params name: The rule name.
      @params object:
          invoke: ['watch', 'blur'] or undefined(validator by yourself)
          filter: function(input)
          validator: RegExp() or function(scope, element, attrs, value)
          error: string or function(scope, element, attrs)
          success: function(scope, element, attrs)
      */

      object.filter = object.filter || null;
      return _this.rules[name] = object;
    };
    this.validator = function(ruleName) {
      /*
      Validator the input value.
      */

    };
    this.get = function($injector) {
      init.all();
      return {
        rules: this.rules
      };
    };
    this.get.$inject = ['$injector'];
    return this.$get = this.get;
  });

}).call(this);

(function() {
  var a, config;

  a = angular.module('validator.rules', ['validator.provider']);

  config = function($validatorProvider) {
    var rules;
    rules = {
      all: function() {
        var x;
        for (x in this) {
          if (x !== 'all') {
            this[x]();
          }
        }
      },
      required: function() {
        return $validatorProvider.register('required', {
          filter: function(input) {
            return input.toLowerCase();
          }
        });
      }
    };
    return rules.all();
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
