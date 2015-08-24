package hunit.utils;

import haxe.Constraints;
import haxe.rtti.Rtti;
import haxe.rtti.CType;
import haxe.unit.TestCase;
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
    groups        : Array<String>
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


    /**
     * Constructor
     *
     */
    public function new (testCase:TestCase) : Void
    {
        tests = [];
        this.testCase = testCase;

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

        return result;
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
        var groups        : Array<String> = [];
        var incompleteMsg : String = null;

        for (meta in field.meta) {
            switch (meta.name) {
                case 'group' :
                    var mGroups = meta.params.map(function(v) return v.replace('"', ''));
                    groups = groups.concat(mGroups);
                case 'incomplete' :
                    isIncomplete = true;
                    incompleteMsg = meta.params.map(function(v) return v.replace('"', '')).join('; ');
                case _ :
            }
        }

        return {
            name          : field.name,
            callback      : callback,
            isIncomplete  : isIncomplete,
            incompleteMsg : incompleteMsg,
            groups        : groups
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