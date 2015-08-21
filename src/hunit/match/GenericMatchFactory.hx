package hunit.match;

import hunit.match.AnyMatch;
import hunit.match.EqualMatch;
import hunit.match.Match;
import hunit.match.TypeMatch;



/**
 * Arguments/returns expectations for method calls in mocked objects
 *
 */
class GenericMatchFactory<T>
{
    /** If this factory is used for Matchs chaining, this field will point to previous Match */
    private var previous : Null<Match<T>>;
    /** and/or with `previous` Match */
    private var chainLogic : MatchChainLogic;


    /**
     * Constructor
     *
     */
    public function new (previous:Null<Match<T>>, chainLogic:MatchChainLogic) : Void
    {
        this.previous   = previous;
        this.chainLogic = chainLogic;
    }


    /**
     * Match any value
     *
     */
    public function any () : AnyMatch<Dynamic>
    {
        return new AnyMatch<Dynamic>(previous, chainLogic);
    }


    /**
     * Match values of the specified `type`
     *
     */
    public function type (type:Class<T>) : TypeMatch<T>
    {
        return new TypeMatch(type, previous, chainLogic);
    }


    /**
     * Match strings which match `pattern`
     *
     */
    public function regexp (pattern:EReg) : ERegMatch<T>
    {
        return new ERegMatch(pattern);
    }


    /**
     * Match objects wich fields values match corresponding fields values of `pattern`.
     *
     * Fields of `pattern` can contain matchers.
     *
     */
    public function similar (pattern:Dynamic) : SimilarMatch<T>
    {
        return new SimilarMatch(pattern);
    }


    /**
     * Match values which are equal to `value`
     *
     */
    public function equal (value:T) : EqualMatch<T>
    {
        return new EqualMatch(value, previous, chainLogic);
    }


    /**
     * Match values which are not equal to `value`
     *
     */
    public function notEqual (value:T) : Match<T>
    {
        return new NotEqualMatch(value, previous, chainLogic);
    }


    /**
     * Match if `verify()` returns `true` when invoked against verified value
     *
     */
    public function callback (verify:T->Bool) : CallbackMatch<T>
    {
        return new CallbackMatch(verify);
    }


}//class GenericMatchFactory


