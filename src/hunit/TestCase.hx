package hunit;

import haxe.PosInfos;
import hunit.assert.AssertFactory;
import hunit.exceptions.ExpectedExceptionData;
import hunit.exceptions.InvalidTestException;
import hunit.match.AnyMatch;
import hunit.mock.IMock;
import hunit.mock.MockData;
import hunit.match.MatchFactory;
import hunit.mock.MockBuilder;
import hunit.Match;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import hunit.utils.MockTypeGenerator;
import hunit.utils.StubCreatorGenerator;
import hunit.utils.ExpectCreatorGenerator;

using hunit.Utils;

#end


/**
 * Base class for tests
 *
 */
@:access(hunit.mock.IMock)
@:rtti
class TestCase
{
    /** Creates patterns for mocked methods' arguments */
    public var match (default,set) : MatchFactory;

    /** assertions */
    public var assert (default,set) : AssertFactory;

    /** Current test state */
    @:noCompletion
    public var __hu_state : Null<TestState>;


    /**
     * Returns mocking config&data associated with `mock`
     *
     */
    @:noCompletion
    static public function getMockData (mock:IMock) : MockData
    {
        return mock.__hu_mock__;
    }


    /**
     * Constructor
     *
     */
    public function new () : Void
    {
        match  = new MatchFactory();
        assert = new AssertFactory(this);
    }


    /**
     * Setup environment before the first test in current test case
     *
     */
    public function setupTestCase () : Void
    {

    }

    /**
     * Setup new environment before each test
     *
     */
    public function setup () : Void
    {

    }


    /**
     * Perform some cleaning after each test
     *
     */
    public function tearDown () : Void
    {

    }


    /**
     * Perform some cleaning after last test in this test case
     *
     */
    public function tearDownTestCase () : Void
    {

    }


    /**
     * Mock specified type
     *
     */
    macro public function mock<T> (eThis:Expr, type:ExprOf<Class<T>>, typeParameters:ExprOf<Array<Class<Dynamic>>> = null) : ExprOf<MockBuilder<T>>
    {
        var generator       = new MockTypeGenerator(type, typeParameters);
        var mockClassExpr   = generator.getTypeDefinition().toClassExpr();
        var builderTypePath = generator.getMockBuilder().getTypeDefinition().toTypePath();

        return macro new $builderTypePath($eThis, $mockClassExpr, $type);
    }


    /**
     * Stub methods of `mock` object
     *
     */
    macro public function stub<T:IMock> (eThis:Expr, mock:ExprOf<IMock>) : Expr
    {
        var mockType  = mock.typeExpr().t;
        if (!mockType.isMock()) {
            Context.error(
                'Provided expression is not a mock. Did you call get() or create() after mock()?',
                Context.currentPos()
            );
        }

        var pos       = Context.currentPos();
        var generator = new StubCreatorGenerator(mockType);
        var typePath  = generator.getTypeDefinition().toTypePath();

        return macro @:pos(pos) new $typePath(hunit.TestCase.getMockData($mock));
    }


    /**
     * Expect method calls of `mock` object
     *
     */
    macro public function expect<T:IMock> (eThis:Expr, mock:ExprOf<IMock>) : Expr
    {
        var mockType  = mock.typeExpr().t;
        if (!mockType.isMock()) {
            Context.error(
                'Provided expression is not a mock. Did you call get() or create() after mock()?',
                Context.currentPos()
            );
        }

        var pos       = Context.currentPos();
        var generator = new ExpectCreatorGenerator(mockType);
        var typePath  = generator.getTypeDefinition().toTypePath();

        return macro @:pos(pos) new $typePath(hunit.TestCase.getMockData($mock));
    }


    /**
     * Assert that test will throw exception which match specified Match
     *
     */
    public function expectException (match:Match<Dynamic> = null, ?pos:PosInfos) : Void
    {
        if (match == null) {
            match = new AnyMatch<Dynamic>();
        }

        __hu_state.expectedException = new ExpectedExceptionData(match, pos);
    }


    /**
     * Setter `match`
     *
     */
    @:noCompletion
    private function set_match (match:MatchFactory) : MatchFactory
    {
        if (this.match != null) {
            throw new InvalidTestException('Matcher factory already set');
        }

        return this.match = match;
    }


    /**
     * Setter for `assert`
     *
     */
    @:noCompletion
    private function set_assert (assert:AssertFactory) : AssertFactory
    {
        if (this.assert != null) {
            throw new InvalidTestException('Assertion factory already set');
        }

        return this.assert = assert;
    }

}//class TestSet