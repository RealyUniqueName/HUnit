package hunit.match.similar;

import hunit.exceptions.InvalidTestException;
import hunit.match.EqualMatch;
import hunit.match.Match;
import hunit.match.SimilarMatch;
import haxe.Constraints;
import Type;

using hunit.Utils;


/**
 * Match maps with the same set of keys and matching corresponding values.
 *
 * E.g.:
 * match.similar(['hello' => new AnyMatch()]);
 * Will match any map with the single key `hello` and any value stored under that key.
 */
class SimilarMapMatch<T> extends Match<T>
{
    /** expected array elements */
    public var expected : DynamicMatchMap;
    /** root similar matcher for this one */
    private var root : SimilarMatch<T>;


    /**
     * Constructor
     *
     * @param processedObjects To fight circular references
     */
    public function new (root:SimilarMatch<T>, processedObjects:ObjectCache, expected:Dynamic, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        if (!Std.is(expected, IMap)) {
            throw new InvalidTestException('`expected` value should be an `haxe.Constraints.IMap` instance.');
        }

        super(previous, chainLogic);

        this.root     = root;
        this.expected = getMatchMap(expected, processedObjects);
    }


    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        if (!Std.is(value, IMap)) return false;

        var value : IMap<Dynamic,Dynamic> = value;

        var cnt = 0;
        for (k in value.keys()) cnt ++;
        for (k in expected.keys()) cnt --;
        if (cnt != 0) return false;

        var actual : Dynamic;
        var match  : Match<Dynamic>;
        for (key in expected.keys()) {
            actual = value.get(key);
            match  = expected.get(key);

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
        var parts : Array<String> = [];
        for (key in expected.keys()) {
            parts.push(key + '=>' + expected.get(key).toString());
        }
        var str = '[' + parts.join(', ') + ']';

        if (str.length == str.shortenString().length) {
            return str;
        } else {
            str = str.shortenString();
            return str.substr(0, str.length - 6) + '<...>]';
        }
    }


    /**
     * Get map of matchers based on `expected` map
     *
     */
    private function getMatchMap (expected:IMap<Dynamic,Dynamic>, processedObjects:ObjectCache) : DynamicMatchMap
    {
        var map = new DynamicMatchMap();

        for (key in expected.keys()) {
            map.set(key, root.createMatcherForValue(expected.get(key), processedObjects));
        }

        return map;
    }


}//class SimilarMapMatch


// typedef DynamicMatchMap = haxe.ds.ObjectMap<Dynamic,Dynamic>;


/**
* To be able to store any data in map keys
*/
private class DynamicMatchMap {
    var keyList   : Array<Dynamic>;
    var valueList : Array<Match<Dynamic>>;

    public function new () {
        keyList   = [];
        valueList = [];
    }

    public function keys()          return keyList;
    public function exists(key)     return keyList.indexOf(key) >= 0;
    public function get(key)        return (!exists(key) ? null : valueList[keyList.indexOf(key)]);
    public function set(key, value)
    {
        if (keyList.indexOf(key) >= 0) {
            valueList[keyList.indexOf(key)] = value;
        } else {
            keyList.push(key);
            valueList.push(value);
        }
    }
}
