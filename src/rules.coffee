
a = angular.module 'validator.rules', ['validator.provider']

config = ($validatorProvider) ->
    rules =
        all: ->
            do @[x] for x of @ when x isnt 'all'
            return
        required: ->
            $validatorProvider.register 'required',
                filter: (input) -> input.toLowerCase()

    do rules.all
config.$inject = ['$validatorProvider']
a.config config
