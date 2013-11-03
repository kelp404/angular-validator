
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
        rules = []

        # ----------------------------
        # functions
        # ----------------------------
        validate = (from) ->
            for rule in rules
                rule.enableError = true if from is 'broadcast'
                model.assign scope, rule.filter(model(scope))
                result = rule.validator model(scope), element, attrs
                return false if !result
            true

        # validat by RegExp
        match = attrs.validator.match(RegExp('^/(.*)/$'))
        if match
            rule = $validator.convertRule
                validator: RegExp match[1]
                invoke: attrs.validatorInvoke
                error: attrs.validatorError
            rules.push rule

        # validat by rules
        match = attrs.validator.match(RegExp('^\\[(.*)\\]$'))
        if match
            ruleNames = match[1].split(',')
            for name in ruleNames
                rules.push $validator.getRule(name.trim())

        # listen
        scope.$on $validator.broadcastChannel.prepare, (self, object) ->
            return if object.model and attrs.ngModel.indexOf(object.model) isnt 0
            do object.accept
        scope.$on $validator.broadcastChannel.start, (self, object) ->
            return if object.model and attrs.ngModel.indexOf(object.model) isnt 0
            if validate('broadcast') then object.success() else object.error()

        # watch
        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first
            do validate


validator.$inject = ['$injector']
a.directive 'validator', validator
