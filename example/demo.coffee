
a = angular.module 'app', ['validator']

a.config ($validatorProvider) ->
    $validatorProvider.register 'backendWatch',
        invoke: ['watch']
        validator: ($http) ->
            h = $http.get 'example/data.json'
            h.success (data) ->
                console.log data
        error: "do not use 'Kelp' or 'x'"

a.controller 'DemoController', ($scope) ->
    $scope.formWatch =
        required: ''
        http: ''
