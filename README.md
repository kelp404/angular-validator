#angular-validator [![Build Status](https://secure.travis-ci.org/kelp404/angular-validator.png?branch=master)](http://travis-ci.org/kelp404/angular-validator)

[MIT License](http://www.opensource.org/licenses/mit-license.php)  


This is an AngularJS form validation written in [CoffeeScript](http://coffeescript.org) and **think in AngularJS not jQuery**.  
It supports [Bootstrap3](http://getbootstrap.com/).




##$validator
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
        filter: function(input)
        validator: RegExp() or function(value, scope, element, attrs, $injector)
        error: string or function(scope, element, attrs)
        success: function(scope, element, attrs)
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
    @param model: The model name of the scope.
    @return:
        @promise success(): The success function.
        @promise error(): The error function.
    ###
```




##Example
>
```html
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
```
```bash
# run the local server and the file watcher to compile CoffeeScript
$ grunt dev
```




###[Closure Compiler](https://code.google.com/p/closure-compiler/)
You could download compiler form [Google Code](https://code.google.com/p/closure-compiler/wiki/BinaryDownloads?tm=2).

**[External Tools](http://www.jetbrains.com/pycharm/webhelp/external-tools.html):**

Settings  |  value
:---------:|:---------:
Program | java
Parameters | -jar /Volumes/Data/tools/closure-compiler/compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js $FileName$ --js_output_file $FileNameWithoutExtension$.min.$FileExt$
Working directory | $FileDir$
