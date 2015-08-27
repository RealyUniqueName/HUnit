package unit;

import hunit.TestCase;
import hunit.TestSuite;


/**
 * Check TestSuite-related features
 *
 */
class TestSuiteTest extends TestCase
{

    /**
     * Check excluding test cases by class name
     *
     */
    public function testExcludeCaseByClassName () : Void
    {
        var suite = new TestSuite(function(v){});
        suite.add(new ExcludeDummyTest());
        suite.add(new NoExcludeDummyTest());

        suite.exclude.push('unit.ExcludeDummyTest');
        suite.run();

        assert.equal(1, suite.report.cases.length);
    }


    /**
     * Check notices added to report
     *
     */
    public function testNotices () : Void
    {
        var notices = Test.self(new NoticeDummyTest()).notices;

        assert.equal(1, notices.length);
    }

}//class TestSuiteTest



class ExcludeDummyTest extends TestCase
{
    public function testStuff() assert.success();
}

class NoExcludeDummyTest extends TestCase
{
    public function testStuff() assert.success();
}

class NoticeDummyTest extends TestCase {
    public function testStuff()
    {
        notice('hello');
        assert.success();
    }
}
