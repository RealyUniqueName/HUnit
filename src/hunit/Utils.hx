package hunit;

import haxe.PosInfos;
import haxe.rtti.CType;
import haxe.rtti.Rtti;
import hunit.TestCase;
import Type;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#end

using Reflect;
using hunit.Utils;

#if macro

typedef TMTUtils = tink.macro.Types;

typedef FSUtils  = hunit.utils.FileSystemUtils;
typedef TMUtils  = hunit.utils.TestMacroUtils;
typedef TUtils   = hunit.utils.TypeUtils;
typedef TDUtils  = hunit.utils.TypeDefinitionUtils;
typedef EUtils   = hunit.utils.ExprUtils;
typedef CTUtils  = hunit.utils.ClassTypeUtils;
typedef CFUtils  = hunit.utils.ClassFieldUtils;
typedef FUtils   = hunit.utils.FieldUtils;
typedef CxTUtils = hunit.utils.ComplexTypeUtils;

typedef TExprTools        = haxe.macro.ExprTools;
typedef TTExprTools       = haxe.macro.TypedExprTools;
typedef TComplexTypeTools = haxe.macro.ComplexTypeTools;
typedef TTypeTools        = haxe.macro.TypeTools;
typedef TMacroStringTools = haxe.macro.MacroStringTools;
typedef TTypedExprTools   = haxe.macro.TypedExprTools;
typedef TPositionTools    = haxe.macro.PositionTools;

typedef STUtils = StringTools;
typedef CUtils  = haxe.macro.Context;

typedef HxFSUtils = sys.FileSystem;
typedef HxFUtils  = sys.io.File;

#end


/**
 * Various utils
 *
 */
@:access(js.Boot)
class Utils
{
    /** meta name for methods which are tests */
    static private inline var META_TEST = 'test';


    /**
     * Check if `value` is a class instance or an anonymous structure.
     *
     */
    static public function isObject (value:Dynamic) : Bool
    {
        return switch (Type.typeof(value)) {
            case TClass(String) : false;
            case TClass(_)      : true;
            case TObject        : true;
            case _              : false;
        }
    }


    /**
     * If string is too long, truncate it and add marker to make user understand, that string is truncated
     *
     */
    static public function shortenString (str:String) : String
    {
        return (str.length > 70 ? str.substr(0, 65) + '<...>' : str);
    }


    /**
     * Check if specified value is either a `String` or has `toString()` method
     *
     */
    static public function hasToString (value:Dynamic) : Bool
    {
        if (Std.is(value, String)) return true;

        switch (Type.typeof(value)) {
            case TClass(cls):
                return Type.getInstanceFields(cls).indexOf('toString') >= 0;
            case _:
                return false;
        }
    }


    /**
     * Get string representation of a `value`.
     *
     * If result string is too long, shorten it.
     * If `value` is a string or has a `toString()` method, add quotes.
     *
     */
    static public function shortenQuote (value:Dynamic) : String
    {
        var str = Std.string(value).shortenString();

        return (value.hasToString() ? '"$str"' : str);
    }


    /**
     * Custom `trace()` implementation in effect during tests.
     *
     */
    static public function printTrace (printer:Dynamic->Void, value:Dynamic, ?pos:PosInfos) : Void
    {
        var file = pos.fileName;
        var line = pos.lineNumber;
        var msg  = Std.string(value);

        printer('HUnit: $file:$line: $msg\n');
    }


    /**
     * Crossplatform `print()`
     */
    static public function print(value:Dynamic) : Void {
        #if flash
            flashPrint(value);
        #elseif neko
            neko.Lib.print(value);
        #elseif php
            php.Lib.print(value);
        #elseif cpp
            cpp.Lib.print(value);
        #elseif js
            var msg = js.Boot.__string_rec(value, "");
            bufferedPrint(msg, untyped __js__("console").log);
        #elseif cs
            cs.system.Console.Write(value);
        #elseif java
            var str:String = Std.string(value);
            untyped __java__("java.lang.System.out.print(str)");
        #elseif python
            python.Lib.print(value);
        #end
    }


    /**
     * Print on flash
     *
     */
    #if flash
    static private var textField : flash.text.TextField;
    static private function flashPrint (value:String) : Void
    {
        #if (fdb || native_trace)
            bufferedPrint(value, flash.Lib.trace);
        #else
            if( textField == null ) {
                textField = new flash.text.TextField();
                textField.selectable = false;
                textField.width = flash.Lib.current.stage.stageWidth;
                textField.autoSize = flash.text.TextFieldAutoSize.LEFT;
                flash.Lib.current.addChild(textField);
            }
            textField.appendText(v);
        #end
    }
    #end


    /**
     * Print when new line encountered
     *
     */
    static private var buffer : String = '';
    static private function bufferedPrint (value:String, printer:Dynamic->Void) : Void
    {
        buffer += value;
        if (buffer.indexOf('\n') >= 0) {
            var lines = buffer.split('\n');
            for (i in 0...lines.length-1) {
                printer(lines[i]);
            }
            buffer = lines[lines.length - 1];
        }
    }


    /**
     * Remove test cases listed in `exclude`
     *
     */
    static public function filterCases (cases:Array<TestCase>, excludes:Array<String>) : Array<TestCase>
    {
        return cases.filter(function (c) {
            var className : String = Type.getClassName(Type.getClass(c));

            for (e in excludes) {
                if (className.indexOf(e) == 0) return false;
            }

            return true;
        });
    }


    /**
     * Get list provided by compilation flag like `-D SOME_FLAG=item1,item2`
     *
     */
    macro static public function getDefinedList (flag:String) : ExprOf<Array<String>>
    {
        var definedList = Context.definedValue(flag);
        if (definedList == null || definedList.trim().length == 0) {
            return macro [];
        }

        var groups : Array<Expr> = definedList.split(',').map(StringTools.trim).map(function(g) return macro $v{g});

        return macro [$a{groups}];
    }


    /**
     * Returns HUnit current version.
     *
     * This macro is expected to be executed from `TestSuite` only.
     */
    macro static private function version () : ExprOf<String>
    {
        var version = '-unknown-version-';

        var pos  : Position = Context.currentPos();
        var file : String = pos.getPosInfos().file.resolvePath();

        var haxelibJson = file.parentDir().ensureSlash() + '../../haxelib.json';
        if (haxelibJson.exists()) {
            var data = haxe.Json.parse(haxelibJson.getContent());
            if (data != null) {
                version = data.version;
            }
        }

        return macro $v{version};
    }

}//class Utils