package hunit.match;

import haxe.Constraints;
import hunit.exceptions.InvalidTestException;
import hunit.match.Match;
import hunit.match.similar.*;
import Type;

using hunit.Utils;



/**
 * Which types can be used with this matcher
 *
 */
@:enum
private abstract AllowedTypes(String) to String
{
    var ATObject = 'object';
    var ATArray  = 'array';
    var ATMap    = 'map';
    // var ATList   = 'list';
}//abstract AllowedTypes


/**
 * Match objects which fields match fields of `expected` object of this matcher.
 *
 * E.g.:
 * new SimilarObjectMatch({someField:'hello', anotherField:new AnyMatch()});
 * Will match any object with fields `someField` and `anotherField` which set to 'hello' and any value respectively.
 */
@:allow(hunit.match.similar)
class SimilarMatch<T> extends Match<T>
{
    /** root similar matcher for this one */
    private var root : SimilarMatch<T>;
    /** actual matcher */
    private var matcher : Match<T>;
    /** Temporary storage of processed objects to deal with circular references */
    private var checkedObjects : Array<Dynamic>;


    /**
     * Find the type of this object
     *
     */
    static private function getAType (value:Dynamic) : AllowedTypes
    {
        if (Std.is(value, IMap)) return ATMap;

        return switch (Type.typeof(value)) {
            case TClass(String) : throw new InvalidTestException('Invalid `expected` value similar matcher');
            case TClass(Array)  : ATArray;
            case TClass(_)      : ATObject;
            case TObject        : ATObject;
            case _              : throw new InvalidTestException('Invalid `expected` value similar matcher');
        }
    }


    /**
     * Constructor
     *
     */
    public function new (expected:Dynamic, previous:Match<T> = null, chainLogic:MatchChainLogic = null, root:SimilarMatch<T> = null, processedObjects:ObjectCache = null) : Void
    {
        super(previous, chainLogic);
        this.root = root;

        if (processedObjects == null) {
            processedObjects = new ObjectCache();
        }
        processedObjects.set(expected, this);

        if (isRoot()) {
            buildMatcher(this, expected, processedObjects);
        } else {
            buildMatcher(root, expected, processedObjects);
        }
    }


    /**
     * Create underlying matcher for specified expected object
     *
     */
    private function buildMatcher (root:SimilarMatch<T>, expected:Dynamic, processedObjects:ObjectCache) : Void
    {
        switch (getAType(expected)) {
            case ATObject : matcher = new SimilarObjectMatch<T>(root, processedObjects, expected);
            case ATArray  : matcher = new SimilarArrayMatch<T>(root, processedObjects, expected);
            case ATMap    : matcher = new SimilarMapMatch<T>(root, processedObjects, expected);
            case _        : throw new InvalidTestException('Provided value can not be used with `similar` matcher');
        }
    }


    /**
     * Check if this is root matcher
     *
     */
    private function isRoot () : Bool
    {
        return root == null;
    }


    /**
     * Method where Match logic should be implemented.
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        if (isRoot()) {
            checkedObjects = [];
            checkedObjects.push(value);
        } else {
            root.checkedObjects.push(value);
        }

        var result = matcher.checkMatch(value);

        if (isRoot()) {
            checkedObjects = null;
        }

        return result;
    }


    /**
     * Short string code of this Match
     *
     */
    override private function shortCode () : String
    {
        return matcher.shortCode();
    }


    /**
     * Create matcher for specific value
     *
     */
    private function createMatcherForValue (value:Dynamic, processedObjects:ObjectCache) : Match<Dynamic>
    {
        var match : Match<Dynamic> = null;

        if (Std.is(value, Match)) {
            match = value;

        } else {
            //nested fields
            if (value.isObject()) {
                match = processedObjects.get(value);
                if (match == null) {
                    match = new SimilarMatch(value, null, null, this, processedObjects);
                }

            //scalar fields & null
            } else {
                match = new EqualMatch(value);
            }
        }

        return match;
    }


}//class SimilarMatch<T>



/**
 * Temporary storage of objects processed while building `expected` to deal with circular references
 *
 */
class ObjectCache {
    var keys   : Array<Dynamic>;
    var values : Array<SimilarMatch<Dynamic>>;

    public function new () {
        keys   = [];
        values = [];
    }

    public function get(key) {
        if (keys.indexOf(key) < 0) {
            return null;
        } else {
            return values[keys.indexOf(key)];
        }
    }

    public function set(key, value) {
        if (keys.indexOf(key) >= 0) {
            values[keys.indexOf(key)] = value;
        } else {
            keys.push(key);
            values.push(value);
        }
    }
}