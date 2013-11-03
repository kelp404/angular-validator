
a = angular.module 'app', ['validator', 'validator.rules']

a.config ($validatorProvider) ->
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

a.controller 'DemoController', ($scope) ->
    $scope.formWatch =
        required: ''
        regexp: ''
        http: ''
