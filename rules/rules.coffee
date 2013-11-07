
a = angular.module 'validator.rules', ['validator']

config = ($validatorProvider) ->
    # ----------------------------------------
    # required
    # ----------------------------------------
    $validatorProvider.register 'required',
        filter: (input='') ->
            return no if input.length > 5
            input
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

    # ----------------------------------------
    # email
    # ----------------------------------------
    $validatorProvider.register 'email',
        invoke: 'blur'
        validator: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        error: 'This field should be email.'

config.$inject = ['$validatorProvider']
a.config config
