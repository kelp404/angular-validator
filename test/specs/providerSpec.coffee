describe "validator.provider", ->
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
        it "check $validator.rules is empty", inject ($validator) ->
            expect(0).toBe Object.keys($validator.rules).length


    describe '$validator.broadcastChannel', ->
        it "check $validator.broadcastChannel property", inject ($validator) ->
            expect
                prepare: '$validatePrepare'
                start: '$validateStart'
            .toEqual $validator.broadcastChannel


    describe '$validatorProvider.setupProviders()', ->
        it "check providers", inject ($injector) ->
            expect(validatorProvider.setupProviders($injector)).not.toThrow()


    describe '$validatorProvider.convertError()', ->
        it "check convertError(string)", ->
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

        it "check convertError(function)", ->
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

