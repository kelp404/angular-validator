(function() {
  var a, validator;

  a = angular.module('validator.directive', []);

  validator = function($injector) {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attrs) {
        var $parse, $validator, model, validate;
        $validator = $injector.get('$validator');
        $parse = $injector.get('$parse');
        model = $parse(attrs.ngModel);
        validate = function(rule, isFromWatch) {
          model.assign(scope, rule.filter(model(scope)));
          return rule.validator(model(scope), scope, element, attrs, isFromWatch);
        };
        return scope.$watch(attrs.ngModel, function(newValue, oldValue) {
          var match, name, regex, rule, ruleNames, _i, _len;
          if (newValue === oldValue) {
            return;
          }
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
              rule = $validator.getRule(name.trim());
              if (rule) {
                validate(rule, true);
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
  var $, a,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $ = angular.element;

  a = angular.module('validator.provider', []);

  a.provider('$validator', function() {
    var init;
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
    this.convertRule = function(object) {
      var errorMessage, func, regex, result, successFunc;
      if (object == null) {
        object = {};
      }
      /*
      Convert the rule object.
      */

      result = {
        invoke: object.invoke,
        filter: object.filter,
        validator: object.validator,
        error: object.error,
        success: object.success
      };
      if (result.invoke == null) {
        result.invoke = [];
      }
      if (result.filter == null) {
        result.filter = function(input) {
          return input;
        };
      }
      if (result.validator == null) {
        result.validator = function() {
          return true;
        };
      }
      if (result.error == null) {
        result.error = '';
      }
      if (result.error.constructor === String) {
        errorMessage = result.error;
        result.error = function(element, attrs) {
          var index, parent, _i, _results;
          parent = $(element).parent();
          _results = [];
          for (index = _i = 1; _i <= 3; index = ++_i) {
            if (parent.hasClass('form-group')) {
              $(element).parent().append("<label class='control-label error'>" + errorMessage + "</label>");
              parent.addClass('has-error');
              break;
            }
            _results.push(parent = parent.parent());
          }
          return _results;
        };
      }
      successFunc = function(element, attrs) {
        var index, label, parent, _i, _j, _len, _ref, _results;
        parent = $(element).parent();
        _results = [];
        for (index = _i = 1; _i <= 3; index = ++_i) {
          _ref = parent.find('label');
          for (_j = 0, _len = _ref.length; _j < _len; _j++) {
            label = _ref[_j];
            if ($(label).hasClass('error')) {
              label.remove();
              break;
            }
          }
          if (parent.hasClass('has-error')) {
            parent.removeClass('has-error');
            break;
          }
          _results.push(parent = parent.parent());
        }
        return _results;
      };
      if (result.success && typeof result.success === 'function') {
        func = result.success;
        result.success = function(element, attrs) {
          func(element, attrs);
          return successFunc(element, attrs);
        };
      } else {
        result.success = successFunc;
      }
      if (result.validator.constructor === RegExp) {
        regex = result.validator;
        result.validator = function(value, scope, element, attrs, isFromWatch) {
          if (isFromWatch == null) {
            isFromWatch = false;
          }
          if (regex.test(value)) {
            return result.success(element, attrs);
          } else {
            if (isFromWatch && __indexOf.call(result.invoke, 'watch') >= 0) {
              return result.error(element, attrs);
            }
          }
        };
      }
      return result;
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
          validator: RegExp() or function(value, element, attrs)
          error: string or function(element, attrs)
          success: function(element, attrs)
      */

      return this.rules[name] = this.convertRule(object);
    };
    this.getRule = function(name) {
      if (this.rules[name]) {
        return this.rules[name];
      } else {
        return null;
      }
    };
    this.validate = function(scope) {};
    this.get = function($injector) {
      init.all();
      return {
        rules: this.rules,
        getRule: this.getRule,
        validate: this.validate
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
          invoke: ['watch'],
          validator: RegExp("^.+$"),
          error: 'This field is required.'
        });
      },
      trim: function() {
        return $validatorProvider.register('trim', {
          filter: function(input) {
            return input.trim();
          }
        });
      }
    };
    return rules.all();
  };

  config.$inject = ['$validatorProvider'];

  a.config(config);

}).call(this);
