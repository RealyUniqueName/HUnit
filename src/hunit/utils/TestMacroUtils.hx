package hunit.utils;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.File;
import hunit.utils.FileSystemUtils;

using hunit.Utils;



/**
 * Additional tools for testing
 *
 */
class TestMacroUtils
{
    /** Description */
    static private var erPackage : EReg = ~/^package\s+([a-z0-9_.]+);/i;


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





}//class TestMacroUtils