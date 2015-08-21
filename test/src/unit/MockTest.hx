package unit;

import hunit.exceptions.UnexpectedCallException;
import hunit.mock.IMock;
import hunit.TestCase;


class MockDummy<T> {
    static public inline var CONSTRUCTOR_EXCEPTION = 'I am original constructor!';
    public var item (default,null) : T;
    public function new (item:T) this.item = item;
    public function helloWorld () return 'Hello, world!';
}


/**
 * Test mocking
 *
 */
class MockTest extends TestCase
{

    /**
     * Test mock creation without invoking original constructor
     *
     */
    public function testCreate_withoutOriginalConstructor () : Void
    {
        var m = mock(MockDummy, [String]).get();

        assert.type(MockDummy, m);
        assert.type(IMock, m);
        assert.equal(null, m.item);
    }


    /**
     * Test mock creation with invoking original constructor
     *
     */
    public function testCreate_invokeOriginalConstructor () : Void
    {
        var item = 'hello';

        var m = mock(MockDummy, [String]).create(item);

        assert.type(MockDummy, m);
        assert.type(IMock, m);
        assert.equal(item, m.item);
    }


    /**
     * Check strict mode
     *
     */
    public function testStrict () : Void
    {
        var m = mock(MockDummy, [String]).strict().get();

        try {
            m.helloWorld();
            assert.fail();
        } catch(e:UnexpectedCallException) {
            assert.success();
            //avoid failing test
            __hu_state.pendingExceptions.remove(e);
        }
    }

}//class MockTest
