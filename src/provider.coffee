
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
    @register = (name, object={}) =>
        ###
        Register the rules.
        @params name: The rule name.
        @params object:
            invoke: ['watch', 'blur'] or undefined(validator by yourself)
            filter: function(input)
            validator: RegExp() or function(scope, element, attrs, value)
            error: string or function(scope, element, attrs)
            success: function(scope, element, attrs)
        ###
        object.filter = object.filter || null
        @rules[name] = object

    @validator = (ruleName) ->
        ###
        Validator the input value.

        ###

    # ----------------------------
    # $get
    # ----------------------------
    @get = ($injector) ->
        do init.all

        rules: @rules
    @get.$inject = ['$injector']
    @$get = @get
