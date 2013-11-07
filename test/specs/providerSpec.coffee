
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
                reset: '$validateReset'
            .toEqual $validator.broadcastChannel


    describe '$validatorProvider.setupProviders()', ->
        it 'check providers', inject ($injector) ->
            expect(validatorProvider.setupProviders($injector)).not.toThrow()


    describe '$validatorProvider.convertError()', ->
        it 'check convertError(string) and work on the form-group element', ->
            $element = $ "<div class='form-group'><input type='text' id='input'/></div>"
            $input = $element.find 'input'
            attrs = id: 'input'
            error = validatorProvider.convertError 'error message'
            # check error type
            expect('function').toEqual typeof error
            # execute error
            error(null, $input, attrs)
            $errorLabel = $element.find 'label'
            expect($element.hasClass('has-error')).toBe yes
            expect($errorLabel.hasClass('control-label')).toBe yes
            expect($errorLabel.hasClass('error')).toBe yes
            expect($errorLabel.attr('for')).toEqual 'input'
            expect($errorLabel.text()).toEqual 'error message'

        it 'check convertError(string) and work on the form-group element and input without id', ->
            $element = $ "<div class='form-group'><input type='text'/></div>"
            $input = $element.find 'input'
            attrs = id: undefined
            error = validatorProvider.convertError ''
            # execute error
            error(null, $input, attrs)
            $errorLabel = $element.find 'label'
            expect($element.hasClass('has-error')).toBe yes
            expect($errorLabel.hasClass('control-label')).toBe yes
            expect($errorLabel.hasClass('error')).toBe yes
            expect($errorLabel.attr('for')).toBeUndefined()
            expect($errorLabel.text()).toEqual ''

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


    describe '$validatorProvider.convertSuccess()', ->
        it 'check convertSuccess(string) and work on the form-group element', ->
            $element = $ "<div class='form-group has-error'><input type='text' id='input'/><label class='control-label error'>msg</label></div>"
            $input = $element.find 'input'
            success = validatorProvider.convertSuccess()
            # check error type
            expect('function').toEqual typeof success
            # execute error
            success(null, $input)
            $errorLabel = $element.find 'label'
            expect($errorLabel.length).toBe 0
            expect($element.hasClass('has-error')).toBe no

        it 'check convertSuccess(function)', ->
            func = (scope, element, attrs) ->
                scope: scope
                element: element
                attrs: attrs
            success = validatorProvider.convertSuccess func
            expect
                scope: 'scope'
                element: 'element'
                attrs: 'attrs'
            .toEqual success('scope', 'element', 'attrs')


    describe 'validatorProvider.convertValidator(validator)', ->
        it 'check arguments of convertValidator(function)', ->
            model = {}
            func = (value, scope, element, attrs, injector) ->
                model.value = value
                model.scope = scope
                model.element = element
                model.attrs = attrs
                model.injector = injector
            validator = validatorProvider.convertValidator func
            expect(typeof validator).toEqual 'function'
            func 'value', 'scope', 'element', 'attrs', 'injector'
            expect
                value: 'value'
                scope: 'scope'
                element: 'element'
                attrs: 'attrs'
                injector: 'injector'
            .toEqual model

        it 'check convertValidator(function)', inject ($validator, $rootScope, $injector) ->
            count =
                success: 0
                error: 0
            func = (value, scope, element, attrs, injector) ->
                expect(injector).toBe $injector
                value is 'value'
            validator = validatorProvider.convertValidator func
            $rootScope.$apply ->
                validator 'value', null, null, null,
                    success: -> count.success++
                    error: ->
            expect(count.success).toBe 1
            $rootScope.$apply ->
                validator 'xx', null, null, null,
                    success: ->
                    error: -> count.error++
            expect(count.error).toBe 1


    describe '$validator.convertRule(name, object)', ->
        it 'check rule.name is equal to the argument', inject ($validator) ->
            rule = $validator.convertRule 'name', validator: /.*/
            expect(rule.name).toEqual 'name'

        it 'check rule.enableError is yes when object.invoke is watch', inject ($validator) ->
            rule = $validator.convertRule 'name', invoke: 'watch'
            expect(rule.enableError).toBe yes
            rule = $validator.convertRule 'name', invoke: 'blur'
            expect(rule.enableError).toBe no
            rule = $validator.convertRule 'name', validator: /.*/
            expect(rule.enableError).toBe no

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


    describe '$validator.getRule', ->
        it 'check $validator.getRule', inject ($validator) ->
            $validator.rules = name: 'object'
            expect($validator.getRule('name')).toEqual 'object'
            expect($validator.getRule('xx')).toBeNull()


    describe '$validator.validate', ->
        $q = null
        $rootScope = null
        scope = null

        beforeEach -> inject ($injector) ->
            $q = $injector.get '$q'
            $rootScope = $injector.get '$rootScope'
            scope = $rootScope.$new()

        it 'check result has success and error functions', inject ($validator) ->
            promise = $validator.validate scope
            expect(typeof promise.error).toEqual 'function'
            expect(typeof promise.success).toEqual 'function'


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
        it '$validator.reset and $validatorProvider.reset are the same object', inject ($validator) ->
            expect($validator.reset).toBe validatorProvider.reset
