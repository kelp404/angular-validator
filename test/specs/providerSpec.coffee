describe "validator.provider", ->
    beforeEach module('validator')

    describe '$validator.register', ->
        fakeModule = null
        validatorProvider = null

        beforeEach ->
            fakeModule = angular.module 'fakeModule', ['validator']
            fakeModule.config ($validatorProvider) ->
                validatorProvider = $validatorProvider
        beforeEach module('fakeModule')

        it "check $validator.rules is empty", inject ($validator) ->
            expect(0).toBe Object.keys($validator.rules).length


    describe '$validator.rules', ->
        it "check $validator.rules is empty", inject ($validator) ->
            expect(0).toBe Object.keys($validator.rules).length

    describe '$validator.broadcastChannel', ->
        it "check $validator.broadcastChannel property", inject ($validator) ->
            expect
                prepare: '$validatePrepare'
                start: '$validateStart'
            .toEqual $validator.broadcastChannel