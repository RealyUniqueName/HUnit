package hunit.assert;

import haxe.PosInfos;
import hunit.match.*;
import hunit.match.NotEqualMatch;
import Type;

using hunit.Utils;


/**
 * Make assertion using matchers.
 *
 */
class MatchAssert extends BaseAssert
{
    /** matcher to use against tested values */
    private var expected : Match<Dynamic>;
    /** Value to check */
    private var actual : Dynamic;
    /** User-defined message for failed assertion */
    private var message : Null<String>;


    /**
     * Constructor
     *
     */
    public function new (expected:Match<Dynamic>, actual:Dynamic, message:String = null, ?pos:PosInfos) : Void
    {
        super(pos);

        this.expected = expected;
        this.actual   = actual;
        this.message  = message;
    }


    /**
     * Validate assertion
     *
     */
    override public function validate () : Void
    {
        if (expected.match(actual)) return;

        failed(message == null ? buildMessage() : message);
    }


    /**
     * Generate fail message
     *
     */
    private function buildMessage () : String
    {
        var a = actual.shortenQuote();

        if (expected.isChained()) {
            return 'Failed asserting that $a matches $expected.';
        } else {
            var cls = Type.getClass(expected);

            return switch (cls) {
                case TypeMatch     : 'Failed asserting that ${actualType()} is ' + Type.getClassName(cast(expected, TypeMatch<Dynamic>).type);
                case NotEqualMatch : 'Failed asserting that $a does not equal ' + cast(expected, NotEqualMatch<Dynamic>).value.shortenQuote();
                case EqualMatch    : 'Failed asserting that $a equals ' + cast(expected, EqualMatch<Dynamic>).value.shortenQuote();
                case _             : 'Failed asserting that $a matches $expected.';
            }
        }
    }


    /**
     * Get type name of `actual` value
     *
     */
    private function actualType () : String
    {
        return switch (Type.typeof(actual)) {
            case TClass(c) : Type.getClassName(c);
            case TEnum(e)  : e.getName();
            case TNull     : 'Null';
            case TInt      : 'Int';
            case TFloat    : 'Float';
            case TBool     : 'Bool';
            case TObject   : 'Object';
            case TFunction : 'Function';
            case TUnknown  : 'Unknown Type';
        }
    }

}//class MatchAssert