
a = angular.module 'app', ['validator', 'validator.rules']

# ----------------------------
# config
# ----------------------------
a.config ($validatorProvider) ->
    # backendWatch
    $validatorProvider.register 'backendWatch',
        invoke: 'watch'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    return false if value in (x.name for x in data.data)
                    return true
                else
                    return false
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendSubmit',
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    return false if value in (x.name for x in data.data)
                    return true
                else
                    return false
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendBlur',
        invoke: 'blur'
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    return false if value in (x.name for x in data.data)
                    return true
                else
                    return false
        error: "do not use 'Kelp' or 'x'"

    # submit - required
    $validatorProvider.register 'requiredSubmit',
        validator: RegExp "^.+$"
        error: 'This field is required.'

    # blur - required
    $validatorProvider.register 'requiredBlur',
        invoke: 'blur'
        validator: RegExp "^.+$"
        error: 'This field is required.'


# ----------------------------
# controller
# ----------------------------
a.controller 'DemoController', ($scope, $validator) ->
    $scope.formWatch =
        required: ''
        regexp: ''
        number: ''
        http: ''

    # the form model
    $scope.formSubmit =
        required: ''
        regexp: ''
        number: ''
        http: ''

    # the submit function
    $scope.submit = ->
        v = $validator.validate $scope, 'formSubmit'
        v.success ->
            # validated success
            console.log 'success'
        v.error ->
            # validated error
            console.log 'error'

    $scope.formBlur =
        required: ''
        regexp: ''
        http: ''
