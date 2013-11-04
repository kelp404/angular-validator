$ = angular.element
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
        validate = (from, funcs) ->
            funcs ?=
                success: ->
                error: ->
            successCount = 0
            for rule in rules
                switch from
                    when 'blur'
                        continue if rule.invoke isnt 'blur'
                        rule.enableError = true
                    when 'watch' then continue if rule.invoke isnt 'watch' and not rule.enableError
                    when 'broadcast' then rule.enableError = true

                model.assign scope, rule.filter(model(scope))
                rule.validator model(scope), scope, element, attrs,
                    success: ->
                        if ++successCount is rules.length
                            rule.success element, attrs
                            funcs.success()
                    error: ->
                        rule.error element, attrs if rule.enableError
                        funcs.error()

        # validat by RegExp
        match = attrs.validator.match(RegExp('^/(.*)/$'))
        if match
            rule = $validator.convertRule 'dynamic',
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
            object.accept()
        scope.$on $validator.broadcastChannel.start, (self, object) ->
            return if object.model and attrs.ngModel.indexOf(object.model) isnt 0
            validate 'broadcast',
                success: object.success
                error: object.error

        # watch
        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first
            validate 'watch'

        # blur
        $(element).bind 'blur', ->
            scope.$apply -> validate 'blur'


validator.$inject = ['$injector']
a.directive 'validator', validator
