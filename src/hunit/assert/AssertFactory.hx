package hunit.assert;

import haxe.PosInfos;
import hunit.assert.BaseAssert;
import hunit.assert.MatchAssert;
import hunit.exceptions.AssertException;
import hunit.match.Match;
import hunit.TestCase;
import hunit.warnings.ForcedWarning;



/**
 * Provides access to assertions
 *
 */
class AssertFactory
{
    /** Test case which created this factory */
    private var testCase : TestCase;


    /**
     * Cosntructor
     *
     */
    public function new (testCase:TestCase) : Void
    {
        this.testCase = testCase;
    }


    /**
     * Validate `value` against matcher
     *
     */
    public function match<T> (match:Match<T>, value:T, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(match, value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `expected` and `actual` are equal
     *
     */
    public function equal<T> (expected:T, actual:T, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.equal(expected), actual, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `expected` and `actual` are not equal
     *
     */
    public function notEqual<T> (expected:T, actual:T, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.notEqual(expected), actual, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if type of `value` is of `expectedType`
     *
     */
    public function type (expectedType:Class<Dynamic>, value:Dynamic, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.type(expectedType), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `value` is null
     *
     */
    public function isNull (value:Dynamic, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.equal(null), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `value` is not null
     *
     */
    public function notNull (value:Dynamic, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.notEqual(null), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `value` is `true`
     *
     */
    public function isTrue (value:Bool, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.equal(true), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `value` is `false`
     *
     */
    public function isFalse (value:Bool, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.equal(false), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success if `pattern` regexp match `value`
     *
     */
    public function regexp (pattern:EReg, value:String, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.regexp(pattern), value, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Success `expected` and `actual` are similar objects/arrays/maps.
     *
     * Aserting with objects:
     * Object `actual` is allowed to have fields, which do not exist in `expected` object.
     * All fields of `expected` object must have corresponding fields in `actual` object to pass this assertion.
     * It's not necessary for `expected` and `actual` to be instances of the same type.
     * Fields values of `expected` objects can be matchers.
     *
     * Asserting with arrays:
     * To pass this assertion `actual` and `expected` arrays must be of the same length and have corresponding elements match each other.
     * Elements of `expected` array can be matchers.
     *
     * Asserting with maps:
     * `expected` and `actual` maps must have the same set of keys and their corresponding values must match each other.
     * Values of `expected` map can be matchers.
     */
    public function similar (expected:Dynamic, actual:Dynamic, message:String = null, ?pos:PosInfos) : Void
    {
        var assert = new MatchAssert(testCase.match.similar(expected), actual, message, pos);
        testCase.__hu_state.asserted.add(assert);

        assert.validate();
    }


    /**
     * Force test failure
     *
     */
    public function fail (message:String = null, ?pos:PosInfos) : Void
    {
        throw new AssertException(message == null ? 'Forced test failure.' : message, pos);
    }


    /**
     * Force warning
     *
     */
    public function warn (message:String = null, ?pos:PosInfos) : Void
    {
        testCase.__hu_state.warn(new ForcedWarning(message == null ? 'Forced warning' : message));
        testCase.__hu_state.asserted.add(new BaseAssert(pos));
    }


    /**
     * Mark test as successful if there are no other assertions in test
     *
     */
    public function success (?pos:PosInfos) : Void
    {
        testCase.__hu_state.asserted.add(new BaseAssert(pos));
    }


}//class AssertFactory