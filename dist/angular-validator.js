(function() {
  var $;

  $ = angular.element;

  angular.module('validator.directive', ['validator.provider']).directive('validator', [
    '$injector', function($injector) {
      return {
        restrict: 'A',
        require: 'ngModel',
        link: function(scope, element, attrs, ctrl) {
          var $parse, $validator, isAcceptTheBroadcast, model, observerRequired, onBlur, registerRequired, removeRule, rules, validate;
          $validator = $injector.get('$validator');
          $parse = $injector.get('$parse');
          model = $parse(attrs.ngModel);
          rules = [];
          validate = function(from, args) {
            var errorCount, fn, i, increaseSuccessCount, len, rule, successCount;
            if (args == null) {
              args = {};
            }

            /*
            Validate this element with all rules.
            @param from: 'watch', 'blur' or 'broadcast'
            @param args:
                success(): success callback (this callback will return success count)
                error(): error callback (this callback will return error count)
                oldValue: the old value of $watch
             */
            successCount = 0;
            errorCount = 0;
            increaseSuccessCount = function() {
              var i, len, rule;
              if (++successCount >= rules.length) {
                ctrl.$setValidity(attrs.ngModel, true);
                for (i = 0, len = rules.length; i < len; i++) {
                  rule = rules[i];
                  rule.success(model(scope), scope, element, attrs, $injector);
                }
                if (typeof args.success === "function") {
                  args.success();
                }
              }
            };
            if (rules.length === 0) {
              return increaseSuccessCount();
            }
            fn = function(rule) {
              return rule.validator(model(scope), scope, element, attrs, {
                success: function() {
                  return increaseSuccessCount();
                },
                error: function() {
                  var base, base1;
                  if (rule.enableError && ++errorCount === 1) {
                    ctrl.$setValidity(attrs.ngModel, false);
                    rule.error(model(scope), scope, element, attrs, $injector);
                  }
                  if ((typeof args.error === "function" ? args.error() : void 0) === 1) {
                    try {
                      element[0].scrollIntoViewIfNeeded();
                    } catch (undefined) {}
                    if (element[0].select) {
                      return typeof (base = element[0]).select === "function" ? base.select() : void 0;
                    } else {
                      return typeof (base1 = element[0]).focus === "function" ? base1.focus() : void 0;
                    }
                  }
                }
              });
            };
            for (i = 0, len = rules.length; i < len; i++) {
              rule = rules[i];
              switch (from) {
                case 'blur':
                  if (rule.invoke !== 'blur') {
                    continue;
                  }
                  rule.enableError = true;
                  break;
                case 'watch':
                  if (rule.invoke !== 'watch' && !rule.enableError) {
                    increaseSuccessCount();
                    continue;
                  }
                  break;
                case 'broadcast':
                  rule.enableError = true;
                  break;
              }
              fn(rule);
            }
          };
          registerRequired = function() {
            var rule;
            rule = $validator.getRule('required');
            if (rule == null) {
              rule = $validator.convertRule('required', {
                validator: /^.+$/,
                invoke: 'watch'
              });
            }
            return rules.push(rule);
          };
          removeRule = function(name) {

            /*
            Remove the rule in rules by the name.
             */
            var i, index, ref, ref1, results;
            results = [];
            for (index = i = 0, ref = rules.length; i < ref; index = i += 1) {
              if (!(((ref1 = rules[index]) != null ? ref1.name : void 0) === name)) {
                continue;
              }
              rules[index].success(model(scope), scope, element, attrs, $injector);
              rules.splice(index, 1);
              results.push(index--);
            }
            return results;
          };
          attrs.$observe('validator', function(value) {
            var i, len, match, name, results, rule, ruleNames;
            rules.length = 0;
            if (observerRequired.validatorRequired || observerRequired.required) {
              registerRequired();
            }
            match = value.match(/^\/(.*)\/$/);
            if (match) {
              rule = $validator.convertRule('dynamic', {
                validator: RegExp(match[1]),
                invoke: attrs.validatorInvoke,
                error: attrs.validatorError
              });
              rules.push(rule);
              return;
            }
            match = value.match(/^\[(.+)\]$/);
            if (match) {
              ruleNames = match[1].split(',');
              results = [];
              for (i = 0, len = ruleNames.length; i < len; i++) {
                name = ruleNames[i];
                rule = $validator.getRule(name.replace(/^\s+|\s+$/g, ''));
                if (typeof rule.init === "function") {
                  rule.init(scope, element, attrs, $injector);
                }
                if (rule) {
                  results.push(rules.push(rule));
                } else {
                  results.push(void 0);
                }
              }
              return results;
            }
          });
          attrs.$observe('validatorError', function(value) {
            var match, rule;
            match = attrs.validator.match(/^\/(.*)\/$/);
            if (match) {
              removeRule('dynamic');
              rule = $validator.convertRule('dynamic', {
                validator: RegExp(match[1]),
                invoke: attrs.validatorInvoke,
                error: value
              });
              return rules.push(rule);
            }
          });
          observerRequired = {
            validatorRequired: false,
            required: false
          };
          attrs.$observe('validatorRequired', function(value) {
            if (value && value !== 'false') {
              registerRequired();
              return observerRequired.validatorRequired = true;
            } else if (observerRequired.validatorRequired) {
              removeRule('required');
              return observerRequired.validatorRequired = false;
            }
          });
          attrs.$observe('required', function(value) {
            if (value && value !== 'false') {
              registerRequired();
              return observerRequired.required = true;
            } else if (observerRequired.required) {
              removeRule('required');
              return observerRequired.required = false;
            }
          });
          isAcceptTheBroadcast = function(broadcast, modelName) {
            var anyHashKey, dotIndex, itemExpression, itemModel;
            if (modelName) {
              if (attrs.validatorGroup === modelName) {
                return true;
              }
              if (broadcast.targetScope === scope) {
                return attrs.ngModel.indexOf(modelName) === 0;
              } else {
                anyHashKey = function(targetModel, hashKey) {
                  var key, x;
                  for (key in targetModel) {
                    x = targetModel[key];
                    switch (typeof x) {
                      case 'string':
                        if (key === '$$hashKey' && x === hashKey) {
                          return true;
                        }
                        break;
                      case 'object':
                        if (anyHashKey(x, hashKey)) {
                          return true;
                        }
                        break;
                    }
                  }
                  return false;
                };
                dotIndex = attrs.ngModel.indexOf('.');
                itemExpression = dotIndex >= 0 ? attrs.ngModel.substr(0, dotIndex) : attrs.ngModel;
                itemModel = $parse(itemExpression)(scope);
                if (itemModel == null) {
                  return false;
                }
                return anyHashKey($parse(modelName)(broadcast.targetScope), itemModel.$$hashKey);
              }
            }
            return true;
          };
          scope.$on($validator.broadcastChannel.prepare, function(self, object) {
            if (!isAcceptTheBroadcast(self, object.model)) {
              return;
            }
            return object.accept();
          });
          scope.$on($validator.broadcastChannel.start, function(self, object) {
            if (!isAcceptTheBroadcast(self, object.model)) {
              return;
            }
            return validate('broadcast', {
              success: object.success,
              error: object.error
            });
          });
          scope.$on($validator.broadcastChannel.reset, function(self, object) {
            var i, len, rule;
            if (!isAcceptTheBroadcast(self, object.model)) {
              return;
            }
            for (i = 0, len = rules.length; i < len; i++) {
              rule = rules[i];
              rule.success(model(scope), scope, element, attrs, $injector);
              if (rule.invoke !== 'watch') {
                rule.enableError = false;
              }
            }
            return ctrl.$setValidity(attrs.ngModel, true);
          });
          scope.$watch(attrs.ngModel, function(newValue, oldValue) {
            if (newValue === oldValue) {
              return;
            }
            return validate('watch', {
              oldValue: oldValue
            });
          });
          onBlur = function() {
            if (scope.$root.$$phase) {
              return validate('blur');
            } else {
              return scope.$apply(function() {
                return validate('blur');
              });
            }
          };
          $(element).bind('blur', onBlur);
          return scope.$on('$destroy', function() {
            return $(element).unbind('blur', onBlur);
          });
        }
      };
    }
  ]);

}).call(this);

(function() {
  angular.module('validator', ['validator.directive']);

}).call(this);

(function() {
  var $;

  $ = angular.element;

  angular.module('validator.provider', []).provider('$validator', function() {
    var $injector, $q, $timeout;
    $injector = null;
    $q = null;
    $timeout = null;
    this.rules = {};
    this.broadcastChannel = {
      prepare: '$validatePrepare',
      start: '$validateStart',
      reset: '$validateReset'
    };
    this.setupProviders = function(injector) {
      $injector = injector;
      $q = $injector.get('$q');
      return $timeout = $injector.get('$timeout');
    };
    this.convertError = function(error) {

      /*
      Convert rule.error.
      @param error: error messate (string) or function(value, scope, element, attrs, $injector)
      @return: function(value, scope, element, attrs, $injector)
       */
      var errorMessage;
      if (typeof error === 'function') {
        return error;
      }
      errorMessage = error.constructor === String ? error : '';
      return function(value, scope, element, attrs) {
        var $label, i, label, len, parent, ref;
        parent = element.closest('.form-group');
        if (parent.length) {
          parent.addClass('has-error');
          ref = parent.find('label');
          for (i = 0, len = ref.length; i < len; i++) {
            label = ref[i];
            if ($(label).hasClass('error')) {
              $(label).remove();
            }
          }
          $label = $("<label class='control-label error'>" + errorMessage + "</label>");
          if (attrs.id) {
            $label.attr('for', attrs.id);
          }
          if (element.parent().hasClass('input-group')) {
            return element.parent().parent().append($label);
          } else {
            return element.parent().append($label);
          }
        }
      };
    };
    this.convertSuccess = function(success) {

      /*
      Convert rule.success.
      @param success: function(value, scope, element, attrs, $injector)
      @return: function(value, scope, element, attrs, $injector)
       */
      if (typeof success === 'function') {
        return success;
      }
      return function(value, scope, element) {
        var i, label, len, parent, ref, results;
        parent = element.parent();
        results = [];
        while (parent.length !== 0) {
          if (parent.hasClass('has-error')) {
            parent.removeClass('has-error');
            ref = parent.find('label');
            for (i = 0, len = ref.length; i < len; i++) {
              label = ref[i];
              if ($(label).hasClass('error')) {
                $(label).remove();
              }
            }
            break;
          }
          results.push(parent = parent.parent());
        }
        return results;
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
          if (value == null) {
            value = '';
          }
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
          }, function() {
            return typeof funcs.error === "function" ? funcs.error() : void 0;
          });
        };
      }
      return result;
    };
    this.convertRule = (function(_this) {
      return function(name, object) {
        var ref, ref1, result;
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
          init: object.init,
          validator: (ref = object.validator) != null ? ref : function() {
            return true;
          },
          error: (ref1 = object.error) != null ? ref1 : '',
          success: object.success
        };
        result.error = _this.convertError(result.error);
        result.success = _this.convertSuccess(result.success);
        result.validator = _this.convertValidator(result.validator);
        return result;
      };
    })(this);
    this.register = function(name, object) {
      if (object == null) {
        object = {};
      }

      /*
      Register the rule.
      @params name: The rule name.
      @params object:
          invoke: 'watch' or 'blur' or undefined(validate by yourself)
          init: function(scope, element, attrs, $injector)
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
        return angular.copy(this.rules[name]);
      } else {
        return null;
      }
    };
    this.validate = (function(_this) {
      return function(scope, model) {

        /*
        Validate the model.
        @param scope: The scope.
        @param model: The model name of the scope or validator-group.
        @return:
            @promise success(): The success function.
            @promise error(): The error function.
         */
        var broadcastObject, count, deferred, func, promise;
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
            error: [],
            then: []
          },
          accept: function() {
            return count.total++;
          },
          validatedSuccess: function() {
            var i, j, len, len1, ref, ref1, x;
            if (++count.success === count.total) {
              ref = func.promises.success;
              for (i = 0, len = ref.length; i < len; i++) {
                x = ref[i];
                x();
              }
              ref1 = func.promises.then;
              for (j = 0, len1 = ref1.length; j < len1; j++) {
                x = ref1[j];
                x();
              }
            }
            return count.success;
          },
          validatedError: function() {
            var i, j, len, len1, ref, ref1, x;
            if (count.error++ === 0) {
              ref = func.promises.error;
              for (i = 0, len = ref.length; i < len; i++) {
                x = ref[i];
                x();
              }
              ref1 = func.promises.then;
              for (j = 0, len1 = ref1.length; j < len1; j++) {
                x = ref1[j];
                x();
              }
            }
            return count.error;
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
        promise.then = function(fn) {
          func.promises.then.push(fn);
          return promise;
        };
        broadcastObject = {
          model: model,
          accept: func.accept,
          success: func.validatedSuccess,
          error: func.validatedError
        };
        scope.$broadcast(_this.broadcastChannel.prepare, broadcastObject);
        $timeout(function() {
          var $validator, i, len, ref, x;
          if (count.total === 0) {
            ref = func.promises.success;
            for (i = 0, len = ref.length; i < len; i++) {
              x = ref[i];
              x();
            }
            return;
          }
          $validator = $injector.get('$validator');
          return scope.$broadcast($validator.broadcastChannel.start, broadcastObject);
        });
        return promise;
      };
    })(this);
    this.reset = (function(_this) {
      return function(scope, model) {

        /*
        Reset validated error messages of the model.
        @param scope: The scope.
        @param model: The model name of the scope or validator-group.
         */
        return scope.$broadcast(_this.broadcastChannel.reset, {
          model: model
        });
      };
    })(this);
    this.get = function($injector) {
      this.setupProviders($injector);
      return {
        rules: this.rules,
        broadcastChannel: this.broadcastChannel,
        register: this.register,
        convertRule: this.convertRule,
        getRule: this.getRule,
        validate: this.validate,
        reset: this.reset
      };
    };
    this.get.$inject = ['$injector'];
    this.$get = this.get;
  });

}).call(this);
