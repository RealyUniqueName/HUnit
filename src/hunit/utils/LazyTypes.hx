package hunit.utils;


import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using hunit.Utils;


/**
 * Deals with `TLazy()` types.
 *
 * Idea was taken from tink_macro lib:
 * https://github.com/haxetink/tink_macro/blob/master/src/tink/macro/Types.hx
 *
 */
class LazyTypes
{
    /** registered callbacks from TLazy(callback) */
    static private var registered : Map<Int, Void->Type> = new Map();
    /** autoincrement for callbacks id */
    static private var idCounter : Int = 0;


    /**
     * Registers lazy type callback and returns callback id
     *
     */
    static public function register (getType:Void->Type) : Int
    {
        registered.set(idCounter, getType);

        var id = idCounter ++;

        return id;
    }


    /**
     * Get return type of TFun(_, returnType) stored in TLazy under specified `id`
     *
     */
    static public function getReturnType (id:Int) : ComplexType
    {
        // //if it's Void
        // var getType = registered.get(id);
        // switch (getType()) {
        //     case TFun(_,ret):
        //         switch (ret.toComplexType()) {
        //             case macro:StdType.Void: return macro:StdType.Void;
        //             case _:
        //         }
        //     case _:
        // }

        var complexType = TPath({
            pack   : ['haxe','macro'],
            name   : 'MacroType',
            params : [TPExpr(macro hunit.utils.LazyTypes.resolveReturnType($v{id}))],
            sub    : null
        });


        return complexType;
    }


    /**
     * Get argument type of TFun(args, _) at specified `argIndex` stored in TLazy under specified `id`
     *
     */
    static public function getArgType (id:Int, argIndex:Int) : ComplexType
    {
        var complexType = TPath({
            pack   : ['haxe','macro'],
            name   : 'MacroType',
            params : [TPExpr(macro hunit.utils.LazyTypes.resolveArgType($v{id}, $v{argIndex}))],
            sub    : null
        });

        return complexType;
    }


    /**
     * Assuming TLazy is resolved to TFun(_,returnType) return `returnType`
     *
     */
    macro static public function resolveReturnType (id:Int) : Type
    {
        var getType = registered.get(id);
        if (getType == null) Context.error('Unknown lazy id: $id', Context.currentPos());
// if (id == 0) trace(getType());
        switch(getType()) {
            case TFun(_, returnType): return returnType;
            case _: Context.error('Lazy type #$id was expected to be TFun, but happened to be ' + Std.string(getType()), Context.currentPos());
        }

        return null;
    }


    /**
     * Assuming TLazy is resolved to TFun(args,_) return `args[argIndex]`
     *
     */
    macro static public function resolveArgType (id:Int, argIndex:Int) : Type
    {
        var getType = registered.get(id);
        if (getType == null) Context.error('Unknown lazy id: $id', Context.currentPos());

        switch(getType()) {
            case TFun(args,_): return args[argIndex].t;
            case _: Context.error('Lazy type #$id was expected to be TFun, but happened to be ' + Std.string(getType()), Context.currentPos());
        }

        return null;
    }

}//class LazyTypes