package hunit.match;



/**
 * Information on failed match
 *
 */
class MatchFailDescription
{

    /** What was expected */
    public var expected : String;
    /** What actually was */
    public var actual : String;


    /**
     * Constructor
     */
    public function new (expected:String = null, actual:String = null) : Void
    {
        this.expected = expected;
        this.actual   = actual;
    }

}//class MatchFailDescription