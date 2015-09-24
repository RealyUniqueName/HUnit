package unit;

import hunit.exceptions.UnexpectedCallException;
import hunit.TestCase;


class ExpectDummy<T> {
    public var item (default,null) : T;
    public function new (item:T) this.item = item;
    public function setItem(newItem:T) return item = newItem;
    public function someMethod(e:Dynamic) throw e;
    public function csMethod (v:Float) : Void {}
    public function catchUnexpectedCallException() {
        try {
            setItem(null);
        } catch (e:Dynamic) {
            //do not let it to raise further
        }
    }
}


/**
 * Test mocking
 *
 */
class ExpectTest extends TestCase
{

    /**
     * Test expected method calls validated correctly
     *
     */
    public function testExpect () : Void
    {
        var expectedArgument = 'Hello, world';
        var expectedResult   =  expectedArgument;

        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem(expectedArgument).returns(expectedResult);

        m.setItem(expectedArgument);
    }


    /**
     * Test that exceptions thrown by expected methods are validated correctly
     *
     */
    public function testExpect_validateExceptions () : Void
    {
        var exception = 'Hello, world!';

        var m = mock(ExpectDummy, [String]).get();
        expect(m).someMethod().throws(exception);

        expectException(exception);

        m.someMethod(exception);
    }


    /**
     * Check `expect()` correclty validates when expected to be invoked multiple times
     *
     */
    public function testExpect_multipleCalls () : Void
    {
        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().never();

        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().once();
        m.setItem('Hello, world');

        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().any();

        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().atLeast(1);
        m.setItem('Hello, world');
        m.setItem('Hello, world');

        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().exactly(3);
        m.setItem('Hello, world');
        m.setItem('Hello, world');
        m.setItem('Hello, world');
    }


    /**
     * Make sure test will fail even if third-party code caught `UnexpectedCallException`
     *
     */
    public function testExpect_testFails_despiteUserCaughtHUnitException () : Void
    {
        var m = mock(ExpectDummy, [String]).get();
        expect(m).setItem().never();

        m.catchUnexpectedCallException();

        //make sure thrown exception reached test state
        assert.equal(1, __hu_state.pendingExceptions.length);
        assert.type(UnexpectedCallException, __hu_state.pendingExceptions.pop());

        //clear expectations
        __hu_state.expectedCalls.pop();
    }


    /**
     * Description
     */
    public function testExpect_fieldWithFloatArg_doesNotThrowWriteErrorOnCs () : Void
    {
        var m = mock(ExpectDummy, [String]).get();

        expect(m).csMethod(80.).once();

        m.csMethod(80);
    }

}//class ExpectTest
