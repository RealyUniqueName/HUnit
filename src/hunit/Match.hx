package hunit;


import hunit.match.Match in RealMatch;
import hunit.match.AnyMatch;
import hunit.match.EqualMatch;



/**
 * Creates `EqualMatch<T>` instances from non-Match values
 *
 */
abstract Match<T>(RealMatch<T>) from RealMatch<T> to RealMatch<T>
{

    /**
     * Create Match from any value
     *
     */
    @:from static private function fromMatcher<T> (value:RealMatch<T>) : Match<T>
    {
        return value;
    }


    /**
     * Create Match from any value
     *
     */
    @:from static private function fromValue<T> (value:Null<T>) : Match<T>
    {
        if (value == null) {
            return new AnyMatch<T>();
        } else {
            return new EqualMatch<T>(value);
        }
    }


}//abstract Match<T>