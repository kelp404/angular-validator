
describe 'validator.directive', ->
    $ = angular.element
    beforeEach module('validator', 'validator.rules')

    describe 'validator=[rule]', ->
        $compile = null
        $timeout = null
        $validator = null
        $rootScope = null
        scope = null
        $form = null

        beforeEach -> inject ($injector) ->
            $compile = $injector.get '$compile'
            $timeout = $injector.get '$timeout'
            $validator = $injector.get '$validator'
            $rootScope = $injector.get '$rootScope'
            scope = $rootScope.$new()
            scope.input = ''
            $form = $ """
                <div class="form-group">
                    <label for="name" class="col-md-2 control-label">label</label>
                    <div class="col-md-10">
                        <input type="text" ng-model="input" validator="[required]" class="form-control" id="name"/>
                    </div>
                </div>
                """

        it 'check validator=[required] error', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
            $compile($form) scope
            $rootScope.$digest()
            v = $validator.validate scope
            v.success -> spy.success()
            v.error -> spy.error()
            $timeout.flush()
            expect(spy.success).not.toHaveBeenCalled()
            expect(spy.error).toHaveBeenCalled()

        it 'check validator=[required] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'xx'
            v = $validator.validate scope
            v.success -> spy.success()
            v.error -> spy.error()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()

    describe 'validator=/regex/', ->
        $compile = null
        $timeout = null
        $rootScope = null
        scope = null
        $form = null

        beforeEach -> inject ($injector) ->
            $compile = $injector.get '$compile'
            $timeout = $injector.get '$timeout'
            $rootScope = $injector.get '$rootScope'
            scope = $rootScope.$new()
            scope.input = ''
            $form = $ """
                <div class="form-group">
                    <label for="name" class="col-md-2 control-label">label</label>
                    <div class="col-md-10">
                        <input type="text" ng-model="input" validator="/^regex$/" class="form-control" id="name"/>
                    </div>
                </div>
                """

        it 'check validator=/regex/ error', inject ($validator) ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
            $compile($form) scope
            $rootScope.$digest()
            v = $validator.validate scope
            v.success -> spy.success()
            v.error -> spy.error()
            $timeout.flush()
            expect(spy.success).not.toHaveBeenCalled()
            expect(spy.error).toHaveBeenCalled()

        it 'check validator=/regex/ success', inject ($validator) ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'regex'
            v = $validator.validate scope
            v.success -> spy.success()
            v.error -> spy.error()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()


    describe 'validator=[ruleA, ruleB]', ->
        $compile = null
        $timeout = null
        $validator = null
        $rootScope = null
        scope = null
        $form = null

        beforeEach -> inject ($injector) ->
            # providers
            $compile = $injector.get '$compile'
            $timeout = $injector.get '$timeout'
            $validator = $injector.get '$validator'
            $rootScope = $injector.get '$rootScope'

            # scope
            scope = $rootScope.$new()

            # template
            $form = $ """
                <div class="form-group">
                    <label for="name" class="col-md-2 control-label">label</label>
                    <div class="col-md-10">
                        <input type="text" ng-model="input" validator="[requiredBlur, emailBlur]" class="form-control" id="name"/>
                    </div>
                </div>
                """

            # rule
            $validator.register 'emailBlur',
                invoke: 'blur'
                validator: (value) ->
                    if value
                        value.match /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
                    else
                        yes
                error: 'This field should be the email.'
            $validator.register 'requiredBlur',
                invoke: 'blur'
                validator: /^.+$/
                error: 'This field is required.'

        it 'check validator=[requiredBlur, emailBlur] emailBlur error', ->
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'x'
            $form.find('input').triggerHandler 'blur'
            $timeout.flush()
            $label = $ $form.find('label')[1]
            expect($label.text()).toEqual 'This field should be the email.'

