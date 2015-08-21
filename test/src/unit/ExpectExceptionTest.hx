package unit;

import hunit.exceptions.NoExpectedException;
import hunit.TestCase;


/**
 * Description
 *
 */
class ExpectExceptionTest extends TestCase
{

    /**
     * Check that test passes when expected exception is thrown
     *
     */
    public function testExpectException_testPass () : Void
    {
        var e = 'I am random exception';

        expectException(e);

        throw e;
    }


    /**
     * Check that test fails when expected exception is not thrown
     *
     */
    public function testExpectException_testFail () : Void
    {
        var fails = Test.self(new ExperimentalCase()).fails;

        assert.equal(1, fails.length);
        assert.type(NoExpectedException, fails.first().exception);
    }


}//class ExpectExceptionTest




/**
 * To test failed tests
 *
 */
private class ExperimentalCase extends TestCase
{

    /**
     * Fail test with 'no expected exception' error
     *
     */
    public function testNoExpectedException () : Void
    {
        expectException('You will not throw!');
    }

}//class ExperimentalCase