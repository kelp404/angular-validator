(function() {
  var $, a, validator;

  $ = angular.element;

  a = angular.module('validator.directive', []);

  validator = function($injector) {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attrs) {
        var $parse, $validator, match, model, name, rule, ruleNames, rules, validate, _i, _len;
        $validator = $injector.get('$validator');
        $parse = $injector.get('$parse');
        model = $parse(attrs.ngModel);
        rules = [];
        validate = function(from, funcs) {
          var rule, successCount, _i, _len, _results;
          if (funcs == null) {
            funcs = {
              success: function() {},
              error: function() {}
            };
          }
          successCount = 0;
          _results = [];
          for (_i = 0, _len = rules.length; _i < _len; _i++) {
            rule = rules[_i];
            switch (from) {
              case 'blur':
                if (rule.invoke !== 'blur') {
                  continue;
                }
                rule.enableError = true;
                break;
              case 'watch':
                if (rule.invoke !== 'watch' && !rule.enableError) {
                  continue;
                }
                break;
              case 'broadcast':
                rule.enableError = true;
            }
            model.assign(scope, rule.filter(model(scope)));
            _results.push(rule.validator(model(scope), scope, element, attrs, {
              success: function() {
                if (++successCount === rules.length) {
                  return funcs.success();
                }
              },
              error: function() {
                return funcs.error();
              }
            }));
          }
          return _results;
        };
        match = attrs.validator.match(RegExp('^/(.*)/$'));
        if (match) {
          rule = $validator.convertRule('dynamic', {
            validator: RegExp(match[1]),
            invoke: attrs.validatorInvoke,
            error: attrs.validatorError
          });
          rules.push(rule);
        }
        match = attrs.validator.match(RegExp('^\\[(.*)\\]$'));
        if (match) {
          ruleNames = match[1].split(',');
          for (_i = 0, _len = ruleNames.length; _i < _len; _i++) {
            name = ruleNames[_i];
            rules.push($validator.getRule(name.trim()));
          }
        }
        scope.$on($validator.broadcastChannel.prepare, function(self, object) {
          if (object.model && attrs.ngModel.indexOf(object.model) !== 0) {
            return;
          }
          return object.accept();
        });
        scope.$on($validator.broadcastChannel.start, function(self, object) {
          if (object.model && attrs.ngModel.indexOf(object.model) !== 0) {
            return;
          }
          return validate('broadcast', {
            success: object.success,
            error: object.error
          });
        });
        scope.$watch(attrs.ngModel, function(newValue, oldValue) {
          if (newValue === oldValue) {
            return;
          }
          return validate('watch');
        });
        return $(element).bind('blur', function() {
          return scope.$apply(function() {
            return validate('blur');
          });
        });
      }
    };
  };

  validator.$inject = ['$injector'];

  a.directive('validator', validator);

}).call(this);

(function() {
  angular.module('validator', ['validator.provider', 'validator.directive']);

}).call(this);

(function() {
  var $, a;

  $ = angular.element;

  a = angular.module('validator.provider', []);

  a.provider('$validator', function() {
    var $injector, $q, setupProviders,
      _this = this;
    $injector = null;
    $q = null;
    this.rules = {};
    this.broadcastChannel = {
      prepare: '$validateStartPrepare',
      start: '$validateStartStart'
    };
    setupProviders = function(injector) {
      $injector = injector;
      return $q = $injector.get('$q');
    };
    this.convertRule = function(name, object) {
      var errorMessage, func, regex, result, successFunc;
      if (object == null) {
        object = {};
      }
      /*
      Convert the rule object.
      */

      result = {
        name: name,
        enableError: object.invoke === 'watch',
        invoke: object.invoke,
        filter: object.filter,
        validator: object.validator,
        error: object.error,
        success: object.success
      };
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
        result.error = function(element) {
          var index, parent, _i;
          parent = $(element).parent();
          for (index = _i = 1; _i <= 3; index = ++_i) {
            if (parent.hasClass('form-group')) {
              if (parent.hasClass('has-error')) {
                return;
              }
              $(element).parent().append("<label class='control-label error'>" + errorMessage + "</label>");
              parent.addClass('has-error');
              break;
            }
            parent = parent.parent();
          }
        };
      }
      successFunc = function(element) {
        var index, label, parent, _i, _j, _len, _ref, _results;
        parent = $(element).parent();
        _results = [];
        for (index = _i = 1; _i <= 3; index = ++_i) {
          if (parent.hasClass('has-error')) {
            parent.removeClass('has-error');
            _ref = parent.find('label');
            for (_j = 0, _len = _ref.length; _j < _len; _j++) {
              label = _ref[_j];
              if (!($(label).hasClass('error'))) {
                continue;
              }
              label.remove();
              break;
            }
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
        result.validator = function(value, scope, element, attrs, funcs) {
          if (regex.test(value)) {
            result.success(element, attrs);
            return typeof funcs.success === "function" ? funcs.success() : void 0;
          } else {
            if (result.enableError) {
              result.error(element, attrs);
            }
            return typeof funcs.error === "function" ? funcs.error() : void 0;
          }
        };
      } else if (typeof result.validator === 'function') {
        func = result.validator;
        result.validator = function(value, scope, element, attrs, funcs) {
          return $q.all([func(value, scope, element, attrs, $injector)]).then(function(objects) {
            if (objects && objects.length > 0 && objects[0]) {
              result.success(element, attrs);
              return typeof funcs.success === "function" ? funcs.success() : void 0;
            } else {
              if (result.enableError) {
                result.error(element, attrs);
              }
              return typeof funcs.error === "function" ? funcs.error() : void 0;
            }
          });
        };
      }
      return result;
    };
    this.register = function(name, object) {
      if (object == null) {
        object = {};
      }
      /*
      Register the rule.
      @params name: The rule name.
      @params object:
          invoke: 'watch' or 'blur' or undefined(validate by yourself)
          filter: function(input)
          validator: RegExp() or function(value, scope, element, attrs, $injector)
          error: string or function(element, attrs)
          success: function(element, attrs)
      */

      return this.rules[name] = this.convertRule(name, object);
    };
    this.getRule = function(name) {
      if (this.rules[name]) {
        return this.rules[name];
      } else {
        return null;
      }
    };
    this.validate = function(scope, model) {
      var brocadcastObject, count, deferred, func, promise;
      deferred = $q.defer();
      promise = deferred.promise;
      count = {
        total: 0,
        success: 0,
        error: 0
      };
      func = {
        success: function() {},
        error: function() {},
        accept: function() {
          return count.total++;
        },
        validatedSuccess: function() {
          if (++count.success === count.total) {
            return func.success();
          }
        },
        validatedError: function() {
          if (count.error++ === 0) {
            return func.error();
          }
        }
      };
      promise.success = function(fn) {
        return func.success = fn;
      };
      promise.error = function(fn) {
        return func.error = fn;
      };
      brocadcastObject = {
        model: model,
        accept: func.accept,
        success: func.validatedSuccess,
        error: func.validatedError
      };
      scope.$broadcast(_this.broadcastChannel.prepare, brocadcastObject);
      setTimeout(function() {
        return scope.$apply(function() {
          var $validator;
          $validator = $injector.get('$validator');
          return scope.$broadcast($validator.broadcastChannel.start, brocadcastObject);
        });
      }, 0);
      return promise;
    };
    this.get = function($injector) {
      setupProviders($injector);
      return {
        rules: this.rules,
        broadcastChannel: this.broadcastChannel,
        convertRule: this.convertRule,
        getRule: this.getRule,
        validate: this.validate
      };
    };
    this.get.$inject = ['$injector'];
    return this.$get = this.get;
  });

}).call(this);
