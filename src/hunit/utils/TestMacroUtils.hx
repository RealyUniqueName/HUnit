package hunit.utils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.File;
import hunit.utils.FileSystemUtils;

using hunit.Utils;
using hunit.utils.CTypeClassFieldUtils;



/**
 * Additional tools for testing
 *
 */
class TestMacroUtils
{
    /** Description */
    static private var erPackage : EReg = ~/^package\s+([a-z0-9_.]+);/i;


    /**
     * Add classpath from HUNIT_TEST_DIR
     */
    static public function addTestDirClasspath () : Void
    {
        if (!Context.defined('HUNIT_TEST_DIR')) return;

        var dir = Context.definedValue('HUNIT_TEST_DIR');
        haxe.macro.Compiler.addClassPath(dir);
    }


    /**
     * Description
     *
     */
    static public function addTests (runner:Expr, dir:String = null) : Expr
    {
        //search tests in `-D HUNIT_TEST_DIR`
        if (dir == null) {
            dir = Context.definedValue('HUNIT_TEST_DIR');
            dir = Sys.getCwd().ensureSlash() + dir;

        //search tests in `dir` relative to the file where `testSuite.addDirectory(dir)` was called.
        } else {
            var pos  : Position = Context.currentPos();
            var file : String = pos.getPosInfos().file.resolvePath();
            dir = file.parentDir().ensureSlash() + dir;
        }

        var tests = collectTests(dir);
        var sThis = runner.toString();

        var exprs : Array<Expr> = tests.map(function (test:String) : Expr {
            var pack     = test.split('.');
            var typePath = {name:pack.pop(), pack:pack};

            return macro $runner.add(new $typePath());
        });

        return macro $b{exprs};
    }


    /**
     * Collect tests located in `dir` and subdirectories.
     *
     */
    static private function collectTests (dir:String) : Array<String>
    {
        var modules : Array<String> = [];
        dir = dir.ensureSlash();

        var content, pack, name;
        for (file in dir.listDir(~/Test.hx$/, FilesOnly, true)) {
            content = File.getContent(dir + file).trim();
            pack = '';
            name = file.canonicalize().split('/').pop().replace('.hx', '');

            if (erPackage.match(content)) {
                pack = erPackage.matched(1);
            }

            modules.push(pack.length > 0 ? '$pack.$name' : name);
        }

        return modules;
    }



    /**
     * Prepare test case classes
     */
    macro static public function buildTestCase () : Array<Field>
    {
        var cls = Context.getLocalClass().get();
        var fields : Array<Field> = null;

        for (meta in cls.meta.extract('inheritTests')) {
            if (fields == null) fields = Context.getBuildFields();

            var list : Array<String> = null;
            if (meta.params != null && meta.params.length > 0) {
                list = meta.params.map(function(e) {
                    return switch (e.expr) {
                        case EConst(CString(testName)): testName;
                        case _ : Context.error('Only string constants allowed in arguments of @inheritTests meta', Context.currentPos());
                    }
                });
            } else {
                list = getTestCaseTestMethodsList(cls);
            }

            for (testName in list) {
                var def = macro class Dummy {
                    @test override public function $testName () super.$testName();
                }

                fields.push(def.fields[0]);
            }
        }

        return fields;
    }


    /**
     * Get list of test methods in `caseClass` type
     */
    static private function getTestCaseTestMethodsList (caseClass:ClassType) : Array<String>
    {
        var list : Array<String> = [];

        if (caseClass.superClass != null) {
            caseClass = caseClass.superClass.t.get();

            for (field in caseClass.fields.get()) {
                if (!field.mIsTest()) continue;

                list.push(field.name);
            }
        }

        return list;
    }


}//class TestMacroUtils