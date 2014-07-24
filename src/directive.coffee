$ = angular.element
angular.module 'validator.directive', ['validator.provider']

.directive 'validator', ['$injector', ($injector) ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs, ctrl) ->
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
        groups = []
        groupRules = {}
        scrollOffset = 100

        # ----------------------------------------
        # private methods
        # ----------------------------------------
        validate = (from, args={}) ->
            ###
            Validate this element with all rules.
            @param from: 'watch', 'blur' or 'broadcast'
            @param args:
                success(): success callback (this callback will return success count)
                error(): error callback (this callback will return error count)
                oldValue: the old value of $watch
                group: model/group passed into $provider.validate arguments
            ###

            if args.group
                # check to see if in one of multiple validator-groups
                if args.group in groups
                    rules = groupRules[args.group]
                    validateRules(rules, from, args)  
                    return
                # single validator-group style
                if attrs.validatorGroup is args.group
                    validateRules(rules, from, args)
                    return

            validateRules(rules, from, args)

        validateRules = (rules, from, args) ->
            successCount = 0
            errorCount = 0
            increaseSuccessCount = ->
                if ++successCount >= rules.length
                    ctrl.$setValidity attrs.ngModel, yes
                    rule.success model(scope), scope, element, attrs, $injector for rule in rules
                    args.success?()
                return

            return increaseSuccessCount() if rules.length is 0
            for rule in rules
                switch from
                    when 'blur'
                        continue if rule.invoke isnt 'blur'
                        rule.enableError = yes
                    when 'watch'
                        if rule.invoke isnt 'watch' and not rule.enableError
                            increaseSuccessCount()
                            continue
                    when 'broadcast' then rule.enableError = yes
                    else

                # validate
                do (rule) ->
                    # success() and error() call back will run in other thread
                    rule.validator model(scope), scope, element, attrs,
                        success: ->
                            increaseSuccessCount()
                        error: ->
                            if rule.enableError and ++errorCount is 1
                                ctrl.$setValidity attrs.ngModel, no
                                # call the rule's error callback -> actually adds message, etc.
                                rule.error model(scope), scope, element, attrs, $injector
                            if args.error?() is 1
                                # scroll to the first element
                                try 
                                    element[0].scrollIntoView(true)
                                    scrolledY = window.pageYOffset
                                    if scrolledY and scrollOffset
                                        window.scroll(0, scrolledY - scrollOffset)
                                try element[0].select()

        registerRequired = ->
            rule = $validator.getRule 'required'
            rule ?= $validator.convertRule 'required',
                validator: /^.+$/
                invoke: 'watch'
            rules.push rule

        removeRule = (name) ->
            ###
            Remove the rule in rules by the name.
            ###
            for index in [0...rules.length] by 1 when rules[index]?.name is name
                rules[index].success model(scope), scope, element, attrs, $injector
                rules.splice index, 1
                index--

        # ----------------------------------------
        # attrs.$observe
        # ----------------------------------------
        # attrs.$observe 'validator', (value) ->
        #     # remove old rule
        #     rules.length = 0
        #     registerRequired() if observerRequired.validatorRequired or observerRequired.required

        #     # validate by RegExp
        #     match = value.match /^\/(.*)\/$/
        #     if match
        #         rule = $validator.convertRule 'dynamic',
        #             validator: RegExp match[1]
        #             invoke: attrs.validatorInvoke
        #             error: attrs.validatorError
        #         rules.push rule
        #         return

        #     # validate by rules
        #     match = value.match /^\[(.+)\]$/
        #     if match
        #         ruleNames = match[1].split ','
        #         for name in ruleNames
        #             # stupid browser has no .trim()
        #             rule = $validator.getRule name.replace(/^\s+|\s+$/g, '')
        #             rule.init? scope, element, attrs, $injector
        #             rules.push rule if rule

        attrs.$observe 'validatorError', (value) ->
            match = attrs.validator.match /^\/(.*)\/$/
            if match
                removeRule 'dynamic'
                rule = $validator.convertRule 'dynamic',
                    validator: RegExp match[1]
                    invoke: attrs.validatorInvoke
                    error: value
                rules.push rule

        # validate by required attribute
        observerRequired =
            validatorRequired: no
            required: no
        attrs.$observe 'validatorRequired', (value) ->
            if value and value isnt 'false'
                # register required
                registerRequired()
                observerRequired.validatorRequired = yes
            else if observerRequired.validatorRequired
                # remove required
                removeRule 'required'
                observerRequired.validatorRequired = no
        attrs.$observe 'required', (value) ->
            if value and value isnt 'false'
                # register required
                registerRequired()
                observerRequired.required = yes
            else if observerRequired.required
                # remove required
                removeRule 'required'
                observerRequired.required = no

        attrs.$observe 'validator', (value) ->
            # remove old rules
            groupRules.length = 0
            rules.length = 0
            
            registerRequired() if observerRequired.validatorRequired or observerRequired.required

            # multiple validator groups
            # pattern: validator="[group-1: [ruleA, ruleB], group-2: [ruleA, ruleC]]"
            match = value.match /[^\[\s]+:[\s,]{0,1}\[[^\]]*\]/g
            if match
                for group in match
                    currentRules = []
                    groupName = group.split(':')[0].trim()

                    # get rules for this group
                    ruleMatch = group.match /\[(.+)\]/
                    if ruleMatch
                        ruleNames = ruleMatch[1].split ','
                        for name in ruleNames
                            # stupid browser has no .trim()
                            rule = $validator.getRule name.replace(/^\s+|\s+$/g, '')
                            rule.init? scope, element, attrs, $injector
                            if rule
                                currentRules.push rule
                                rules.push rule
                    groupRules[groupName] = currentRules
                    groups.push groupName
                return

            # validate by RegExp
            match = value.match /^\/(.*)\/$/
            if match
                rule = $validator.convertRule 'dynamic',
                    validator: RegExp match[1]
                    invoke: attrs.validatorInvoke
                    error: attrs.validatorError
                rules.push rule
                return

            # validate by rules
            match = value.match /^\[(.+)\]$/
            if match
                ruleNames = match[1].split ','
                for name in ruleNames
                    # stupid browser has no .trim()
                    rule = $validator.getRule name.replace(/^\s+|\s+$/g, '')
                    rule.init? scope, element, attrs, $injector
                    rules.push rule if rule
                return


        # ----------------------------------------
        # listen
        # ----------------------------------------
        isAcceptTheBroadcast = (broadcast, modelName) ->
            if modelName
                # matches validator-group
                return yes if modelName in groups
                return yes if attrs.validatorGroup is modelName

                if broadcast.targetScope is scope
                    # check ngModel and validate model are same.
                    return attrs.ngModel.indexOf(modelName) is 0
                else
                    # current scope is different maybe create by scope.$new() or in the ng-repeat
                    anyHashKey = (targetModel, hashKey) ->
                        for key of targetModel
                            x = targetModel[key]
                            switch typeof x
                                when 'string'
                                    return yes if key is '$$hashKey' and x is hashKey
                                when 'object'
                                    return yes if anyHashKey x, hashKey
                                else
                        no

                    # the model of the scope in ng-repeat
                    dotIndex = attrs.ngModel.indexOf '.'
                    itemExpression = if dotIndex >= 0 then attrs.ngModel.substr(0, dotIndex) else attrs.ngModel
                    itemModel = $parse(itemExpression) scope
                    return anyHashKey $parse(modelName)(broadcast.targetScope), itemModel.$$hashKey
            yes
        scope.$on $validator.broadcastChannel.prepare, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            object.accept()
        scope.$on $validator.broadcastChannel.start, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            validate 'broadcast',
                success: object.success
                error: object.error
                group: object.model
        scope.$on $validator.broadcastChannel.reset, (self, object) ->
            return if not isAcceptTheBroadcast self, object.model
            for rule in rules
                rule.success model(scope), scope, element, attrs, $injector
                rule.enableError = no if rule.invoke isnt 'watch'
            ctrl.$setValidity attrs.ngModel, yes

        # ----------------------------------------
        # watch
        # ----------------------------------------
        scope.$watch attrs.ngModel, (newValue, oldValue) ->
            return if newValue is oldValue  # first
            validate 'watch', oldValue: oldValue

        # ----------------------------------------
        # blur
        # ----------------------------------------
        $(element).bind 'blur', ->
            if scope.$root.$$phase
                validate 'blur'
            else
                scope.$apply -> validate 'blur'
]
