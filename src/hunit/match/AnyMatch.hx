package hunit.match;



/**
 * Match any value
 *
 */
class AnyMatch<T> extends Match<T>
{

    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        return true;
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        return 'ANY';
    }

}//class AnyMatch