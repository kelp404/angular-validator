
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
            $validator.validate scope
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
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
            $validator.validate scope
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check validator=[required] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'xx'
            $validator.validate(scope, 'input')
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
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
            $validator.validate scope
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
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
            $validator.validate scope
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
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

    describe 'validator-group with validator=[ruleA, ruleB]', ->
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
                        <input type="text" ng-model="input" validator="[requiredSubmit, emailBlur]" validator-group="test-group" class="form-control" id="name"/>
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
            $validator.register 'requiredSubmit',
                validator: /^.+$/
                error: 'This field is required.'

        it 'check test-group: [requiredSubmit, emailBlur] error', ->
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'x'
            $validator.validate(scope, 'test-group')
            $timeout.flush()
            $label = $ $form.find('label')[1]
            expect($label.text()).toEqual 'This field should be the email.'

        it 'check test-group: [requiredSubmit, emailBlur] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'test@test.com'
            $validator.validate(scope, 'test-group')
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check validator=[requiredSubmit, emailBlur] emailBlur error', ->
            $compile($form) scope
            $rootScope.$digest()
            scope.input = 'x'
            $form.find('input').triggerHandler 'blur'
            $timeout.flush()
            $label = $ $form.find('label')[1]
            expect($label.text()).toEqual 'This field should be the email.'

    describe 'validator=[group-1: [ruleA, ruleB], group-2: [ruleA, ruleC]]', ->
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
                        <input type="text" ng-model="input" class="form-control" id="name"
                            validator="[group-1: [requiredSubmit, numberSubmit], group-2: [requiredBlur, zipSubmit], group-3: [numberSubmit], group-4:[requiredBlur]]" />
                    </div>
                </div>
                """

            # rule
            $validator.register('requiredSubmit', {
                validator: /^.+$/,
                error: 'This field is required.'
            });
            $validator.register('numberSubmit', {
                validator: /^[-+]?[0-9]*[\.]?[0-9]*$/,
                error: 'This field should be a number.'
            });
            $validator.register('zipSubmit', {
                validator: /^$|^\d{5}(-\d{4})?$/,  #empty or zip code
                error: 'This field should be a zip code. E.g. 23233 or 23233-5014'
            });
            $validator.register 'requiredBlur',
                invoke: 'blur'
                validator: /^.+$/
                error: 'This field is required.'

        it 'check group-1: [requiredSubmit, numberSubmit] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = '1235'
            $validator.validate(scope, 'group-1')
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check group-2: [requiredSubmit, zipSubmit] success', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = '23233'
            $validator.validate(scope, 'group-2')
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()

        it 'check group-2: [requiredSubmit, zipSubmit] failure', ->
            spy =
                success: jasmine.createSpy 'success'
                error: jasmine.createSpy 'error'
                then: jasmine.createSpy 'then'
            $compile($form) scope
            $rootScope.$digest()
            scope.input = '1235'
            $validator.validate(scope, 'group-2')
            .success -> spy.success()
            .error -> spy.error()
            .then -> spy.then()
            $timeout.flush()
            expect(spy.success).not.toHaveBeenCalled()
            expect(spy.error).toHaveBeenCalled()
            expect(spy.then).toHaveBeenCalled()
            $label = $ $form.find('label')[1]
            expect($label.text()).toEqual 'This field should be a zip code. E.g. 23233 or 23233-5014'

        it 'check normal requiredBlur error triggered by blur', ->
            $compile($form) scope
            $rootScope.$digest()
            scope.input = ''
            $form.find('input').triggerHandler 'blur'
            $timeout.flush()
            $label = $ $form.find('label')[1]
            expect($label.text()).toEqual 'This field is required.'


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