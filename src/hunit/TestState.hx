package hunit;

import haxe.CallStack;
import haxe.PosInfos;
import hunit.assert.BaseAssert;
import hunit.call.Call;
import hunit.call.Expect;
import hunit.exceptions.ExpectedExceptionData;
import hunit.exceptions.InvalidTestException;
import hunit.exceptions.UnexpectedException;
import hunit.TestCase;
import hunit.report.TestReport;
import hunit.warnings.Warning;

using hunit.utils.Value;


/**
 * Current test data
 *
 */
class TestState
{
    /** Current test case */
    public var testCase (default,null) : TestCase;
    /** Current test name */
    public var testName (default,null) : String;
    /** Tests result information */
    public var report (default,null) : TestReport;
    /** If current test is expected to throw an exception */
    public var expectedException (default,set) : ExpectedExceptionData;
    /** Print some value */
    public var print (default,null) : Dynamic->Void;
    /** Indicates if current test caused any warnings */
    public var warned (default,null) : Bool = false;
    /** Expected method calls */
    public var expectedCalls (default,null) : List<Expect>;
    /** Performed assertions */
    public var asserted (default,null) : List<BaseAssert>;
    /** exceptions, which wait the end of current test to be processed */
    public var pendingExceptions (default,null) : Array<Exception>;
    /** expected or stubbed method calls which raised exceptions */
    private var callExceptions : Array<Call>;



    /**
     * Cosntructor
     *
     */
    public function new (testCase:TestCase, testName:String, report:TestReport, print:Dynamic->Void) : Void
    {
        this.testCase = testCase;
        this.testName = testName;
        this.report   = report;
        this.print    = print;

        pendingExceptions = [];
        callExceptions    = [];
        expectedCalls     = new List();
        asserted          = new List();
    }


    /**
     * Indicates if current test is expected to throw an exception
     *
     */
    public function expectingException () : Bool
    {
        return expectedException != null;
    }


    /**
     * Validate `e`.
     *
     * @throws hunit.exceptions.UnexpectedException If `e` is not an expected exception
     */
    public function validateException (e:Null<Dynamic>, catchExceptionStack:Array<StackItem>) : Void
    {
        if (e != null) {
            if (expectedException != null) {
                expectedException.validate(e, getOriginalExceptionStack(e, catchExceptionStack));
            } else {
                throw new UnexpectedException(e, getOriginalExceptionStack(e, catchExceptionStack));
            }
        }
    }


    /**
     * Mark test as passed without warnings
     *
     */
    public function success () : Void
    {
        report.addSuccess(testCase, testName);
    }


    /**
     * Add warning to report
     *
     */
    public function warn (warning:Warning) : Void
    {
        warned = true;
        report.addWarning(testCase, testName, warning);
    }


    /**
     * Mark test as failed with `exception`
     *
     */
    public function fail (exception:Exception) : Void
    {
        //check if this is one of the pending exceptions
        pendingExceptions.remove(exception);

        report.addFail(testCase, testName, exception);
    }


    /**
     * Add `msg` to test suite summary report
     *
     */
    public function notice (msg:String, pos:PosInfos) : Void
    {
        report.addNotice(testCase, testName, msg, pos);
    }


    /**
     * Exceptions happened before test ended, which potentially will fail test unless handled elsewhere
     *
     */
    public function pendingFail (exception:Exception) : Void
    {
        pendingExceptions.push(exception);
    }


    /**
     * Record thrid party exceptions so if they will be raised to the test validator, we can obtain original exception stack
     *
     */
    public function cacheCallException (call:Call) : Void
    {
        callExceptions.push(call);
    }


    /**
     * Try to obtain callstack for caught exception `e`
     *
     */
    public function getOriginalExceptionStack (e:Dynamic, catchExceptionStack:Array<StackItem>) : Array<StackItem>
    {
        for (call in callExceptions) {
            if (call.exceptionValue.getValue() == e) {
                return call.exceptionStack;
            }
        }

        return CallStack.exceptionStack().concat(catchExceptionStack);
    }


    /**
     * Indicates whether current test performed any assertions or not.
     *
     */
    public function madeAssertions () : Bool
    {
        return (expectedCalls.length > 0 || asserted.length > 0 || expectingException());
    }


    /**
     * Perform some actions after test validation ended.
     *
     */
    public function finalize () : Void
    {
        report.assertionCount += asserted.length;
        report.assertionCount += expectedCalls.length;
        if (expectingException()) {
            report.assertionCount ++;
        }
    }


    /**
     * Setter `expectedException`
     *
     */
    private function set_expectedException (expectedException:ExpectedExceptionData) : ExpectedExceptionData
    {
        if (this.expectedException != null) {
            throw new InvalidTestException('Expected exception is already set');
        }

        return this.expectedException = expectedException;
    }

}//class TestState