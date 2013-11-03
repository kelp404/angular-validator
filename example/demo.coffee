
a = angular.module 'app', ['validator', 'validator.rules']

# ----------------------------
# config
# ----------------------------
a.config ($validatorProvider) ->
    # backendWatch
    $validatorProvider.register 'backendWatch',
        invoke: ['watch']
        validator: (value, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    if value in (x.name for x in data.data) then return false
                    return true
                else
                    return false
        error: "do not use 'Kelp' or 'x'"

    $validatorProvider.register 'backendSubmit',
        validator: (value, element, attrs, $injector) ->
            console.log '----------'
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    if value in (x.name for x in data.data) then return false
                    return true
                else
                    return false
        error: "do not use 'Kelp' or 'x'"

    # submit - required
    $validatorProvider.register 'requiredSubmit',
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
