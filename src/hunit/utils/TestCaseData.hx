package hunit.utils;

import haxe.Constraints;
import haxe.rtti.Rtti;
import haxe.rtti.CType;
import haxe.unit.TestCase;
import hunit.exceptions.CircularTestDependencyException;
import hunit.TestCase;

using StringTools;
using Type;
using Reflect;
using hunit.utils.CTypeClassFieldUtils;


typedef TestData = {
    name          : String,
    callback      : Function,
    isIncomplete  : Bool,
    incompleteMsg : String,
    groups        : Array<String>,
    depends       : Array<String>
}


/**
 * Collects configuration of a test case
 */
class TestCaseData
{
    /** Class name of test case */
    public var className (get,never) : String;
    /** File where test case is declared */
    public var file (get,never) : Null<String>;
    /** total amount of tests in this case */
    public var totalTestCount (get,never) : Int;

    /** processed test case */
    private var testCase (default,set) : TestCase;
    /** rtti data for a testCase */
    private var rtti : Classdef;
    /** list of tests in test case */
    private var tests : Array<TestData>;
    /** Default groups to assign tests to */
    private var defaultGroups : Array<String>;


    /**
     * Get list of test which depend on `test`
     *
     */
    static public function getDependent (test:TestData, list:Array<TestData>, dependencyStack:Array<TestData> = null) : Array<TestData>
    {
        var dependent : Array<TestData> = [];

        if (dependencyStack != null) {
            if (dependencyStack.indexOf(test) >= 0) {
                throw new CircularTestDependencyException('Tests with circular dependancies detected. Check @depends() metas.');
            }
            dependencyStack.push(test);
        }

        for (t in list) {
            if (t == test) continue;

            if (t.depends.indexOf(test.name) >= 0) {
                dependent.push(t);
                var subStack = (dependencyStack == null ? null : dependencyStack.copy());
                dependent = dependent.concat(getDependent(t, list, subStack));
            }
        }

        return dependent;
    }


    /**
     * Sort list so that dependent tests moved to the end of list
     *
     */
    static private function sortByDependencies (list:Array<TestData>) : Array<TestData>
    {
        if (list.length == 0) return [];

        var result : Array<TestData> = list.copy();
        result.sort(function(a, b) return a.depends.length - b.depends.length);
        if (result[0].depends.length > 0) {
            throw new CircularTestDependencyException("Can't find tests without dependencies.");
        }

        var idx = 0;
        // var current : TestData;
        var dependent : Array<TestData>;
        while (idx < list.length) {
            dependent = getDependent(result[idx], result, []);

            //move to the end
            for (test in dependent) {
                result.remove(test);
                result.push(test);
            }

            idx ++;
        }

        return result;
    }


    /**
     * Constructor
     *
     */
    public function new (testCase:TestCase) : Void
    {
        tests = [];
        defaultGroups = [];
        this.testCase = testCase;

        processTestCaseRttiMeta();

        gatherTestData();
    }


    /**
     * Get tests of `testCase`
     *
     * @param group Returns tests from this group only
     */
    public function getTests (groups:Array<String> = null, excludeGroups:Array<String> = null) : Array<TestData>
    {
        var result = (
            groups == null || groups.length == 0
                ? tests.copy()
                : tests.filter(function(t) return testIsInGroups(t, groups))
        );
        if (excludeGroups != null) {
            result = result.filter(function(t) return !testIsInGroups(t, excludeGroups));
        }

        return sortByDependencies(result);
    }


    /**
     * Get list of groups from `@group` meta of test case
     */
    private function processTestCaseRttiMeta () : Void
    {
        for (meta in rtti.meta) {
            switch (meta.name) {
                case 'group':
                    var mGroups = meta.params.map(StringTools.replace.bind(_, '"', ''));
                    defaultGroups = defaultGroups.concat(mGroups);
                case _:
            }
        }
    }


    /**
     * Collect test data in `testCase`
     *
     */
    private function gatherTestData () : Void
    {
        for (field in rtti.fields) {
            if (!field.isTest()) continue;

            //this is not a method
            if (!testCase.field(field.name).isFunction()) continue;

            tests.push( getTestData(field) );
        }
    }


    /**
     * Extract test configuration from `field` definition.
     *
     */
    private function getTestData (field:ClassField) : TestData
    {
        var callback     = testCase.field(field.name);
        var isIncomplete = false;
        var groups        : Array<String> = defaultGroups.copy();
        var incompleteMsg : String = null;
        var depends       : Array<String> = [];

        for (meta in field.meta) {
            switch (meta.name) {
                case 'group' :
                    var mGroups = meta.params.map(StringTools.replace.bind(_, '"', ''));
                    groups = groups.concat(mGroups);
                case 'incomplete' :
                    isIncomplete = true;
                    incompleteMsg = meta.params.map(StringTools.replace.bind(_, '"', '')).join('; ');
                case 'depends' :
                    depends = meta.params.map(StringTools.replace.bind(_, '"', ''));
                case _ :
            }
        }

        return {
            name          : field.name,
            callback      : callback,
            isIncomplete  : isIncomplete,
            incompleteMsg : incompleteMsg,
            groups        : groups,
            depends       : depends
        }
    }


    /**
     * Check if `test` is assigned to at least one of `groups`.
     *
     */
    private function testIsInGroups (test:TestData, groups:Array<String>) : Bool
    {
        for (group in groups) {
            if (test.groups.indexOf(group) >= 0) {
                return true;
            }
        }

        return false;
    }


    /**
     * Getters & setters
     *
     */
    private function get_className ()      : String return testCase.getClass().getClassName();
    private function get_file ()           : String return rtti.file;
    private function get_totalTestCount () : Int    return tests.length;


    /**
     * Setter `testCase`
     *
     */
    private function set_testCase (value:TestCase) : TestCase
    {
        rtti = Rtti.getRtti(value.getClass());

        return testCase = value;
    }


}