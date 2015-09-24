package hunit;


import hunit.match.Match in RealMatch;
import hunit.match.AnyMatch;
import hunit.match.EqualMatch;



/**
 * Creates `EqualMatch<T>` instances from non-Match values
 *
 */
abstract Match<T>(Dynamic) from RealMatch<T> to RealMatch<T>
{


    /**
     * Create Match from any value
     *
     */
    @:from static private function fromValue<T> (value:Null<T>) : Match<T>
    {
        if (value == null) {
            return new Match<T>(new AnyMatch<T>());
        } else {
            return new Match<T>(value);
        }
    }


    /**
     * Constructor
     */
    public function new (value:Dynamic) : Void
    {
        if (Std.is(value, RealMatch)) {
            this = value;
        } else {
            this = new EqualMatch<Dynamic>(value);
        }
    }


}//abstract Match<T>