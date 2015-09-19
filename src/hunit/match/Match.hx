package hunit.match;

import hunit.match.GenericMatchFactory;
import hunit.match.MatchFailDescription;


/**
 * Logical and/or for Match chaining
 *
 */
enum MatchChainLogic
{
    And;
    Or;
}//enum MatchChainLogic


/**
 * Arguments expectations for method calls in mocked objects
 *
 */
class Match<T>
{
    /** For mathcers chaining */
    private var previous : Null<Match<T>>;
    /** and/or with `previous` Match */
    private var chainLogic : Null<MatchChainLogic>;

    /** To chain argument Matchs */
    public var and (get,never) : GenericMatchFactory<T>;
    private var _and : GenericMatchFactory<T>;
    /** To chain argument Matchs */
    public var or (get,never) : GenericMatchFactory<T>;
    private var _or : GenericMatchFactory<T>;

    /** If previous match failed, this field should contain reason description. */
    // private var fail : MatchFailDescription;


    /**
     * Constructor
     *
     * @param previous For Matchs chaining
     */
    public function new (previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        this.previous   = previous;
        this.chainLogic = chainLogic;
    }


    /**
     * Check if this Match match `value`
     *
     */
    @:final
    public function match (value:Dynamic) : Bool
    {
        var result = checkMatch(value);

        var current = this;
        while (current.chainLogic != null) {
            switch (current.chainLogic) {
                case And  : result = result && current.previous.checkMatch(value);
                case Or   : result = result || current.previous.checkMatch(value);
            }

            current = current.previous;
        }

        return result;
    }


    // /**
    //  * Get description of failed match reason
    //  */
    // @:noCompletion
    // public function getFail () : MatchFailDescription
    // {
    //     return null;
    // }


    /**
     * Check if this matcher has previous matcher, which also will be checked against verified values.
     *
     */
    @:noCompletion
    public function isChained () : Bool
    {
        return previous != null;
    }


    /**
     * Get string representation of this Match
     *
     */
    @:noCompletion
    public function toString () : String
    {
        var code = shortCode();

        if (previous == null) {
            return '[$code]';
        } else {
            var result  = '$code';
            var current = this;
            while (current.chainLogic != null) {
                switch (current.chainLogic) {
                    case And  : result = current.previous.shortCode() + ' && $result';
                    case Or   : result = current.previous.shortCode() + ' || $result';
                }
                current = current.previous;
            }

            return '[$result]';
        }
    }


    /**
     * Short string code of this Match
     *
     */
    private function shortCode () : String
    {
        throw 'To be overriden';
    }


    /**
     * Method where Match logic should be implemented.
     *
     */
    private function checkMatch (value:Dynamic) : Bool
    {
        throw 'To be overriden';
    }


    /**
     * Getter `and`
     *
     */
    private function get_and () : GenericMatchFactory<T>
    {
        if (_and == null) {
            _and = new GenericMatchFactory<T>(this, And);
        }

        return _and;
    }


    /**
     * Getter `or`
     *
     */
    private function get_or () : GenericMatchFactory<T>
    {
        if (_or == null) {
            _or = new GenericMatchFactory<T>(this, Or);
        }

        return _or;
    }


}//class Match


