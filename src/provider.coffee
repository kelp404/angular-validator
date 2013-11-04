
$ = angular.element
a = angular.module 'validator.provider', []

a.provider '$validator', ->
    # ----------------------------
    # providers
    # ----------------------------
    $injector = null
    $q = null

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
        successFunc = (element) ->
            parent = $(element).parent()
            until parent.length is 0
                if parent.hasClass 'has-error'
                    parent.removeClass 'has-error'
                    for label in parent.find('label') when $(label).hasClass 'error'
                        label.remove()
                        break
                    break
                parent = parent.parent()
        if result.success and typeof(result.success) is 'function'
            # swop
            func = result.success
            result.success = (element, attrs) ->
                func element, attrs
                successFunc element, attrs
        else
            result.success = successFunc


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
            success: ->
            error: ->
            # accept callback function for directives
            accept: -> count.total++
            # success callback function for directives
            validatedSuccess: -> func.success() if ++count.success is count.total
            # error callback function for directives
            validatedError: -> func.error() if count.error++ is 0
        promise.success = (fn) -> func.success = fn
        promise.error = (fn) -> func.error = fn

        brocadcastObject =
            model: model
            accept: func.accept
            success: func.validatedSuccess
            error: func.validatedError

        scope.$broadcast @broadcastChannel.prepare, brocadcastObject
        setTimeout ->
            scope.$apply ->
                $validator = $injector.get '$validator'
                scope.$broadcast $validator.broadcastChannel.start, brocadcastObject
        , 0

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
