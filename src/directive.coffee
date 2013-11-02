
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
        validate = (rule, isFromWatch) ->
            model.assign scope, rule.filter(model(scope))
            rule.validator model(scope), scope, element, attrs, isFromWatch
#            rule.validator.$inject =
#                value: model(scope)
#                scope: scope
#                element: element
#                attrs: attrs
#                isFromWatch: isFromWatch
#            $injector.invoke rule.validator

        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first

            # validat by RegExp
            match = attrs.validator.match(RegExp('^/(.*)/$'))
            if match
                regex = RegExp match[1]
                return

            # validat by rules
            match = attrs.validator.match(RegExp('^\\[(.*)\\]$'))
            if match
                ruleNames = match[1].split(',')
                for name in ruleNames
                    rule = $validator.getRule name.trim()
                    validate rule, true if rule
                return


validator.$inject = ['$injector']
a.directive 'validator', validator
