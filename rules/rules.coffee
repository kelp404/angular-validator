
a = angular.module 'validator.rules', ['validator']

config = ($validatorProvider) ->
    # ----------------------------
    # required
    # ----------------------------
    $validatorProvider.register 'required',
        invoke: ['watch']
        validator: RegExp "^.+$"
        error: 'This field is required.'

    # ----------------------------
    # trim
    # ----------------------------
    $validatorProvider.register 'trim',
        filter: (input) -> input.trim()

config.$inject = ['$validatorProvider']
a.config config
