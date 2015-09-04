package ;

import haxe.CallStack;
import hunit.report.TestReport;
import hunit.TestCase;
import hunit.TestSuite;

/**
 * Test HUnit with HUnit
 *
 */
class Test extends TestSuite
{

    /**
     * Entry point
     *
     */
    static public function main () : Void
    {
        Exception.processCallStackOnCreation = processExceptionStack;

        var suite = new TestSuite();
        suite.shutDownStandaloneFlashPlayer = false;
        suite.addDirectory('unit');
        suite.run();

        finalCheck(suite.report);

        #if flash
        flash.Lib.fscommand('quit');
        #end
    }


    /**
     * To simplify testing HUnit by itself.
     *
     * Creates test suite, adds `testCase`, runs tests and returns tests report
     */
    static public function self (testCase:TestCase) : TestReport
    {
        var suite = new TestSuite(function(v){});
        suite.shutDownStandaloneFlashPlayer = false;
        suite.add(testCase);
        suite.run();

        return suite.report;
    }


    /**
     * Final check that HUnit's testing loop works ok
     *
     */
    static private function finalCheck (report:TestReport) : Void
    {
        trace('Traces restored');

        var totalCases = 11;
        var totalTests = 61;

        if (report.fails.length != 0 || report.warnings.length != 0) return;
        #if HUNIT_GROUP return; #end

        if (report.cases.length != totalCases) throw new Exception('Amount of test cases does not match: $totalCases expected, ${report.cases.length} actual.');
        if (report.successful.length != totalTests) throw new Exception('Amount of tests does not match: $totalTests expected, ${report.successful.length} actual.');
    }


    /**
     * Remove call stack items which will be common for all exceptions.
     *
     */
    static private function processExceptionStack (stack:Array<StackItem>) : Array<StackItem>
    {
        #if neko        var count = 5;
        #elseif cpp     var count = 4;
        #elseif js      var count = 4;
        #elseif php     var count = 4;
        #elseif cs      var count = 8;
        #elseif java    var count = 7;
        #elseif flash   var count = 4;
        #else           var count = 1;
        #end

        return stack.slice(0, -count);
    }

}//class Test