
$ = angular.element
a = angular.module 'validator.provider', []

a.provider '$validator', ->
    # ----------------------------
    # properties
    # ----------------------------
    @rules = {}

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

    # ----------------------------
    # public functions
    # ----------------------------
    @convertRule = (object={}) ->
        ###
        Convert the rule object.
        ###
        result =
            invoke: object.invoke
            filter: object.filter
            validator: object.validator
            error: object.error
            success: object.success

        result.invoke ?= []
        result.filter ?= (input) -> input
        result.validator ?= -> true
        result.error ?= ''

        # convert error
        if result.error.constructor is String
            errorMessage = result.error
            result.error = (element, attrs) ->
                parent = $(element).parent()
                for index in [1..3]
                    if parent.hasClass('form-group')
                        $(element).parent().append "<label class='control-label error'>#{errorMessage}</label>"
                        parent.addClass('has-error')
                        break
                    parent = parent.parent()

        # convert success
        successFunc = (element, attrs) ->
            parent = $(element).parent()
            for index in [1..3]
                for label in parent.find('label')
                    if $(label).hasClass 'error'
                        label.remove()
                        break
                if parent.hasClass('has-error')
                    parent.removeClass('has-error')
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
            result.validator = (value, scope, element, attrs, isFromWatch=false) ->
                if regex.test value
                    result.success element, attrs
                else
                    if isFromWatch and 'watch' in result.invoke
                        result.error element, attrs

        result

    @register = (name, object={}) ->
        ###
        Register the rules.
        @params name: The rule name.
        @params object:
            invoke: ['watch', 'blur'] or undefined(validator by yourself)
            filter: function(input)
            validator: RegExp() or function(value, element, attrs)
            error: string or function(element, attrs)
            success: function(element, attrs)
        ###
        # set rule
        @rules[name] = @convertRule object

    @getRule = (name) ->
        if @rules[name] then @rules[name] else null

    @validate = (scope) ->


    # ----------------------------
    # $get
    # ----------------------------
    @get = ($injector) ->
        do init.all

        rules: @rules
        getRule: @getRule
        validate: @validate
    @get.$inject = ['$injector']
    @$get = @get
