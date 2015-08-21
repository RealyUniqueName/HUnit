package unit;

import haxe.CallStack;
import hunit.exceptions.InvalidTestException;
import hunit.TestCase;


class StubDummy<T> {
    static public inline var EXCEPTION_MESSAGE = 'I am original exception';
    public var item (default,null) : T;
    public function new (item:T) this.item = item;
    public function setItem(newItem:T) return item = newItem;
    public function raiseException() throw EXCEPTION_MESSAGE;
}


/**
 * Test methods mocking
 *
 */
class StubTest extends TestCase
{

    /**
     * Test mocked method returns `null` by default.
     *
     */
    public function testStub_returnsNullByDefault () : Void
    {
        var m = mock(StubDummy, [String]).get();
        stub(m).setItem();

        var result = m.setItem('random string');

        assert.isNull(result);
    }


    /**
     * Test mocked method returns predefined value.
     *
     */
    public function testStub_returnsPredefinedValue () : Void
    {
        var expectedArgument = 'Hello';
        var expectedResult   = 'World';

        var m = mock(StubDummy, [String]).get();
        stub(m).setItem(expectedArgument).returns(expectedResult);

        var result = m.setItem(expectedArgument);

        assert.equal(expectedResult, result);
    }


    /**
     * Ensure mocked method throws predefined exception
     *
     */
    public function testStub_throwsPredefinedException () : Void
    {
        var exception = 'Hello, world!';

        var m = mock(StubDummy, [String]).get();
        stub(m).setItem().throws(exception);

        expectException(exception);

        m.setItem('oops');
    }


    /**
     * Test `stub(mock).someMethod().implement(callback)`
     *
     */
    public function testStub_customImplementation () : Void
    {
        var m = mock(StubDummy, [String]).get();
        stub(m).setItem().implement(function(item) return '$item and $item');

        var result = m.setItem('rock');

        assert.equal('rock and rock', result);
    }


    /**
     * Test stubbing all methods by default
     *
     */
    public function testStub_stubAll () : Void
    {
        var initialItem = 'initial';
        var m = mock(StubDummy, [String]).stubAll().create(initialItem);

        var stubResult = m.setItem(initialItem);

        assert.equal(initialItem, m.item);
        assert.isNull(stubResult);
    }


    /**
     * Test stubbing all methods by default and then unstubbing single method
     *
     */
    public function testStub_unstub() : Void
    {
        var initialItem = 'initial';
        var m = mock(StubDummy, [String]).stubAll().create(initialItem);

        expect(m).setItem().unstub();

        //stubbing unstubbed methods is not allowed
        try {
            stub(m).setItem();
            assert.fail();
        } catch(e:InvalidTestException) {
            assert.success();
        }

        //make sure unstubbed method executes original code
        var expected = 'hello';
        var actual   = m.setItem(expected);
        assert.equal(expected, actual);
        assert.equal(expected, m.item);
    }


    /**
     * Test `unstub()` fails on methods which were stubbed directly with `stub()`
     *
     */
    public function testStub_unstubFailIfStubbedDirectly() : Void
    {
        var initialItem = 'initial';
        var m = mock(StubDummy, [String]).stubAll().create(initialItem);

        stub(m).setItem();

        try {
            expect(m).setItem().unstub();
            assert.fail();
        } catch (e:InvalidTestException) {
            assert.success();
        }
    }

}//class StubTest