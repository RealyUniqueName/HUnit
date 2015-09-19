package hunit.mock;

import haxe.CallStack;
import haxe.PosInfos;
import hunit.exceptions.InvalidTestException;
import hunit.exceptions.UnexpectedCallException;
import hunit.exceptions.UnmetExpectationException;
import hunit.call.CallCount;
import hunit.call.Expect;
import hunit.call.IExpect;
import hunit.call.Stub;
import hunit.match.Match;
import hunit.utils.Value;
import hunit.TestCase;
import hunit.call.Call;


using hunit.utils.Value;


/**
 * Data required for correct mock behavior
 *
 */
@:access(hunit.TestCase)
class MockData
{
    /** fully qualified classname of mocked type */
    public var mockClass (default,null) : Class<Dynamic>;
    /** current test set */
    public var testCase (default,null) : TestCase;

    /** Counts every method invocation */
    private var callCounter : Int = 0;
    /** log of all methods invocations */
    private var callLog : Array<Call>;
    /** Data for mocked calls */
    private var stubs : Array<Stub>;
    /** Expectations for method calls */
    private var expectations : Array<Expect>;
    /** All methods should be stubbed by default */
    private var fullStub : Bool = false;
    /** Throw exceptions for each called method which was not configured with `stub()` or `expect()` */
    private var strictMode : Bool = false;
    /** Methods which should not be stubbed */
    private var unstubbedMethods : Array<String>;
    private var unstubPositions : Array<PosInfos>;


    /**
     * Constructor
     *
     */
    public function new (testCase:TestCase, mockClass:Class<Dynamic>, fullStub:Bool = false, strictMode:Bool = false) : Void
    {
        this.mockClass  = mockClass;
        this.testCase   = testCase;
        this.fullStub   = fullStub;
        this.strictMode = strictMode;

        unstubbedMethods = [];
        unstubPositions  = [];
        callLog          = [];
        stubs            = [];
        expectations     = [];
    }


    /**
     * Get classname of a mocked type
     *
     */
    public function mockClassName () : String
    {
        return Type.getClassName(mockClass);
    }


    /**
     * Stub method call
     *
     */
    public function stub (stub:Stub) : Void
    {
        //make user decide whether he actually want a stub or original method
        if (unstubbedMethods.indexOf(stub.method) >= 0) {
            var pos = unstubPositions[ unstubbedMethods.indexOf(stub.method) ];
            var unstubPos = pos.fileName + ':' + pos.lineNumber;

            throw new InvalidTestException('Cannot stub method which was unstubbed at $unstubPos', stub.pos);
        }

        stubs.push(stub);
    }


    /**
     * Make sure `method` won't be stubbed with `mock(MockedClass).stubAll()` if no direct stubs applied.
     *
     * @throws hunit.exceptions.InvalidTestException If `method` has direct stubs configured with `stub(mockInstance)`
     */
    public function unstub (method:String, ?pos:PosInfos) : Void
    {
        for (stub in stubs) {
            //make user decide whether he actually want a stub or original method
            if (stub.method == method) {
                var stubPos = stub.pos.fileName + ':' + stub.pos.lineNumber;

                throw new InvalidTestException('Cannot unstub method which was stubbed directly at $stubPos', pos);
            }
        }

        //don't create duplicates
        if (unstubbedMethods.indexOf(method) < 0) {
            unstubbedMethods.push(method);
            unstubPositions.push(pos);
        }
    }


    /**
     * Add expectation
     *
     */
    public function expect (expect:Expect) : Void
    {
        expect.fromCallId = callCounter;
        expectations.push(expect);
        testCase.__hu_state.expectedCalls.add(expect);
    }


    /**
     * Cancel expectation
     *
     */
    public function removeExpect (expect:Expect) : Void
    {
        expectations.remove(expect);
        testCase.__hu_state.expectedCalls.remove(expect);
    }


    /**
     * Log method invocations
     *
     * @return Call id
     */
    public function methodInvoked (name:String, args:Array<Dynamic>, ?pos:PosInfos) : Int
    {
        var isStub = (false || (fullStub && unstubbedMethods.indexOf(name) < 0));
        var stub : Stub = null;
        for (i in 0...stubs.length) {
            stub = stubs[i];

            if (stub.method == name) {
                isStub = true;

                if (stub.match(name, args)) {
                    break;
                }
            }
            stub = null;
        }

        var stack = CallStack.callStack();
        //remove `methodInvoked()` and mock call from call stack
        stack.shift();

        var call = new Call(callCounter++, this, name, args, stack, pos, isStub, stub);
        callLog.push(call);

        return call.id;
    }


    /**
     * Whether method should call original code (false) or just return predefined result (true)
     *
     */
    public function isMethodMocked (callId:Int) : Bool
    {
        var call = callLog[callId];

        return call.isStub;
    }


    /**
     * Get predefined result for invocation of mocked `method` with `args`
     *
     */
    public function getMockedCallResult (callId:Int) : Dynamic
    {
        var call = callLog[callId];

        if (!call.isStub) {
            var cls = Type.getClassName(mockClass);
            throw new Exception('Trying to get mocked result while `$cls.${call.method}()` is not stubbed');
        }

        if (call.stub == null) {
            return null;
        }

        if (call.stub.implementation.hasValue()) {
            return Reflect.callMethod(null, call.stub.implementation.getValue(), call.arguments);
        }

        if (call.stub.throws.hasValue()) {
            throw call.stub.throws.getValue();
        }

        return (call.stub.returns.hasValue() ? call.stub.returns.getValue() : null);
    }


    /**
     * Add invocation result to call log.
     *
     */
    public function addCallResult (callId:Int, result:Dynamic) : Void
    {
        callLog[callId].result = Thing(result);
    }


    /**
     * Add raised exception to call log.
     *
     */
    public function addCallException (callId:Int, exception:Dynamic) : Void
    {
        callLog[callId].exceptionValue = Thing(exception);
        testCase.__hu_state.cacheCallException(callLog[callId]);
    }


    /**
     * Validate expectation and throw exceptions if expectation is not satisfied.
     *
     */
    public function validateExpectation (expect:Expect) : Void
    {
        var failed = false;
        var reason = '';

        var call  : Call;
        var count : Int = 0;
        for (i in 0...callLog.length) {
            call = callLog[i];
            if (call.id < expect.fromCallId) continue;

            if (expect.match(call)) {
                count ++;
            }
        }
        var s = (count == 1 ? '' : 's');

        switch (expect.count) {
            case Never:
                if (count > 0) {
                    failed = true;
                    // reason = 'Expected to be never called, actually called $count time$s.';
                    reason = ', actually called $count time$s.';
                }
            case Any:
            case Once:
                if (count != 1) {
                    failed = true;
                    // reason = 'Expected to be called once, actually called $count time$s.';
                    reason = ', actually called $count time$s.';
                }
            case AtLeast(amount):
                if (count < amount) {
                    failed = true;
                    // reason = 'Expected to be called at least $amount times, actually called $count time$s.';
                    reason = ', actually called $count time$s.';
                }
            case Exactly(amount):
                if (count != amount) {
                    failed = true;
                    // reason = 'Expected to be called exactly $amount times, actually called $count time$s.';
                    reason = ', actually called $count time$s.';
                }
        }

        if (failed) {
            throw new UnmetExpectationException(expect, reason, expect.pos);
        }
    }


    /**
     * Make some validation before executing call depending on strict mode requirements.
     *
     */
    public function validateStrictMode (callId:Int) : Void
    {
        if (!strictMode) return;

        var call = callLog[callId];
        //call is configured with `stub()`
        if (call.stub != null) return;

        for (i in 0...expectations.length) {
            if (expectations[i].sameObjectMethod(call)) {
                return;
            }
        }

        var msg = '$call is not expected nor stubbed.';
        throwUnexpectedCallException(call, msg);
    }


    /**
     * Check expectations after call with `callId` was executed
     *
     */
    public function validateCall (callId:Int) : Void
    {
        var isExpected = false;
        var satisfies  = false;

        var call = callLog[callId];

        var expect : Expect;
        for (i in 0...expectations.length) {
            expect = expectations[i];

            if (expect.sameObjectMethod(call)) {
                isExpected = true;

                if (expect.match(call)) {
                    expect.timesMatched ++;
                    satisfies = true;
                    if (expect.tooManyCalls()) {
                        throwUnexpectedCallException(call, expect);
                    }
                }
            }
        }

        if (isExpected && !satisfies) {
            throwUnexpectedCallException(call);
        }
    }


    /**
     * Description
     *
     */
    private function throwUnexpectedCallException (call:Call, msg:String = null, expect:Expect = null) : Void
    {
        var e = new UnexpectedCallException(call, expect, msg, call.pos);
        testCase.__hu_state.pendingFail(e);
        //called from mock, so reduce exception stack till that call
        e.truncateStack(1);
        throw e;
    }

}//class MockData