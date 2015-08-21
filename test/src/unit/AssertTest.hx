package unit;

import hunit.exceptions.AssertException;
import hunit.TestCase;


class AssertDummy {
    public var someField = 'hello';
    public function new () {}
}


/**
 * Test assertions
 *
 */
class AssertTest extends TestCase
{

    /**
     * Check `assert.fail()` & `assert.success()`
     *
     */
    public function testFailSuccess () : Void
    {
        try {
            assert.fail();
        } catch (e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.match()`
     *
     */
    public function testMatch () : Void
    {
        assert.match(match.equal(1), 1);

        try {
            assert.match(match.equal('expected'), 'actual');
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.equal()`
     *
     */
    public function testEqual () : Void
    {
        assert.equal(1, 1);

        var classInstance = new AssertDummy();
        assert.equal(classInstance, classInstance);

        var anonymousStructure = {hello:'world'};
        assert.equal(anonymousStructure, anonymousStructure);

        assert.equal(AssertDummy, AssertDummy);

        try {
            assert.equal('expected', 'actual');
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.notEequal()`
     *
     */
    public function testNotEqual () : Void
    {
        assert.notEqual(2, 1);
        assert.notEqual(new AssertDummy(), new AssertDummy());
        assert.notEqual({hello:'world'}, {hello:'world'});

        try {
            assert.notEqual('hello', 'hello');
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.type()`
     *
     */
    public function testType () : Void
    {
        assert.type(AssertDummy, new AssertDummy());

        try {
            assert.type(AssertTest, new AssertDummy());
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.isNull()`
     *
     */
    public function testIsNull () : Void
    {
        assert.isNull(null);

        try {
            assert.isNull('not null');
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.notNull()`
     *
     */
    public function testNotNull () : Void
    {
        assert.notNull('not null');

        try {
            assert.notNull(null);
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.isTrue()`
     *
     */
    public function testIsTrue () : Void
    {
        assert.isTrue(true);

        try {
            assert.isTrue(false);
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.isFalse()`
     *
     */
    public function testIsFalse () : Void
    {
        assert.isFalse(false);

        try {
            assert.isFalse(true);
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * Check `assert.regex()`
     *
     */
    public function testRegex () : Void
    {
        assert.regexp(~/hello/i, 'Hello, world!');

        try {
            assert.regexp(~/no match/, 'Hello, world!');
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }


    /**
     * `assert.similar()`
     *
     */
    public function testSimilar () : Void
    {
        var dummy = new AssertDummy();
        dummy.someField = 'hello';

        assert.similar({someField:'hello'}, dummy);

        try {
            assert.similar({someField:'world'}, dummy);
            assert.fail();
        } catch(e:AssertException) {
            assert.success();
        }
    }

}//class AssertTest

