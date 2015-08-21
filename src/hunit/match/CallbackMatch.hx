package hunit.match;

import hunit.match.Match;



/**
 * Match any value
 *
 */
class CallbackMatch<T> extends hunit.match.Match<T>
{
    /** Callback to verify values */
    private var verify : T->Bool;


    /**
     * Cosntructor
     *
     */
    public function new (verify:T->Bool, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        super(previous, chainLogic);

        this.verify = verify;
    }

    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        return verify(value);
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        return 'CALLBACK';
    }

}//class CallbackMatch