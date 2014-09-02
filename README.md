#angular-validator [![Build Status](https://secure.travis-ci.org/kelp404/angular-validator.png?branch=master)](http://travis-ci.org/kelp404/angular-validator) [![devDependency Status](https://david-dm.org/kelp404/angular-validator/dev-status.png?branch=master)](https://david-dm.org/kelp404/angular-validator#info=devDependencies)

[MIT License](http://www.opensource.org/licenses/mit-license.php)  


This is an AngularJS form validation written in [CoffeeScript](http://coffeescript.org) and **thinking in AngularJS not jQuery**.




##Frameworks
1. [AngularJS](http://angularjs.org/) 1.2.18

2. [Bootstrap 3](http://getbootstrap.com/)
> If your `error` is `string` in rules you should include bootstrap3.css and use `form-group` to the input div.




##$validator
```coffee
angular.module 'yourApp', ['validator']
```
####register
>
```coffee
# .config
$validatorProvider.register = (name, object={}) ->
    ###
    Register the rule.
    @params name: The rule name.
    @params object:
        invoke: 'watch' or 'blur' or undefined(validate by yourself)
        init: function(scope, element, attrs, $injector)
        validator: RegExp() or function(value, scope, element, attrs, $injector)
        error: string or function(value, scope, element, attrs, $injector)
        success: function(value, scope, element, attrs, $injector)
    ###
# .run
$validator.register = (name, object={}) ->
```

####validate
>
```coffee
$validate.validate = (scope, model) =>
    ###
    Validate the model.
    @param scope: The scope.
    @param model: The model name of the scope or validator-group.
    @return:
        @promise success(): The success function.
        @promise error(): The error function.
    ###
```

####reset
>
```coffee
$validate.reset = (scope, model) =>
    ###
    Reset validated error messages of the model.
    @param scope: The scope.
    @param model: The model name of the scope or validator-group.
    ###
```




##validator.directive
>
```coffee
a = angular.module 'validator.directive', ['validator.provider']
validator = ($injector) ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, element, attrs) ->
        ###
        The link of `validator`.
        You could use `validator=[rule, rule]` or `validator=/^regex$/`.
        ###
validator.$inject = ['$injector']
a.directive 'validator', validator
```

####validator="[rule, rule]", [required], [validator-required="true/false"], [validator-group="group"]
>
```html
<div class="form-group">
    <label for="required0" class="col-md-2 control-label">Required</label>
    <div class="col-md-10">
        <input type="text" ng-model="formWatch.required" validator="[required]"
         class="form-control" id="required0" placeholder="Required"/>
    </div>
</div>
```

####validator="/^regex$/", [validator-error="msg"], [validator-invoke="watch"], [required], [validator-required="true/false"], [validator-group="group"]
>
```html
<div class="form-group">
    <label for="regexp0" class="col-md-2 control-label">RegExp [a-z]</label>
    <div class="col-md-10">
        <input type="text" ng-model="formWatch.regexp" validator="/[a-z]/"
         validator-invoke="watch" validator-error="it should be /[a-z]/"
         class="form-control" id="regexp0" placeholder="RegExp [a-z]"/>
    </div>
</div>
```

####[required], [validator-required="true/false"]
>
If the element has this attribute, $validator will add the rule `required` into rules of the element.




##validator.rules
```coffee
angular.module 'yourApp', ['validator.rules']
```
>There are default rules in this module.
+ required
+ number
+ email
+ url




##Example
>
```html
<!-- Bootstrap3 (not required) -->
<link type="text/css" rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.1.0/css/bootstrap.min.css"/>
<!-- AngularJS -->
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.0.8/angular.min.js"></script>
<!-- $validator -->
<script type="text/javascript" src="dist/angular-validator.js"></script>
<!-- basic rules (not required) -->
<script type="text/javascript" src="dist/angular-validator-rules.js"></script>
```
>
```html
<!-- submit -->
<div class="panel panel-default">
    <div class="panel-heading">
        <h3 class="panel-title">submit</h3>
    </div>
    <form class="form-horizontal panel-body">
        <div class="form-group">
            <label for="required2" class="col-md-2 control-label">Required</label>
            <div class="col-md-10">
                <input type="text" ng-model="formSubmit.required" validator="[requiredSubmit]" class="form-control" id="required2" placeholder="Required"/>
            </div>
        </div>
        <div class="form-group">
            <label for="regexp2" class="col-md-2 control-label">RegExp [a-z]</label>
            <div class="col-md-10">
                <input type="text" ng-model="formSubmit.regexp" validator="/[a-z]/" validator-error="it should be /[a-z]/" class="form-control" id="regexp2" placeholder="RegExp [a-z]"/>
            </div>
        </div>
        <div class="form-group">
            <label for="http2" class="col-md-2 control-label">$http</label>
            <div class="col-md-10">
                <input type="text" ng-model="formSubmit.http" validator="[backendSubmit]" class="form-control" id="http2" placeholder="do not use 'Kelp' or 'x'"/>
            </div>
        </div>
        <div class="form-group">
            <div class="col-md-offset-2 col-md-10">
                <input type="submit" ng-click="submit()" class="btn btn-default"/>
            </div>
        </div>
    </form>
    <div class="panel-footer">{{formSubmit}}</div>
</div>
```
>
```coffee
a = angular.module 'app', ['validator', 'validator.rules']
a.config ($validatorProvider) ->    
    $validatorProvider.register 'backendSubmit',
        validator: (value, scope, element, attrs, $injector) ->
            $http = $injector.get '$http'
            h = $http.get 'example/data.json'
            h.then (data) ->
                if data and data.status < 400 and data.data
                    return no if value in (x.name for x in data.data)
                    return yes
                else
                    return no
        error: "do not use 'Kelp' or 'x'"
    # submit - required
    $validatorProvider.register 'requiredSubmit',
        validator: RegExp "^.+$"
        error: 'This field is required.'
```
>
```coffee
# CoffeeScript
# the form model
$scope.formSubmit =
    required: ''
    regexp: ''
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
```
```js
// JavaScript
// the form model
$scope.formSubmit = {
    required: '',
    regexp: '',
    http: ''
};
// the submit function
$scope.submit = function () {
    $validator.validate($scope, 'formSubmit')
    .success(function () {
        // validated success
        console.log('success');
    })
    .error(function () {
        // validated error
        console.log('error');
    });
};
```




##Unit Test
>
```bash
$ grunt test
```




##Development
```bash
# install node modules
$ npm install
# install bower components
$ bower install
```
```bash
# run the local server and the file watcher to compile CoffeeScript
$ grunt dev
# compile coffee script and minify
$ grunt build
```

