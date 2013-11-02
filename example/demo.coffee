
a = angular.module 'app', ['validator']

a.controller 'DemoController', ($scope) ->
    $scope.formWatch =
        required: ''
