
a = angular.module 'validator.directive', []

validator = ($injector) ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs) ->
        # ----------------------------
        # providers
        # ----------------------------
        $validator = $injector.get '$validator'
        $parse = $injector.get '$parse'

        # ----------------------------
        # valuables
        # ----------------------------
        model = $parse attrs.ngModel

        # ----------------------------
        # functions
        # ----------------------------
        validate = (rule) ->
            model.assign scope, rule.filter(model(scope))
            rule.validator model(scope), element, attrs

        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first

            # validat by RegExp
            match = attrs.validator.match(RegExp('^/(.*)/$'))
            if match
                rule = $validator.convertRule
                    validator: RegExp match[1]
                    invoke: attrs.validatorInvoke
                    error: attrs.validatorError
                validate rule
                return

            # validat by rules
            match = attrs.validator.match(RegExp('^\\[(.*)\\]$'))
            if match
                ruleNames = match[1].split(',')
                for name in ruleNames
                    rule = $validator.getRule name.trim()
                    validate rule if rule
                return


validator.$inject = ['$injector']
a.directive 'validator', validator
