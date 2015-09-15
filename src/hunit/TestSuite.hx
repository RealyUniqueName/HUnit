package hunit;


import haxe.CallStack;
import haxe.macro.Expr;
import haxe.Constraints.Function;
import haxe.Log;
import haxe.PosInfos;
import haxe.Timer;
import hunit.exceptions.InvalidTestException;
import hunit.exceptions.NoExpectedException;
import hunit.exceptions.TestFailException;
import hunit.exceptions.UnexpectedException;
import hunit.exceptions.WarningException;
import hunit.report.DefaultWriter;
import hunit.report.IReportWriter;
import hunit.TestCase;
import hunit.report.TestReport;
import hunit.TestState;
import hunit.Utils;
import hunit.utils.TestCaseData;
import hunit.warnings.IncompleteTestWarning;
import hunit.warnings.NoAssertionsWarning;
import hunit.warnings.NoTestsWarning;


using hunit.Utils;



/**
 * Base class for test suites.
 *
 */
@:access(hunit.Utils)
class TestSuite
{
    /** Try to shutdown flash player after running tests */
    public var shutDownStandaloneFlashPlayer : Bool = #if (fdb || native_trace) true #else false #end;
    /** Tests results data */
    public var report : Null<TestReport>;
    /** Run tests assigned to these groups onlu */
    public var groups : Array<String>;
    /** Do not run tests assigned to these groups */
    public var excludeGroups : Array<String>;
    /** Exclude specified packages and/or classes from tests */
    public var exclude : Array<String>;

    /** Current test state */
    private var state : Null<TestState>;
    /** List of test cases added to this test suite */
    private var cases : Array<TestCase>;
    /** Temporary stored original `trace()` method */
    private var originalTrace : Null<Dynamic->?PosInfos->Void>;
    /** Function which outputs something to user */
    private var printer : Dynamic->Void;
    /** This is required to build full call stack for unexpected exceptions */
    private var executeTestCallStack : Array<StackItem>;
    /** Outputs report after all tests finished */
    private var reportWriter : IReportWriter;


    /**
     * Cosntructor
     *
     * @param reportWriter Handles test suite results report
     * @param printer Callback to use when HUnit need to output something to user. By default uses `hunit.Unitls.print()`
     */
    public function new (reportWriter:IReportWriter = null, printer:Dynamic->Void = null) : Void
    {
        groups = Utils.getDefinedList('HUNIT_GROUP');
        excludeGroups = Utils.getDefinedList('HUNIT_EXCLUDE_GROUP');

        exclude = Utils.getDefinedList('HUNIT_EXCLUDE');

        if (printer == null) {
            printer = Utils.print;
        }

        this.printer = printer;

        if (reportWriter == null) {
            reportWriter = new DefaultWriter(printer);
        }
        this.reportWriter = reportWriter;

        cases  = [];
        report = createReport();
    }


    /**
     * Add tests from specified directory.
     *
     * @param dir Directory relative to a file this method was called from.
     *              If `dir` is `null`, HUnit will use one from `-D HUNIT_TEST_DIR=path/to/tests` compilation flag.
     */
    macro public function addDirectory (eThis:Expr, dir:String = null) : Expr
    {
        return eThis.addTests(dir);
    }


    /**
     * Add test case to test suite
     *
     */
    public function add (testCase:TestCase) : Void
    {
        cases.push(testCase);
    }


    /**
     * Execute tests
     *
     */
    public function run () : Void
    {
        if (cases.length == 0) {
            printer('\nNo test cases added to test suite.\n\n');
            return;
        }

        redirectTraces();
        report.startTime  = Timer.stamp();

        printHeader();

        var total = 1;
        for (testCase in cases.filterCases(exclude)) {
            try {
                var data  = new TestCaseData(testCase);

                onCaseBegin(testCase, data);

                if (data.totalTestCount == 0) {
                    var cls = Type.getClassName(Type.getClass(testCase));
                    report.addWarning(testCase, '<none>', new NoTestsWarning('$cls does not contain any tests.'));

                } else {
                    var runQueue = data.getTests(groups, excludeGroups);

                    while (runQueue.length > 0) {
                        var test = runQueue.shift();

                        if (total % 80 == 0) another80Tests();

                        var passed = executeTest(testCase, test);
                        if (!passed) {
                            runQueue = skipDependent(testCase, test, runQueue);
                        }

                        total ++;
                    }
                }

                onCaseEnd(testCase);
            } catch(e:Dynamic) {
                printer('E');
                report.addFail(testCase, '<none>', Exception.wrap(e));
            }
        }
        report.endTime = Timer.stamp();

        printer('\n\n');

        report.output();
        printSummary();

        restoreOriginalTrace();

        #if flash
        if (shutDownStandaloneFlashPlayer) {
            flash.Lib.fscommand('quit');
        }
        #end
    }


    /**
     * Creates new report
     *
     */
    private function createReport () : TestReport
    {
        return new TestReport(reportWriter);
    }


    /**
     * Creates new test state
     *
     */
    private function createTestState (testCase:TestCase, testName:String) : TestState
    {
        return new TestState(testCase, testName, report, printer);
    }


    /**
     * Change `trace()`
     *
     */
    private function redirectTraces () : Void
    {
        originalTrace = Log.trace;
        Log.trace = Utils.printTrace.bind(printer, _, _);
    }


    /**
     * Restore original behavior of `trace()`
     *
     */
    private function restoreOriginalTrace () : Void
    {
        Log.trace = originalTrace;
    }


    /**
     * Handle the beginning of executing tests from `testCase`
     *
     */
    private function onCaseBegin (testCase:TestCase, data:TestCaseData) : Void
    {
        report.cases.add(testCase);
        testCase.setupTestCase();
    }


    /**
     * Handle the end of executing tests from `testCase`
     *
     */
    private function onCaseEnd (testCase:TestCase) : Void
    {
        testCase.tearDownTestCase();
    }


    /**
     * Run tests from `testCase`
     * Returns `true` if test passed.
     */
    private function executeTest (testCase:TestCase, test:TestData) : Bool
    {
        executeTestCallStack = CallStack.callStack();

        beforeTestStart(testCase, test.name);
        testCase.setup();

        var passed = false;

        try {
            try {
                Reflect.callMethod(testCase, test.callback, []);
                validateTest(test);
            } catch (e:TestFailException) {
                throw e;
            } catch (e:Dynamic) {
                validateTest(test, e, CallStack.exceptionStack());
            }

            if (!state.warned) {
                state.success();
                passed = true;
                printer('.');
            } else {
                printer('W');
            }
            state.finalize();

        } catch (e:Exception) {
            state.fail(e);
            printer(Std.is(e, InvalidTestException) ? 'E' : 'F');
        }

        testCase.tearDown();
        afterTestDone(testCase);

        return passed;
    }


     /**
     * Initialize new state
     *
     */
    private function beforeTestStart (testCase:TestCase, test:String) : Void
    {
        state = createTestState(testCase, test);
        testCase.__hu_state = state;
    }


    /**
     * Perform cleaning after each test
     *
     */
    private function afterTestDone (testCase:TestCase) : Void
    {
        state = null;
    }


    /**
     * Check expectations satisfaction.
     *
     * @param test
     * @param exception If test threw an exception, this is thrown exception.
     *
     * @throws hunit.exceptions.TestFailException If test failed.
     */
    private function validateTest (test:TestData, exception:Dynamic = null, exceptionStack:Array<StackItem> = null) : Void
    {
        //check if test is incomplete
        if (test.isIncomplete) {
            state.warn(new IncompleteTestWarning(test.incompleteMsg));
        }

        //test already failed somewhere else
        if (state.pendingExceptions.length > 0) {
            throw state.pendingExceptions[0];
        }

        if (exception != null) {
            state.validateException(exception, executeTestCallStack, exceptionStack);
        }

        for (expect in state.expectedCalls) {
            expect.validate();
        }

        if (state.expectingException() && !state.expectedException.satisfied) {
            throw new NoExpectedException(state.expectedException.match, state.expectedException.pos);
        }

        if (!test.isIncomplete && !state.madeAssertions()) {
            state.warn(new NoAssertionsWarning('This test did not perform any assertions'));
        }
    }


    /**
     * Remove tests which depend on `failed` one from `runQueue`
     *
     */
    private function skipDependent (testCase:TestCase, failed:TestData, runQueue:Array<TestData>) : Array<TestData>
    {
        var dependent : Array<TestData> = TestCaseData.getDependent(failed, runQueue);

        for (test in dependent) {
            printer('S');
            runQueue.remove(test);
            report.addSkip(testCase, test.name, test.depends);
        }

        return runQueue;
    }


    /**
     * Returns HUnit version
     *
     */
    private function version () : String
    {
        return Utils.version();
    }


    /**
     * Output some fancy header before running the first test.
     *
     */
    private function printHeader () : Void
    {
        printer('HUnit ${version()}\n\n');
    }


    /**
     * Output short stats of running tests
     *
     */
    private function printSummary () : Void
    {
        printer(report.getSummary() + '\n');
        printer('\n');
    }


    /**
     * Perform some actions after each 80 tests done
     *
     */
    private function another80Tests () : Void
    {
        //insert new line each 80 tests
        printer('\n');
    }

}//class TestSuite