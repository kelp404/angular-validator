
a = angular.module 'validator.rules', ['validator']

config = ($validatorProvider) ->
    # ----------------------------
    # required
    # ----------------------------
    $validatorProvider.register 'required',
        invoke: 'watch'
        validator: RegExp "^.+$"
        error: 'This field is required.'

    # ----------------------------
    # number
    # ----------------------------
    $validatorProvider.register 'number',
        invoke: 'watch'
        validator: RegExp "^[-+]?[0-9]*[\.]?[0-9]*$"
        error: 'This field should be number.'

config.$inject = ['$validatorProvider']
a.config config
