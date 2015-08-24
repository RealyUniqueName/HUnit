package unit;

import hunit.TestCase;
import hunit.warnings.NoAssertionsWarning;
import hunit.warnings.NoTestsWarning;



/**
 * Test warnings
 *
 */
class WarningTest extends TestCase
{

    /**
     * Ensure warning is emitted if no assertions were made
     *
     */
    public function testNoAssertions () : Void
    {
        var warnings = Test.self(new NoAssertionsTest()).warnings;

        assert.equal(1, warnings.length);
        assert.type(NoAssertionsWarning, warnings.first().warning);
    }


    /**
     * Ensure warning is emitted if no tests found in test case
     *
     */
    public function testNoTests () : Void
    {
        var warnings = Test.self(new NoTestsTest()).warnings;

        assert.equal(1, warnings.length);
        assert.type(NoTestsWarning, warnings.first().warning);
    }


}//class WarningTest



/**
 * Emits 'no assertions' warning
 *
 */
private class NoAssertionsTest extends TestCase
{
    public function test_noAssertions () : Void {}
}//class NoAssertionsTest


/**
 * Emits 'no tests' warning
 *
 */
private class NoTestsTest extends TestCase
{

}//class NoTestsTest


