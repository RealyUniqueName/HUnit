package hunit.match;

import hunit.match.AnyMatch;
import hunit.match.EqualMatch;
import hunit.match.ERegMatch;
import hunit.match.Match;
import hunit.match.*;
import hunit.match.TypeMatch;



/**
 * Arguments/returns expectations for method calls in mocked objects
 *
 */
class MatchFactory
{

    /**
     * Constructor
     *
     */
    public function new () : Void
    {
    }


    /**
     * Match any value
     *
     */
    public function any<T> () : AnyMatch<T>
    {
        return new AnyMatch<T>();
    }


    /**
     * Match values of the specified `type`
     *
     */
    public function type<T> (type:Class<T>) : TypeMatch<T>
    {
        return new TypeMatch(type);
    }


    /**
     * Match strings which match `pattern`
     *
     */
    public function regexp (pattern:EReg) : ERegMatch<String>
    {
        return new ERegMatch<String>(pattern);
    }


    /**
     * Match objects which fields values match corresponding fields values of `pattern`.
     *
     * Fields of `pattern` can contain matchers.
     *
     */
    public function similar (pattern:Dynamic) : SimilarMatch<Dynamic>
    {
        return new SimilarMatch(pattern);
    }


    /**
     * Match values which are equal to `value`
     *
     */
    public function equal<T> (value:T) : EqualMatch<T>
    {
        return new EqualMatch<T>(value);
    }


    /**
     * Match values which are not equal to `value`
     *
     */
    public function notEqual<T> (value:T) : NotEqualMatch<T>
    {
        return new NotEqualMatch<T>(value);
    }


    /**
     * Match if `verify()` returns `true` when invoked against verified value
     *
     */
    public function callback<T> (verify:T->Bool) : CallbackMatch<T>
    {
        return new CallbackMatch<T>(verify);
    }


}//class MatchFactory


