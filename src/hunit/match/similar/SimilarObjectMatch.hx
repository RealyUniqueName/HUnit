package hunit.match.similar;

import hunit.exceptions.InvalidTestException;
import hunit.match.EqualMatch;
import hunit.match.Match;
import hunit.match.SimilarMatch;
import Type;

using hunit.Utils;


/**
 * Match objects which fields match fields of `expected` object of this matcher.
 *
 * E.g.:
 * match.similar({someField:'hello', anotherField:new AnyMatch()});
 * Will match any object with fields `someField` and `anotherField` which set to 'hello' and any value respectively.
 */
class SimilarObjectMatch<T> extends Match<T>
{
    /** expected fields values */
    public var expected : Map<String,Match<Dynamic>>;
    /** root similar matcher for this one */
    private var root : SimilarMatch<T>;


    /**
     * Constructor
     *
     * @param processedObjects To fight circular references
     */
    public function new (root:SimilarMatch<T>, processedObjects:ObjectCache, expected:Dynamic, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        if (!expected.isObject()) {
            throw new InvalidTestException('`expected` value should be an object.');
        }

        super(previous, chainLogic);

        this.root     = root;
        this.expected = getFieldMatchMap(expected, processedObjects);
    }


    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        var valueMap = getFieldValueMap(value);

        var actual : Dynamic;
        var match  : Match<Dynamic>;
        for (field in expected.keys()) {
            if (!valueMap.exists(field)) return false;

            actual = valueMap.get(field);
            match  = expected.get(field);

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
        for (field in expected.keys()) {
            parts.unshift(field + ':' + expected.get(field).toString());
        }
        var str = '{' + parts.join(', ') + '}';

        if (str.length == str.shortenString().length) {
            return str;
        } else {
            str = str.shortenString();
            return str.substr(0, str.length - 6) + '<...>}';
        }
    }


    /**
     * Get map of matchers based on `object` fields
     *
     */
    private function getFieldMatchMap (object:Dynamic, processedObjects:ObjectCache) : Map<String,Match<Dynamic>>
    {
        var fieldValue = getFieldValueMap(object);
        var fieldMatch = new Map<String,Match<Dynamic>>();

        var value : Dynamic;
        for (field in fieldValue.keys()) {
            value = fieldValue.get(field);

            fieldMatch.set(field, root.createMatcherForValue(value, processedObjects));
        }

        return fieldMatch;
    }


    /**
     * Get map of field and values of `object`
     *
     */
    static private function getFieldValueMap (object:Dynamic) : Map<String,Dynamic>
    {
        var map : Map<String,Dynamic> = new Map();

        var fields : Array<String> =  switch (Type.typeof(object)) {
            case TObject        : Reflect.fields(object);
            case TClass(String) : [];
            case TClass(cls)    : Type.getInstanceFields(cls);
            case _              : [];
        }

        for (field in fields) {
            map.set(field, Reflect.getProperty(object, field));
        }

        return map;
    }


}//class SimilarObjectMatch