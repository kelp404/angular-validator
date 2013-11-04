
a = angular.module 'validator.rules', ['validator']

config = ($validatorProvider) ->
    # ----------------------------
    # required
    # ----------------------------
    $validatorProvider.register 'required',
        invoke: 'watch'
        validator: RegExp "^.+$"
        error: 'This field is required.'

config.$inject = ['$validatorProvider']
a.config config
