$ = angular.element
angular.module 'validator.provider', []

.provider '$validator', ->
    # ----------------------------------------
    # providers
    # ----------------------------------------
    $injector = null
    $q = null
    $timeout = null


    # ----------------------------------------
    # properties
    # ----------------------------------------
    @rules = {}
    @broadcastChannel =
        prepare: '$validatePrepare'
        start: '$validateStart'
        reset: '$validateReset'


    # ----------------------------------------
    # private functions
    # ----------------------------------------
    @setupProviders = (injector) ->
        $injector = injector
        $q = $injector.get '$q'
        $timeout = $injector.get '$timeout'

    @convertError = (error) ->
        ###
        Convert rule.error.
        @param error: error messate (string) or function(value, scope, element, attrs, $injector)
        @return: function(value, scope, element, attrs, $injector)
        ###
        return error if typeof error is 'function'

        errorMessage = if error.constructor is String then error else ''
        (value, scope, element, attrs) ->
            parent = $(element).parent()
            until parent.length is 0
                if parent.hasClass 'form-group'
                    parent.addClass 'has-error'
                    for label in parent.find('label') when $(label).hasClass 'error'
                        $(label).remove()
                    $label = $ "<label class='control-label error'>#{errorMessage}</label>"
                    $label.attr('for', attrs.id) if attrs.id
                    if $(element).parent().hasClass 'input-group'
                        $(element).parent().parent().append $label
                    else
                        $(element).parent().append $label
                    break
                parent = parent.parent()

    @convertSuccess = (success) ->
        ###
        Convert rule.success.
        @param success: function(value, scope, element, attrs, $injector)
        @return: function(value, scope, element, attrs, $injector)
        ###
        return success if typeof success is 'function'

        (value, scope, element) ->
            parent = $(element).parent()
            until parent.length is 0
                if parent.hasClass 'has-error'
                    parent.removeClass 'has-error'
                    for label in parent.find('label') when $(label).hasClass 'error'
                        $(label).remove()
                    break
                parent = parent.parent()

    @convertValidator = (validator) ->
        ###
        Convert rule.validator.
        @param validator: RegExp() or function(value, scope, element, attrs, $injector)
                                                    { return true / false }
        @return: function(value, scope, element, attrs, funcs{success, error})
            (funcs is callback functions)
        ###
        result = ->
        if validator.constructor is RegExp
            regex = validator
            result = (value='', scope, element, attrs, funcs) ->
                if regex.test value then funcs.success?() else funcs.error?()
        else if typeof validator is 'function'
            # swop
            func = validator
            result = (value, scope, element, attrs, funcs) ->
                $q.all([func(value, scope, element, attrs, $injector)]).then (objects) ->
                    if objects and objects.length > 0 and objects[0]
                        funcs.success?()
                    else
                        funcs.error?()
                , -> funcs.error?()
        result


    # ----------------------------------------
    # public functions
    # ----------------------------------------
    @convertRule = (name, object={}) =>
        ###
        Convert the rule object.
        ###
        result =
            name: name
            enableError: object.invoke is 'watch'
            invoke: object.invoke
            init: object.init
            validator: object.validator ? -> yes
            error: object.error ? ''
            success: object.success

        # convert
        result.error = @convertError result.error
        result.success = @convertSuccess result.success
        result.validator = @convertValidator result.validator

        result

    @register = (name, object={}) ->
        ###
        Register the rule.
        @params name: The rule name.
        @params object:
            invoke: 'watch' or 'blur' or undefined(validate by yourself)
            init: function(scope, element, attrs, $injector)
            validator: RegExp() or function(value, scope, element, attrs, $injector)
            error: string or function(scope, element, attrs)
            success: function(scope, element, attrs)
        ###
        # set rule
        @rules[name] = @convertRule name, object

    @getRule = (name) ->
        ###
        Get the rule form $validator.rules by the name.
        @return rule / null
        ###
        if @rules[name] then angular.copy(@rules[name]) else null

    @validate = (scope, model) =>
        ###
        Validate the model.
        @param scope: The scope.
        @param model: The model name of the scope or validator-group.
        @return:
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
                then: []
            # accept callback function for directives
            accept: -> count.total++
            # success callback function for directives
            validatedSuccess: ->
                if ++count.success is count.total
                    x() for x in func.promises.success
                    x() for x in func.promises.then
                count.success
            # error callback function for directives
            validatedError: ->
                if count.error++ is 0
                    x() for x in func.promises.error
                    x() for x in func.promises.then
                count.error
        promise.success = (fn) ->
            # push success promises into func.promise.success
            func.promises.success.push fn
            promise
        promise.error = (fn) ->
            # push error promises into func.promise.error
            func.promises.error.push fn
            promise
        promise.then = (fn) ->
            func.promises.then.push fn
            promise

        broadcastObject =
            model: model
            accept: func.accept
            success: func.validatedSuccess
            error: func.validatedError

        scope.$broadcast @broadcastChannel.prepare, broadcastObject
        $timeout ->
            # wait for getting all promises
            if count.total is 0
                # nothing to validate
                x() for x in func.promises.success
                return
            $validator = $injector.get '$validator'
            scope.$broadcast $validator.broadcastChannel.start, broadcastObject
        promise

    @reset = (scope, model) =>
        ###
        Reset validated error messages of the model.
        @param scope: The scope.
        @param model: The model name of the scope or validator-group.
        ###
        scope.$broadcast @broadcastChannel.reset, model: model


    # ----------------------------------------
    # $get
    # ----------------------------------------
    @get = ($injector) ->
        @setupProviders $injector

        rules: @rules
        broadcastChannel: @broadcastChannel
        register: @register
        convertRule: @convertRule
        getRule: @getRule
        validate: @validate
        reset: @reset
    @get.$inject = ['$injector']
    @$get = @get
    return
