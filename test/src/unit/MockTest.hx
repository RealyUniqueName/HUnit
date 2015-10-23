package unit;

import hunit.exceptions.InvalidTestException;
import hunit.exceptions.UnexpectedCallException;
import hunit.mock.IMock;
import hunit.TestCase;


class MockDummy<T> {
    static public inline var CONSTRUCTOR_EXCEPTION = 'I am original constructor!';
    public var item (default,null) : T;
    public function new (item:T, anotherArg:Bool = false) this.item = item;
    public function helloWorld () return 'Hello, world!';
    public function withOptionalBasicType (intArg:Int = 1, boolArg:Null<Bool>, ?arg2:Float, ?boolArg:Bool = null) return intArg;
    public function withNullOfClass (nulLArg:Null<MockTest>) : Void {}
    public inline function thisOneIsInlined() trace('You should not see this');
    public function callbackArgument(fn:MockTest->MockTest) {}
    public function callbackReturn() : MockTest->MockTest return null;
    public function notypeReturn() return function (a:MockTest) : MockTest return a;
}


class SimpleMockDummy {
    public var item (default,null) : String;
    public function new (item:String, anotherArg:Bool = false) this.item = item;
    public function parametrized<T,D> (v:T,b:D) : T return v;
}


interface IMockDummy<T> {
    public function setItem (item:T) : T;
    public function method (simple:Bool = false) : IMockDummy<T>;
}

interface ISimpleMockDummy {
    public function setItem (item:String) : String;
}

typedef TDClassDummy<T> = MockDummy<T>;


typedef TDAnonDummy<T> = {
    function new (item:T) : Void;
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
     * Test mock creation on classes without type parameters
     *
     */
    public function testCreate_nonParametrized_class () : Void
    {
        var m = mock(SimpleMockDummy).get();
// expect(m).parametrized(0, 'hello').once();

        assert.type(SimpleMockDummy, m);
        assert.type(IMock, m);
    }


    /**
     * Test mock creation on interfaces without type parameters
     *
     */
    public function testCreate_nonParametrized_interface () : Void
    {
        var m = mock(ISimpleMockDummy).get();

        assert.type(ISimpleMockDummy, m);
        assert.type(IMock, m);
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
     * Ensure mocked interfaces have all methods stubbed by default
     *
     */
    public function testInterfaceMocking_allMethodsStubbedByDefault () : Void
    {
        var m = mock(IMockDummy, [String]).get();

        var result = m.method();
        assert.isNull(result);
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


    /**
     * If user wants to mock inlined methods, HUnit should throw InvalidTestException
     *
     */
    public function testMockingInlinedMethodsShouldThrowError () : Void
    {
        var m = mock(MockDummy, [String]).get();

        try {
            stub(m).thisOneIsInlined();
            assert.fail('Stubbing inlined method should fail');
        } catch (e:InvalidTestException) {
            assert.success();
        }

        try {
            expect(m).thisOneIsInlined();
            assert.fail('Expecting inlined method should fail');
        } catch (e:InvalidTestException) {
            assert.success();
        }
    }


    // /**
    //  * Check anonymous structure typedef mocking ability
    //  *
    //  */
    // @incomplete('Requires mocking typedefs of anonymous structures')
    // public function testTypedefAnonMocking () : Void
    // {
    //     // var m = mock(TDAnonDummy, [String]).get();

    //     // stub(m).setItem().returns('World');
    //     // var result = m.setItem('Hello');
    //     // assert.equal('World', result);
    // }

}//class MockTest
