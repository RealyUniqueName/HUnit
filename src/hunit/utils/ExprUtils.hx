package hunit.utils;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using hunit.Utils;


/**
 * `haxe.macro.Expr`
 *
 */
class ExprUtils
{
    /**
     * Create a copy of expression (positions are not guaranteed to be preserved)
     *
     */
    static public function copy (e:Null<Expr>) : Null<Expr>
    {
        return (e == null ? null : e.toString().parseInlineString(e.pos));
    }


    /**
     * Convert array declaration to a list of types
     *
     */
    static public function toTypeList (arrayOfTypes:Expr) : Array<Type>
    {
        var list = [];

        switch (arrayOfTypes) {
            case macro [$a{values}]:
                for (parameter in values) {
                    list.push(parameter.toString().getType());
                }

            case macro null:
            case _:
                Context.error('Array of types expected instead of this: ' + arrayOfTypes.toString(), Context.currentPos());
        }

        return list;
    }


    /**
     * Replace all `needle` expressions with `replacement` expressions in `haystack`
     *
     */
    static public function replace (haystack:Expr, needle:Expr, replacement:Expr) : Expr
    {
        if (haystack.toString() == needle.toString()) {
            return replacement.copy();
        }

        var result = haystack.map(replace.bind(_, needle, replacement));

        return result;
    }


}//class ExprUtils