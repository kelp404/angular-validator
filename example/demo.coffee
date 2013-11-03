
a = angular.module 'app', ['validator', 'validator.rules']

# ----------------------------
# config
# ----------------------------
a.config ($validatorProvider) ->
    # backendWatch
    $validatorProvider.register 'backendWatch',
        invokes: ['watch']
        validator: (value, element, attrs, $injector) ->
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
        validator: (value, element, attrs, $injector) ->
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
        invokes: ['blur']
        validator: RegExp "^.+$"
        error: 'This field is required.'


# ----------------------------
# controller
# ----------------------------
a.controller 'DemoController', ($scope, $validator) ->
    $scope.formWatch =
        required: ''
        regexp: ''
        http: ''

    $scope.formSubmit =
        required: ''
        regexp: ''
        http: ''
    $scope.submit = ->
        v = $validator.validate $scope, 'formSubmit'
        v.success -> console.log 'success'
        v.error -> console.log 'error'

    $scope.formBlur =
        required: ''
        regexp: ''
        http: ''
