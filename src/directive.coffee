$ = angular.element
a = angular.module 'validator.directive', ['validator.provider']

validator = ($injector) ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs) ->
        # ----------------------------------------
        # providers
        # ----------------------------------------
        $validator = $injector.get '$validator'
        $parse = $injector.get '$parse'

        # ----------------------------------------
        # valuables
        # ----------------------------------------
        model = $parse attrs.ngModel
        rules = []

        # ----------------------------------------
        # functions
        # ----------------------------------------
        validate = (from, args={}) ->
            ###
            Validate this element with all rules.
            @param from: 'watch', 'blur' or 'broadcast'
            @param args:
                success(): success callback (this callback will return success count)
                error(): error callback (this callback will return error count)
                oldValue: the old value of $watch
            ###
            successCount = 0
            for rule in rules
                switch from
                    when 'blur'
                        continue if rule.invoke isnt 'blur'
                        rule.enableError = yes
                    when 'watch' then continue if rule.invoke isnt 'watch' and not rule.enableError
                    when 'broadcast' then rule.enableError = yes

                # filter
                filterValue = rule.filter model(scope)
                if filterValue is no and from is 'watch'
                    model.assign scope, args.oldValue
                else
                    model.assign scope, filterValue

                # validate
                rule.validator model(scope), scope, element, attrs,
                    success: ->
                        if ++successCount is rules.length
                            rule.success scope, element, attrs
                            args.success?()
                    error: ->
                        rule.error scope, element, attrs if rule.enableError
                        if args.error?() is 1
                            # scroll to the first element
                            try element[0].scrollIntoViewIfNeeded()

        # validat by RegExp
        match = attrs.validator.match /^\/(.*)\/$/
        if match
            rule = $validator.convertRule 'dynamic',
                validator: RegExp match[1]
                invoke: attrs.validatorInvoke
                error: attrs.validatorError
            rules.push rule

        # validat by rules
        match = attrs.validator.match /^\[(.*)\]$/
        if match
            ruleNames = match[1].split(',')
            for name in ruleNames
                # stupid browser has no .trim()
                rule = $validator.getRule name.replace(/^\s+|\s+$/g, '')
                rules.push rule if rule

        # validate by required attribute
        if attrs.required
            rule = $validator.getRule 'required'
            rule ?= $validator.convertRule 'required',
                validator: /^.+$/
                invoke: 'watch'
            rules.push rule


        # listen
        isAcceptTheBroadcast = (broadcast, modelName) ->
            if modelName
                if broadcast.targetScope is scope
                    # check ngModel and validate model are same.
                    return attrs.ngModel.indexOf(modelName) is 0
                else
                    # current scope was created by ng-repeat
                    item = $(element)
                    until item.length is 0
                        repeat = item.attr 'ng-repeat'
                        match = repeat?.match /^.* in (.*)$/
                        return yes if match and match[1].indexOf(modelName) >= 0
                        item = item.parent()
                    return no
            yes
        scope.$on $validator.broadcastChannel.prepare, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            object.accept()
        scope.$on $validator.broadcastChannel.start, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            validate 'broadcast',
                success: object.success
                error: object.error
        scope.$on $validator.broadcastChannel.reset, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            for rule in rules
                rule.success scope, element, attrs

        # watch
        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first
            validate 'watch', oldValue: oldValue

        # blur
        $(element).bind 'blur', ->
            scope.$apply -> validate 'blur'

validator.$inject = ['$injector']
a.directive 'validator', validator
