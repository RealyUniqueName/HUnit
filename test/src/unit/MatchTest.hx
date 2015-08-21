package unit;

import hunit.exceptions.InvalidTestException;
import hunit.TestCase;


enum MatchDummyEnum {
    Item1(v:String);
    Item2(v:String);
}

class MatchDummy {
    public var emptyField  : Dynamic = null;
    public var strField    : String = 'hello';
    public var boolField   : Bool = true;
    public var intField    : Int = 2;
    public var nestedField : {enumField:MatchDummyEnum,?circular:MatchDummy};

    public function new() {
        nestedField = {enumField:Item1('world')};
    }
}


/**
 * Test matchers
 *
 */
class MatchTest extends TestCase
{

    /**
     * `match.any()`
     *
     */
    public function testAny () : Void
    {
        if (match.any().match('some random value')) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.regexp()`
     *
     */
    public function testRegexp () : Void
    {
        if (match.regexp(~/hello/i).match('Hello, world!')) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.equal()`
     *
     */
    public function testEqual () : Void
    {
        if (match.equal('hello').match('hello')) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.notEqual()`
     *
     */
    public function testNotEqual () : Void
    {
        if (match.notEqual('hello').match('world')) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.type()`
     *
     */
    public function testType () : Void
    {
        if (match.type(TestCase).match(this)) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.callback()`
     *
     */
    public function testCallback () : Void
    {
        var matcher = match.callback(function (v) return v == 'hello');

        if (matcher.match('hello')) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.similar()` with objects
     *
     */
    public function testSimilar_objects () : Void
    {
        var actual = new MatchDummy();

        //match with anonymous structure
        var matcher = match.similar({
            emptyField : null,
            strField   : 'hello',
            boolField  : true,
            intField   : match.any()
        });
        if (matcher.match(actual)) {
            assert.success();
        } else {
            assert.fail();
        }

        //match with another instance of the same class
        var matcher = match.similar(new MatchDummy());
        if (matcher.match(actual)) {
            assert.success();
        } else {
            assert.fail();
        }

        //actual does not have required field
        var matcher = match.similar({
            someField: 'some value'
        });
        if (matcher.match(actual)) {
            assert.fail();
        } else {
            assert.success();
        }

        //actual has wrong value of one field
        var matcher = match.similar({
            boolField: false
        });
        if (matcher.match(actual)) {
            assert.fail();
        } else {
            assert.success();
        }
    }


    /**
     * `match.similar()` on inappropriate values
     *
     */
    public function testSimilar_invalid () : Void
    {
        //fail on non-object values
        try {
            match.similar('I am not an object');
            assert.fail();
        } catch (e:InvalidTestException) {
            assert.success();
        }
    }


    /**
     * Test `match.similar()` against objects with circular references
     *
     */
    public function testSimilar_circularReferences () : Void
    {
        var expected = new MatchDummy();
        expected.nestedField.circular = expected;

        var matcher = match.similar(expected);

        var actualNonCircular = new MatchDummy();
        var actualCircular    = new MatchDummy();
        actualCircular.nestedField.circular = actualCircular;

        if (matcher.match(actualNonCircular)) {
            assert.fail();
        } else {
            assert.success();
        }

        if (matcher.match(actualCircular)) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `match.similar()` on arrays
     *
     */
    public function testSimilar_arrays () : Void
    {
        var matcher = match.similar(['hello', match.any()]);

        if (matcher.match(['hello', 'random string'])) {
            assert.success();
        } else {
            assert.fail();
        }

        if (matcher.match(['bye', 'random string'])) {
            assert.fail();
        } else {
            assert.success();
        }

        if (matcher.match(['hello', 'random string', 'wrong length'])) {
            assert.fail();
        } else {
            assert.success();
        }
    }


    /**
     * `match.similar()` on maps
     *
     */
    public function testSimilar_maps () : Void
    {
        var expected : Map<String,Dynamic> = ['hello' => 1, 'world' => match.any()];
        var matcher = match.similar(expected);

        if (matcher.match(['hello' => 1, 'world' => 123])) {
            assert.success();
        } else {
            assert.fail();
        }
    }


    /**
     * `assert.similar()` on arrays of objects, objects of arrays etc.
     *
     */
    public function testSimilar_mixed () : Void
    {
        var expected = new MatchDummy();
        expected.nestedField.circular = expected;

        var actual = new MatchDummy();
        actual.nestedField.circular = actual;

        var matcher = match.similar({
            arrField : [ match.notEqual(1) ],
            arrOfObj : [ new MatchDummy(), expected ],
            str      : 'one'
        });

        var object = {
            arrField : [ 2 ],
            arrOfObj : [ new MatchDummy(), actual ],
            str      : 'one'
        };

        if (matcher.match(object)) {
            assert.success();
        } else {
            assert.fail();
        }

        object.arrField[0] = 1;
        if (matcher.match(object)) {
            assert.fail();
        } else {
            assert.success();
        }
    }

}//class MatchTest