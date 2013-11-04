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
                  rule.success(scope, element, attrs);
                  return funcs.success();
                }
              },
              error: function() {
                if (rule.enableError) {
                  rule.error(scope, element, attrs);
                }
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
            rule = $validator.getRule(name.trim());
            if (rule) {
              rules.push(rule);
            }
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
    var $injector, $q, $timeout,
      _this = this;
    $injector = null;
    $q = null;
    $timeout = null;
    this.rules = {};
    this.broadcastChannel = {
      prepare: '$validateStartPrepare',
      start: '$validateStartStart'
    };
    this.setupProviders = function(injector) {
      $injector = injector;
      $q = $injector.get('$q');
      return $timeout = $injector.get('$timeout');
    };
    this.convertError = function(error) {
      /*
      Convert rule.error.
      @param error: error messate (string) or function(scope, element, attrs)
      @return: function(scope, element, attrs)
      */

      var errorMessage;
      if (typeof error === 'function') {
        return error;
      }
      errorMessage = error.constructor === String ? error : '';
      return function(scope, element) {
        var parent;
        parent = $(element).parent();
        while (parent.length !== 0) {
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
    };
    this.convertSuccess = function(success) {
      /*
      Convert rule.success.
      @param success: function(scope, element, attrs)
      @return: function(scope, element, attrs)
      */

      if (typeof success === 'function') {
        return success;
      }
      return function(scope, element) {
        var label, parent, _i, _len, _ref, _results;
        parent = $(element).parent();
        _results = [];
        while (parent.length !== 0) {
          if (parent.hasClass('has-error')) {
            parent.removeClass('has-error');
            _ref = parent.find('label');
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              label = _ref[_i];
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
    };
    this.convertValidator = function(validator) {
      /*
      Convert rule.validator.
      @param validator: RegExp() or function(value, scope, element, attrs, $injector)
                                                  { return true / false }
      @return: function(value, scope, element, attrs, funcs{success, error})
          (funcs is callback functions)
      */

      var func, regex, result;
      result = function() {};
      if (validator.constructor === RegExp) {
        regex = validator;
        result = function(value, scope, element, attrs, funcs) {
          if (regex.test(value)) {
            return typeof funcs.success === "function" ? funcs.success() : void 0;
          } else {
            return typeof funcs.error === "function" ? funcs.error() : void 0;
          }
        };
      } else if (typeof validator === 'function') {
        func = validator;
        result = function(value, scope, element, attrs, funcs) {
          return $q.all([func(value, scope, element, attrs, $injector)]).then(function(objects) {
            if (objects && objects.length > 0 && objects[0]) {
              return typeof funcs.success === "function" ? funcs.success() : void 0;
            } else {
              return typeof funcs.error === "function" ? funcs.error() : void 0;
            }
          });
        };
      }
      return result;
    };
    this.convertRule = function(name, object) {
      var result;
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
      result.error = _this.convertError(result.error);
      result.success = _this.convertSuccess(result.success);
      result.validator = _this.convertValidator(result.validator);
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
          error: string or function(scope, element, attrs)
          success: function(scope, element, attrs)
      */

      return this.rules[name] = this.convertRule(name, object);
    };
    this.getRule = function(name) {
      /*
      Get the rule form $validator.rules by the name.
      @return rule / null
      */

      if (this.rules[name]) {
        return this.rules[name];
      } else {
        return null;
      }
    };
    this.validate = function(scope, model) {
      /*
      Validate the model.
      @param scope: The scope.
      @param model: The model name of the scope.
      @return:
          @promise success(): The success function.
          @promise error(): The error function.
      */

      var brocadcastObject, count, deferred, func, promise;
      deferred = $q.defer();
      promise = deferred.promise;
      count = {
        total: 0,
        success: 0,
        error: 0
      };
      func = {
        promises: {
          success: [],
          error: []
        },
        accept: function() {
          return count.total++;
        },
        validatedSuccess: function() {
          var x, _i, _len, _ref;
          if (++count.success === count.total) {
            _ref = func.promises.success;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              x = _ref[_i];
              x();
            }
          }
        },
        validatedError: function() {
          var x, _i, _len, _ref;
          if (count.error++ === 0) {
            _ref = func.promises.error;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              x = _ref[_i];
              x();
            }
          }
        }
      };
      promise.success = function(fn) {
        func.promises.success.push(fn);
        return promise;
      };
      promise.error = function(fn) {
        func.promises.error.push(fn);
        return promise;
      };
      brocadcastObject = {
        model: model,
        accept: func.accept,
        success: func.validatedSuccess,
        error: func.validatedError
      };
      scope.$broadcast(_this.broadcastChannel.prepare, brocadcastObject);
      $timeout(function() {
        var $validator;
        $validator = $injector.get('$validator');
        return scope.$broadcast($validator.broadcastChannel.start, brocadcastObject);
      });
      return promise;
    };
    this.get = function($injector) {
      this.setupProviders($injector);
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
