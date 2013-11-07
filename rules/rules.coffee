
a = angular.module 'validator.rules', ['validator']

config = ($validatorProvider) ->
    # ----------------------------------------
    # required
    # ----------------------------------------
    $validatorProvider.register 'required',
        invoke: 'watch'
        validator: /^.+$/
        error: 'This field is required.'

    # ----------------------------------------
    # number
    # ----------------------------------------
    $validatorProvider.register 'number',
        invoke: 'watch'
        validator: /^[-+]?[0-9]*[\.]?[0-9]*$/
        error: 'This field should be number.'

config.$inject = ['$validatorProvider']
a.config config
