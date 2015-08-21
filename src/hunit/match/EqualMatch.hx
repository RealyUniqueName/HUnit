package hunit.match;

import hunit.match.Match;
import hunit.Utils;
import Type;

using StringTools;
using hunit.Utils;


/**
 * Match equal value.
 *
 * Compares enums with `Type.enumEq()`
 * Compares functions with `Reflect.compareMethod()`
 * Compares other types with `==`
 */
class EqualMatch<T> extends Match<T>
{
    /** Compare against this value */
    public var value (default,null) : T;


    /**
     * Cosntructor
     *
     */
    public function new (value:T, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        super(previous, chainLogic);
        this.value = value;
    }


    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        try {
            switch (Type.typeof(this.value)) {
                case TFunction: return Reflect.compareMethods(this.value, value);
                case TEnum(_) : return Type.enumEq(this.value, value);
                case _        : return this.value == value;
            }
        } catch (e:Dynamic) {
            return false;
        }
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        var code = Std.string(value).shortenString();

        return (value.hasToString() ? '="$code"' : '=$code');
    }

}//class EqualMatch