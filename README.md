#angular-validator [![Build Status](https://secure.travis-ci.org/kelp404/angular-validator.png?branch=master)](http://travis-ci.org/kelp404/angular-validator)

[MIT License](http://www.opensource.org/licenses/mit-license.php)  


This is an AngularJS form validation written in [CoffeeScript](http://coffeescript.org) and **think in AngularJS not jQuery**.  
It supports [Bootstrap3](http://getbootstrap.com/).




##$validator
####register
>
```coffeescript
$validatorProvider.register = (name, object={}) ->
    ###
    Register the rule.
    @params name: The rule name.
    @params object:
        invoke: 'watch' or 'blur' or undefined(validator by yourself)
        filter: function(input)
        validator: RegExp() or function(value, scope, element, attrs, $injector)
        error: string or function(element, attrs)
        success: function(element, attrs)
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
```coffee
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
