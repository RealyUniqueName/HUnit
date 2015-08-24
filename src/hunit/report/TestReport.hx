package hunit.report;

import haxe.PosInfos;
import hunit.report.IReportWriter;
import hunit.report.TestWarning;
import hunit.TestCase;
import hunit.warnings.Warning;


using Type;


/**
 * Tests results data
 *
 */
class TestReport
{
    /** When testing started (seconds since application start) */
    public var startTime : Float = 0;
    /** When testing ended (seconds since application start) */
    public var endTime (default,set) : Float = 0;
    /** Total time spent running test suite */
    public var spentTime (default,null) : Float = 0;

    /** Report output channel */
    private var writer : IReportWriter;
    /** processed test cases */
    public var cases (default,null) : List<TestCase>;
    /** failed tests */
    public var fails (default,null) : List<TestFail>;
    /** emmited warnings */
    public var warnings (default,null) : List<TestWarning>;
    /** passed tests without warnings */
    public var successful (default,null) : List<TestSuccess>;
    /** Get finished tests count */
    public var testCount (get,never) : Int;
    /** Total assertions performed */
    public var assertionCount : Int = 0;


    /**
     * Cosntructor
     *
     */
    public function new (writer:IReportWriter) : Void
    {
        cases      = new List();
        fails      = new List();
        warnings   = new List();
        successful = new List();

        this.writer = writer;
    }


    /**
     * Add exceptions of failed tests
     *
     */
    public function addFail (testCase:TestCase, test:String, e:Exception) : Void
    {
        fails.add({
            caseName  : testCase.getClass().getClassName(),
            testName  : test,
            exception : e
        });
    }


    /**
     * Notify about passed test
     *
     */
    public function addSuccess (testCase:TestCase, test:String) : Void
    {
        successful.add({
            caseName : testCase.getClass().getClassName(),
            testName : test
        });
    }


    /**
     * Notify about warning
     *
     */
    public function addWarning (testCase:TestCase, test:String, warning:Warning) : Void
    {
        warnings.add({
            caseName : testCase.getClass().getClassName(),
            testName : test,
            warning  : warning
        });
    }


    /**
     * Output report data
     *
     */
    public function output () : Void
    {
        writer.write(this);
    }


    /**
     * Get summary string for this report.
     *
     */
    public function getSummary () : String
    {
        var failed = fails.length;
        var warned = warnings.length;
        var passed = warned + successful.length;
        var total  = failed + passed;

        var summary = 'Time: $spentTime seconds.\n\n';
        if (fails.length == 0 && warnings.length == 0) {
            summary += 'OK ($total tests, $assertionCount assertions)';
        } else if (fails.length == 0) {
            summary += 'OK, but with risky tests! ($total tests, $assertionCount assertions, $warned warnings)';
        } else {
            summary += 'FAILURES! ($total tests, $failed failures, $warned warnings)';
        }

        return summary;
    }


    /**
     * Setter `endTime`
     *
     */
    private function set_endTime (endTime:Float) : Float
    {
        spentTime = Math.round((endTime - startTime) * 1000) / 1000;

        return this.endTime = endTime;
    }


    /**
     * Getter `testCount`
     *
     */
    private function get_testCount () : Int
    {
        return  successful.length + warnings.length + fails.length;
    }

}//class TestReport