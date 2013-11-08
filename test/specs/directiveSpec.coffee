
describe 'validator.directive', ->
    $ = angular.element
    beforeEach module('validator', 'validator.rules')

    describe 'validator=[rule]', ->
        $compile = null
        $timeout = null
        $validator = null
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
            scope.input = 'regex'
            v = $validator.validate scope
            v.success -> spy.success()
            v.error -> spy.error()
            $timeout.flush()
            expect(spy.success).toHaveBeenCalled()
            expect(spy.error).not.toHaveBeenCalled()
