
a = angular.module 'app', ['validator', 'validator.rules']

# ----------------------------------------
# config
# ----------------------------------------
a.config ($validatorProvider) ->
    # backendWatch
    $validatorProvider.register 'backendWatch',
        invoke: 'watch'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (response) ->
                if response and response.data
                    not (value in (x.name for x in response.data))
                else
                    no
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendSubmit',
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (response) ->
                if response and response.data
                    not (value in (x.name for x in response.data))
                else
                    no
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendBlur',
        invoke: 'blur'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (response) ->
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
a.run ($validator) ->
    $validator.register 'requiredRun',
        invoke: 'watch'
        validator: /^.+$/
        error: 'This field is requrired.'


# ----------------------------------------
# controller
# ----------------------------------------
a.controller 'DemoController', ($scope, $validator) ->
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
            v = $validator.validate $scope, 'formSubmit'
            v.success ->
                # validated success
                console.log 'success'
            v.error ->
                # validated error
                console.log 'error'
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
            v = $validator.validate $scope, 'formRepeat'
            v.success -> console.log 'success'
            v.error -> console.log 'error'
        reset: ->
            $validator.reset $scope, 'formRepeat'
