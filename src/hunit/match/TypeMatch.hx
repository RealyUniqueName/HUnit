package hunit.match;

import hunit.match.Match;
import Type.ValueType;


/**
 * Match values of specified type
 *
 */
class TypeMatch<T> extends Match<T>
{

    /** Required type */
    public var type (default,null) : Class<T>;


    /**
     * Cosntructor
     *
     */
    public function new (type:Class<T>, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        super(previous, chainLogic);
        this.type = type;
    }

    /**
     * Check matching
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        return value != null && Std.is(value, type);
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        return 'Class<' + Type.getClassName(type) + '>';
    }

}//class AnyMatch