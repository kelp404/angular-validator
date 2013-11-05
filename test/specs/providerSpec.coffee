
# https://github.com/pivotal/jasmine/wiki/Matchers

describe 'validator.provider', ->
    $ = angular.element
    fakeModule = null
    validatorProvider = null

    beforeEach module('validator')
    beforeEach ->
        fakeModule = angular.module 'fakeModule', ['validator']
        fakeModule.config ($validatorProvider) ->
            validatorProvider = $validatorProvider
    beforeEach module('fakeModule')


    describe '$validator.rules', ->
        it 'check $validator.rules is empty', inject ($validator) ->
            expect(0).toBe Object.keys($validator.rules).length


    describe '$validator.broadcastChannel', ->
        it 'check $validator.broadcastChannel property', inject ($validator) ->
            expect
                prepare: '$validatePrepare'
                start: '$validateStart'
            .toEqual $validator.broadcastChannel


    describe '$validatorProvider.setupProviders()', ->
        it 'check providers', inject ($injector) ->
            expect(validatorProvider.setupProviders($injector)).not.toThrow()


    describe '$validatorProvider.convertError()', ->
        it 'check convertError(string)', ->
            $element = $ "<div class='form-group'><input type='text' id='input'/></div>"
            $input = $element.find 'input'
            attrs =
                id: 'input'
            error = validatorProvider.convertError 'error message'
            # check error type
            expect('function').toEqual typeof error

            # execute error
            error(null, $input, attrs)
            $errorLabel = $element.find 'label'
            expect($element.hasClass('has-error')).toBe true
            expect($errorLabel.hasClass('control-label')).toBe true
            expect($errorLabel.hasClass('error')).toBe true
            expect($errorLabel.attr('for')).toEqual 'input'
            expect($errorLabel.text()).toEqual 'error message'

        it 'check convertError(function)', ->
            func = (scope, element, attrs) ->
                scope: scope
                element: element
                attrs: attrs
            error = validatorProvider.convertError func
            expect
                scope: 'scope'
                element: 'element'
                attrs: 'attrs'
            .toEqual error('scope', 'element', 'attrs')


    describe '$validator.convertRule(name, object)', ->
        it 'check rule.name is equal to the argument', inject ($validator) ->
            rule = $validator.convertRule 'name', validator: /.*/
            expect(rule.name).toEqual 'name'

        it 'check rule.enableError is true when object.invoke is watch', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(rule.enableError).toBe true
            rule = $validator.convertRule 'name', invoke: 'blur'
            expect(rule.enableError).toBe false
            rule = $validator.convertRule 'name', validator: /.*/
            expect(rule.enableError).toBe false

        it 'check invoke is equal to the argument', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(rule.invoke).toEqual 'watch'
            
        it 'check filter(input) is return input value when object.filter is undefined', inject ($validator) ->
            rule = $validator.convertRule 'name', validator: /.*/
            result = rule.filter 'input'
            expect(result).toEqual 'input'
            func = (input) -> input.toLowerCase()
            rule = $validator.convertRule 'name', filter: func
            expect(rule.filter).toBe func

        it 'check validator is in the result of convertRule()', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(typeof rule.validator).toEqual 'function'

        it 'check error is in the result of convertRule()', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(typeof rule.error).toEqual 'function'

        it 'check success is in the result of convertRule()', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(typeof rule.success).toEqual 'function'


    describe '$validator', ->
        it '$validator.rules and $validatorProvider.rules are the same object', inject ($validator) ->
            expect($validator.rules).toBe validatorProvider.rules
        it '$validator.broadcastChannel and $validatorProvider.broadcastChannel are the same object', inject ($validator) ->
            expect($validator.broadcastChannel).toBe validatorProvider.broadcastChannel
        it '$validator.register and $validatorProvider.register are the same object', inject ($validator) ->
            expect($validator.register).toBe validatorProvider.register
        it '$validator.convertRule and $validatorProvider.convertRule are the same object', inject ($validator) ->
            expect($validator.convertRule).toBe validatorProvider.convertRule
        it '$validator.getRule and $validatorProvider.getRule are the same object', inject ($validator) ->
            expect($validator.getRule).toBe validatorProvider.getRule
        it '$validator.validate and $validatorProvider.validate are the same object', inject ($validator) ->
            expect($validator.validate).toBe validatorProvider.validate
