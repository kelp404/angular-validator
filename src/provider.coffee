
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
    # init
    # ----------------------------
    init =
        all: ->
            do @[x] for x of @ when x isnt 'all'
            return

    # ----------------------------
    # private functions
    # ----------------------------
    setupProviders = (injector) ->
        $injector = injector
        $q = $injector.get '$q'

    # ----------------------------
    # public functions
    # ----------------------------
    @convertRule = (object={}) ->
        ###
        Convert the rule object.
        ###
        result =
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
                for index in [1..3]
                    if parent.hasClass 'form-group'
                        return if parent.hasClass 'has-error'
                        $(element).parent().append "<label class='control-label error'>#{errorMessage}</label>"
                        parent.addClass 'has-error'
                        break
                    parent = parent.parent()

        # convert success
        successFunc = (element) ->
            parent = $(element).parent()
            for index in [1..3]
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
                if regex.test value
                    result.success element, attrs
                    funcs.success?()
                else
                    result.error element, attrs if result.enableError
                    funcs.error?()

        else if typeof(result.validator) is 'function'
            func = result.validator
            result.validator = (value, scope, element, attrs, funcs) ->
                $q.all([func(value, scope, element, attrs, $injector)]).then (objects) ->
                    if objects and objects.length > 0 and objects[0]
                        result.success element, attrs
                        funcs.success?()
                    else
                        result.error element, attrs if result.enableError
                        funcs.error?()

        result

    @register = (name, object={}) ->
        ###
        Register the rules.
        @params name: The rule name.
        @params object:
            invoke: 'watch' or 'blur' or undefined(validator by yourself)
            filter: function(input)
            validator: RegExp() or function(value, scope, element, attrs, $injector)
            error: string or function(element, attrs)
            success: function(element, attrs)
        ###
        # set rule
        @rules[name] = @convertRule object

    @getRule = (name) ->
        if @rules[name] then @rules[name] else null

    @validate = (scope, model) =>
        deferred = $q.defer()
        promise = deferred.promise
        count =
            total: 0
            success: 0
            error: 0
        func =
            success: ->
            error: ->
            accept: -> count.total++
            validatedSuccess: -> func.success() if ++count.success is count.total
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
        do init.all

        rules: @rules
        broadcastChannel: @broadcastChannel
        convertRule: @convertRule
        getRule: @getRule
        validate: @validate
    @get.$inject = ['$injector']
    @$get = @get
