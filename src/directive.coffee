
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
        validat = (ruleName) ->
            rule = $validator.rules[ruleName]
            return true if not rule
            if rule.filter
                model.assign scope, rule.filter(model(scope))
            true

        scope.$watch attrs.ngModel, ->
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
                    name = name.trim()
                    break if not validat name
                return


validator.$inject = ['$injector']
a.directive 'validator', validator
