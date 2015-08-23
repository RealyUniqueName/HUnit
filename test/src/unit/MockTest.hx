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


interface IMockDummy<T> {
    public function setItem (item:T) : T;
}


typedef TDClassDummy<T> = MockDummy<T>;


typedef TDAnonDummy<T> = {
    function setItem (item:T) : T;
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


    /**
     * Check interface mocking ability
     *
     */
    public function testInterfaceMocking () : Void
    {
        var m = mock(IMockDummy, [String]).get();

        stub(m).setItem().returns('World');
        var result = m.setItem('Hello');
        assert.equal('World', result);
    }


    /**
     * Check class/interface typedef mocking ability
     *
     */
    public function testTypedefClassMocking () : Void
    {
        var m = mock(TDClassDummy, [String]).get();

        assert.type(MockDummy, m);
        assert.type(IMock, m);
    }


    // /**
    //  * Check anonymous structure typedef mocking ability
    //  *
    //  */
    // public function testTypedefAnonMocking () : Void
    // {
    //     var m = mock(TDAnonDummy, [String]).get();

    //     stub(m).setItem().returns('World');
    //     var result = m.setItem('Hello');
    //     assert.equal('World', result);
    // }

}//class MockTest
