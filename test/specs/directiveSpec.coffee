
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
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            result = $validator.validate scope
            result.success -> spy.success()
            result.error -> spy.error()
            result.then -> spy.then()
            $timeout.flush()
            expect(spy.success).not.toHaveBeenCalled()
            expect(spy.error).toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check validator=[required] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'xx'
            result = $validator.validate scope
            result.success -> spy.success()
            result.error -> spy.error()
            result.then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

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
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            result = $validator.validate scope
            result.success -> spy.success()
            result.error -> spy.error()
            result.then -> spy.then()
            $timeout.flush()
            expect(spy.success).not.toHaveBeenCalled()
            expect(spy.error).toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check validator=/regex/ success', inject ($validator) ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'regex'
            result = $validator.validate scope
            result.success -> spy.success()
            result.error -> spy.error()
            result.then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()


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


    describe 'given two fields having the same rule with invoke "blur"', ->

        $compile = null
        $timeout = null
        $validator = null
        $rootScope = null
        scope = null
        $form = null

        describe 'when entering invalid data in the first input and switching to the second input and start typing', ->

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
                      <div class="col-md-10">
                        <input type="text" ng-model="input1" validator="[emailBlur]" name="name1" />
                      </div>
                  </div>
                  <div class="form-group">
                      <div class="col-md-10">
                        <input type="text" ng-model="input2" validator="[emailBlur]" name="name2" />
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
                  error: 'Valid e-mail required'


                $compile($form) scope
                $rootScope.$digest()

                scope.input1 = 'x'
                $($form.find('input')[0]).triggerHandler 'blur'
                scope.input2 = 'y'
                scope.$apply()
                $timeout.flush()


            it 'should show an error for the first input', ->
                firstInput = $form.find('input')[0]
                expect(firstInput.parentNode.querySelector('label')).toBeDefined()


            it 'should not show an error for the second input', ->
                secondInput = $form.find('input')[1]
                expect(secondInput.parentNode.querySelector('label')).toBeNull()


            it 'should show an error for the second input when it is blurred', ->
                secondInput = $form.find('input')[1]
                $(secondInput).triggerHandler 'blur'
                expect(secondInput.parentNode.querySelector('label')).toBeDefined()