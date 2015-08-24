package unit;

import hunit.TestCase;
import hunit.TestSuite;
import hunit.warnings.IncompleteTestWarning;



/**
 * Check declared meta support
 *
 */
class MetaTest extends TestCase
{

    /**
     * Ensure @incomplete meta is working
     *
     */
    public function testIncompleteTest () : Void
    {
        var report = Test.self(new IncompleteTest());

        assert.equal(1, report.warnings.length);

        var warning = report.warnings.first().warning;
        assert.type(IncompleteTestWarning, warning);
        assert.equal('details', warning.message);
    }


    /**
     * If user wants @group to run tests assigned to specified group only
     *
     */
    public function testGroupRunsOnlyIncludedTests () : Void
    {
        var suite = new TestSuite(function(v:Dynamic){});
        suite.groups.push('groupTest');
        suite.shutDownStandaloneFlashPlayer = false;
        suite.add(new GroupDummyTest());
        suite.run();

        var report = suite.report;

        assert.equal(1, report.testCount);
        assert.equal('testInGroup', report.successful.first().testName);
    }


    /**
     * If user wants @group to exclude tests assigned to specified group
     *
     */
    public function testGroupExcludesTests () : Void
    {
        var suite = new TestSuite(function(v:Dynamic){});
        suite.excludeGroups.push('groupTest');
        suite.shutDownStandaloneFlashPlayer = false;
        suite.add(new GroupDummyTest());
        suite.run();

        var report = suite.report;

        assert.equal(1, report.testCount);
        assert.equal('testNotInGroup', report.successful.first().testName);
    }


    /**
     * Methods marked with @test meta should be considered as test methods too.
     *
     */
    public function testTestMeta () : Void
    {
        var report = Test.self(new TestDummyTest());

        assert.equal(2, report.testCount);
    }

}//class MetaTest



/**
 * Emits 'incomplete test' warning
 *
 */
private class IncompleteTest extends TestCase
{
    @incomplete('details')
    public function test_incomplete () : Void {}
}//class IncompleteTest



private class GroupDummyTest extends TestCase
{
    @group('groupTest')
    public function testInGroup () assert.success();

    public function testNotInGroup () assert.success();
}


private class TestDummyTest extends TestCase
{
    @test
    public function withTestMeta () assert.success();

    public function testWithTestPrefix () assert.success();
}