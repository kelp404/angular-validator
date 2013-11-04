
$ = angular.element
a = angular.module 'validator.provider', []

a.provider '$validator', ->
    # ----------------------------
    # providers
    # ----------------------------
    $injector = null
    $q = null
    $timeout = null

    # ----------------------------
    # properties
    # ----------------------------
    @rules = {}
    @broadcastChannel =
        prepare: '$validateStartPrepare'
        start: '$validateStartStart'

    # ----------------------------
    # private functions
    # ----------------------------
    setupProviders = (injector) ->
        $injector = injector
        $q = $injector.get '$q'
        $timeout = $injector.get '$timeout'

    # ----------------------------
    # public functions
    # ----------------------------
    @convertRule = (name, object={}) ->
        ###
        Convert the rule object.
        ###
        result =
            name: name
            enableError: object.invoke is 'watch'
            invoke: object.invoke
            filter: object.filter
            validator: object.validator
            error: object.error
            success: object.success

        result.filter ?= (input) -> input
        result.validator ?= -> true
        result.error ?= ''

        # convert error
        if result.error.constructor is String
            errorMessage = result.error
            result.error = (element) ->
                parent = $(element).parent()
                until parent.length is 0
                    if parent.hasClass 'form-group'
                        return if parent.hasClass 'has-error'
                        $(element).parent().append "<label class='control-label error'>#{errorMessage}</label>"
                        parent.addClass 'has-error'
                        break
                    parent = parent.parent()

        # convert success
        result.success ?= (element) ->
            parent = $(element).parent()
            until parent.length is 0
                if parent.hasClass 'has-error'
                    parent.removeClass 'has-error'
                    for label in parent.find('label') when $(label).hasClass 'error'
                        label.remove()
                        break
                    break
                parent = parent.parent()


        # convert validator
        if result.validator.constructor is RegExp
            regex = result.validator
            result.validator = (value, scope, element, attrs, funcs) ->
                if regex.test value then funcs.success?() else funcs.error?()

        else if typeof(result.validator) is 'function'
            func = result.validator
            result.validator = (value, scope, element, attrs, funcs) ->
                $q.all([func(value, scope, element, attrs, $injector)]).then (objects) ->
                    if objects and objects.length > 0 and objects[0]
                        funcs.success?()
                    else
                        funcs.error?()

        result

    @register = (name, object={}) ->
        ###
        Register the rule.
        @params name: The rule name.
        @params object:
            invoke: 'watch' or 'blur' or undefined(validate by yourself)
            filter: function(input)
            validator: RegExp() or function(value, scope, element, attrs, $injector)
            error: string or function(element, attrs)
            success: function(element, attrs)
        ###
        # set rule
        @rules[name] = @convertRule name, object

    @getRule = (name) ->
        if @rules[name] then @rules[name] else null

    @validate = (scope, model) =>
        ###
        Validate the model.
        @param scope: The scope.
        @param model: The model name of the scope.
        @promise success(): The success function.
        @promise error(): The error function.
        ###
        deferred = $q.defer()
        promise = deferred.promise
        count =
            total: 0
            success: 0
            error: 0
        func =
            # promise success and error
            promises:
                success: []
                error: []
            # accept callback function for directives
            accept: -> count.total++
            # success callback function for directives
            validatedSuccess: ->
                if ++count.success is count.total
                    x() for x in func.promises.success
                return
            # error callback function for directives
            validatedError: ->
                if count.error++ is 0
                    x() for x in func.promises.error
                return
        promise.success = (fn) ->
            func.promises.success.push fn
            promise
        promise.error = (fn) ->
            func.promises.error.push fn
            func.error = fn
            promise

        brocadcastObject =
            model: model
            accept: func.accept
            success: func.validatedSuccess
            error: func.validatedError

        scope.$broadcast @broadcastChannel.prepare, brocadcastObject
        $timeout ->
            $validator = $injector.get '$validator'
            scope.$broadcast $validator.broadcastChannel.start, brocadcastObject

        promise


    # ----------------------------
    # $get
    # ----------------------------
    @get = ($injector) ->
        setupProviders $injector

        rules: @rules
        broadcastChannel: @broadcastChannel
        convertRule: @convertRule
        getRule: @getRule
        validate: @validate
    @get.$inject = ['$injector']
    @$get = @get
