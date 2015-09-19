package ;

import haxe.CallStack;
import haxe.macro.Expr;
import hunit.TestSuite;

using hunit.Utils;


/**
 * To use as default entry point for test suites where no additional setup is required.
 *
 */
class HUnit
{

    /**
     * If you don't need any special tests suite setup, use this method as main function in your hxml.
     * E.g.:
     *  -main HUnit
     *  -D HUNIT_TEST_DIR="path/to/test/cases"
     */
    static public function main () : Void
    {
        Exception.processCallStackOnCreation = processExceptionStack;

        var suite = new TestSuite();
        addTestsFromHUnitFlag(suite);
        suite.run();
    }


    /**
     * Search for tests in `-D HUNIT_TEST_DIR="path/to/test/cases` define and add them to test `suite`
     *
     */
    macro static public function addTestsFromHUnitFlag (suite:ExprOf<TestSuite>) : Expr
    {
        if (haxe.macro.Context.defined('HUNIT_TEST_DIR')) {
            return suite.addTests();
        } else {
            return macro {};
        }
    }


    /**
     * Remove call stack items which will be common for all exceptions in tests if `-main HUnit` is used.
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

}//class HUnit