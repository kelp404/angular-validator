
angular.module 'app', ['validator', 'validator.rules']

# ----------------------------------------
# config
# ----------------------------------------
.config ($validatorProvider) ->
    # backendWatch
    $validatorProvider.register 'backendWatch',
        invoke: 'watch'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            $http.get 'example/data.json'
            .then (response) ->
                if response and response.data
                    not (value in (x.name for x in response.data))
                else
                    no
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendSubmit',
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            $http.get 'example/data.json'
            .then (response) ->
                if response and response.data
                    not (value in (x.name for x in response.data))
                else
                    no
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendBlur',
        invoke: 'blur'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            $http.get 'example/data.json'
            .then (response) ->
                if response and response.data
                    not (value in (x.name for x in response.data))
                else
                    no
        error: "do not use 'Kelp' or 'x'"

    # submit - required
    $validatorProvider.register 'requiredSubmit',
        validator: /^.+$/
        error: 'This field is required.'

    # blur - required
    $validatorProvider.register 'requiredBlur',
        invoke: 'blur'
        validator: /^.+$/
        error: 'This field is required.'

    $validatorProvider.register 'numberSubmit',
        validator: /^[-+]?[0-9]*[\.]?[0-9]*$/
        error: 'This field should be number.'

    # watch - custom less than xx
    $validatorProvider.register 'customLess',
        invoke: 'watch'
        validator: (value, scope) -> value < scope.formWatch.number
        error: 'It should less than number 1.'


# ----------------------------------------
# run
# ----------------------------------------
.run ($validator) ->
    $validator.register 'requiredRun',
        invoke: 'watch'
        validator: /^.+$/
        error: 'This field is requrired.'


# ----------------------------------------
# controller
# ----------------------------------------
.controller 'DemoController', ($scope, $validator) ->
    $scope.formWatch =
        required: ''
        regexp: ''
        requiredRun: ''
        number: 100
        number2: ''
        http: ''

    $scope.formSubmit =
        required: ''
        regexp: ''
        number: ''
        http: ''
        # the submit function
        submit: ->
            $validator.validate $scope, 'formSubmit'
            .success ->
                # validated success
                console.log 'success'
            .error ->
                # validated error
                console.log 'error'
            .then ->
                console.log 'then'
        reset: ->
            $validator.reset $scope, 'formSubmit'

    $scope.formBlur =
        required: ''
        email: ''
        url: ''
        regexp: ''
        http: ''

    $scope.formRepeat =
        model: [
            value: 'a'
        ,   value: 100,
            value: ''
        ]
        submit: ->
            $validator.validate $scope, 'formRepeat'
            .success -> console.log 'success'
            .error -> console.log 'error'
        reset: ->
            $validator.reset $scope, 'formRepeat'
