package hunit.match.similar;

import hunit.exceptions.InvalidTestException;
import hunit.match.EqualMatch;
import hunit.match.Match;
import hunit.match.SimilarMatch;
import Type;

using hunit.Utils;


/**
 * Match arrays which elements match corresponding elements of `expected` array of this matcher.
 *
 * E.g.:
 * match.similar(['hello', new AnyMatch()]);
 * Will match any array with the first element equal 'hello' and any value as the second elemant.
 */
class SimilarArrayMatch<T> extends Match<T>
{
    /** expected array elements */
    public var expected : Array<Match<Dynamic>>;
    /** root similar matcher for this one */
    private var root : SimilarMatch<T>;


    /**
     * Constructor
     *
     * @param processedObjects To fight circular references
     */
    public function new (root:SimilarMatch<T>, processedObjects:ObjectCache, expected:Array<Dynamic>, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        if (!Std.is(expected, Array)) {
            throw new InvalidTestException('`expected` value should be an array.');
        }

        super(previous, chainLogic);

        this.root     = root;
        this.expected = getArrayMatchMap(expected, processedObjects);
    }


    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        if (!Std.is(value, Array)) return false;

        var value : Array<Dynamic> = value;
        if (expected.length != value.length) return false;

        var actual : Dynamic;
        var match  : Match<Dynamic>;
        for (i in 0...expected.length) {
            actual = value[i];
            match  = expected[i];

            //circular reference, already checked
            if (Std.is(match, SimilarMatch)) {
                if (root.checkedObjects.indexOf(actual) >= 0) {
                    continue;
                }
            }

            if (!match.match(actual)) return false;
        }

        return true;
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        var parts : Array<String> = expected.map(function(m) return m.toString());
        var str = '[' + parts.join(', ') + ']';

        if (str.length == str.shortenString().length) {
            return str;
        } else {
            str = str.shortenString();
            return str.substr(0, str.length - 6) + '<...>]';
        }
    }


    /**
     * Get array of matchers based on `expected` array
     *
     */
    private function getArrayMatchMap (expected:Array<Dynamic>, processedObjects:ObjectCache) : Array<Match<Dynamic>>
    {
        var matchers : Array<Match<Dynamic>> = [];

        for (i in 0...expected.length) {
            matchers.push(root.createMatcherForValue(expected[i], processedObjects));
        }

        return matchers;
    }


}//class SimilarArrayMatch
