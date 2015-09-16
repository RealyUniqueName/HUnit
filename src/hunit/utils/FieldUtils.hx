package hunit.utils;


import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using hunit.Utils;


/**
 * `haxe.macro.Field`
 *
 */
class FieldUtils
{

    /**
     * Removes `private` from field declaration and adds `public`
     *
     */
    static public function makePublic (method:Field) : Void
    {
        if (method.access == null) {
            method.access = [APublic];
            return;
        }

        var access : Array<Access> = [];
        for (i in 0...method.access.length) {
            switch (method.access[i]) {
                case APrivate :
                case APublic  :
                case _        : access.push(method.access[i]);
            }
        }
        access.push(APublic);

        method.access = access;
    }


    /**
     * Check if field has `inline` accessor
     *
     */
    static public function isInlined (field:Field) : Bool
    {
        if (field.access == null) return false;

        for (access in field.access) {
            switch (access) {
                case AInline : return true;
                case _       :
            }
        }

        return false;
    }


    /**
     * Create a copy of specified field.
     *
     */
    static public function copy (field:Field, targetType:Type = null) : Field
    {
        var meta : Metadata = field.meta.copyFieldMeta();
        var kind : FieldType = field.kind.copyFieldType(targetType, field.name);

        var copy : Field = {
            name   : field.name,
            doc    : field.doc,
            access : (field.access == null ? null : field.access.copy()),
            kind   : kind,
            pos    : field.pos,
            meta   : meta
        }

        return copy;
    }


    /**
     * Copy metadata of some field
     *
     */
    static public function copyFieldMeta (meta:Null<Metadata>) : Null<Metadata>
    {
        if (meta == null) return null;

        var copy : Metadata = [];
        for (m in meta) {
            copy.push({
                name   : m.name,
                params : (m.params == null ? null : m.params.map(function(e:Expr) return e.copy())),
                pos    : m.pos
            });
        }

        return copy;
    }


    /**
     * Create a copy of `FieldType`
     *
     */
    static public function copyFieldType (fieldType:Null<FieldType>, targetType:Type = null, fieldName:String = null) : Null<FieldType>
    {
        if (fieldType == null) return null;

        var copy : FieldType = null;

        switch (fieldType) {
            case FVar(t, e):
                copy = FVar(t.copy(), e.copy());
            case FFun(fn):
                copy = FFun({
                    args   : fn.args.map(function(a:FunctionArg) return a.copyFunctionArg(targetType, fieldName)),
                    ret    : fn.ret, //.copy(),
                    expr   : fn.expr.copy(),
                    params : (fn.params == null ? null : fn.params.map(function(tpd:TypeParamDecl) return tpd.copyTypeParamDecl()))
                });
            case FProp(get, set, t, e):
                copy = FProp(get, set, t.copy(), e.copy());
        }

        return copy;
    }


    /**
     * Create a copy of TypeParamDecl
     *
     */
    static public function copyTypeParamDecl (tpd:TypeParamDecl) : TypeParamDecl
    {
        var copy : TypeParamDecl = {name : tpd.name};

        if (tpd.constraints != null) {
            copy.constraints = tpd.constraints.map(function(ct:ComplexType) return ct.copy());
        }
        if (tpd.params != null) {
            copy.params = tpd.params.map(function(t:TypeParamDecl) return t.copyTypeParamDecl());
        }

        return copy;
    }


    /**
     * Create a copy of FunctionArg
     *
     */
    static public function copyFunctionArg (arg:FunctionArg, targetType:Type = null, method:String = null) : FunctionArg
    {
        var copy : FunctionArg = {
            name : arg.name,
            type : arg.type //.copy()
        }

        if (arg.opt != null) {
            copy.opt = arg.opt;
        }
        if (arg.value != null) {
            copy.value = arg.value.copy();
        }

        if (copy.type.isBasicType()) {
            switch (copy.type) {
                case TPath(_.sub => name):
                    copy.type = TPath({name:name, pack:[], params:[]});
                case _:
            }
            if (copy.value == null && targetType != null && method != null) {
                //check if this is interface or extern
                copy.value = targetType.findMethodArgumentValue(method, copy.name);
            }
            if (copy.value != null) {
                copy.opt = false;
            }
        }

        return copy;
    }


    /**
     * Create overriden method.
     *
     */
    static public function overrideMethod (method:Field, body:Expr, targetType:Type = null) : Field
    {
        var copy = method.copy(targetType);
        copy.ensureOverrides();

        switch (copy.kind) {
            case FFun(fn):
                body = body.replaceSuperCall(copy.name, fn);
                body = body.replaceMockedCall(copy.name, fn);
                body = body.replaceArguments(copy.name, fn);

                fn.expr   = body;
                copy.kind = FFun(fn);
            case _:
        }

        return copy;
    }


    /**
     * Create implemented method.
     *
     */
    static public function implementMethod (method:Field, body:Expr, targetType:Type = null) : Field
    {
        var copy = method.copy(targetType);

        switch (copy.kind) {
            case FFun(fn):
                body = body.replaceMockedCall(copy.name, fn);
                body = body.replaceArguments(copy.name, fn);

                fn.expr   = body;
                copy.kind = FFun(fn);
            case _:
        }

        return copy;
    }


    /**
     * Replace SUPER_CALL with [return ]super.functionName(arguments)
     *
     */
    static private function replaceSuperCall (expr:Expr, functionName:String, fn:Function) : Expr
    {
        if (fn.ret == null) {
            throw 'Unknown return type for $functionName';
        }

        var args = fn.args.map(function(a) return macro $i{a.name});

        var superCall : Expr = (
            args.length == 0
                ? macro super.$functionName()
                : macro super.$functionName($a{args})
        );

        superCall = switch (fn.ret) {
            case macro:StdTypes.Void:
                macro try {
                    $superCall;
                    __hu_mock__.validateCall(__call_id__);
                } catch(e:hunit.exceptions.UnexpectedCallException) {
                    throw e;
                } catch(e:Dynamic) {
                    __hu_mock__.addCallException(__call_id__, e);
                    __hu_mock__.validateCall(__call_id__);
                    throw e;
                }
            case _ :
                macro try {
                    var result = $superCall;
                    __hu_mock__.addCallResult(__call_id__, result);
                    __hu_mock__.validateCall(__call_id__);
                    return result;
                } catch(e:hunit.exceptions.UnexpectedCallException) {
                    throw e;
                } catch (e:Dynamic) {
                    __hu_mock__.addCallException(__call_id__, e);
                    __hu_mock__.validateCall(__call_id__);
                    throw e;
                }
        }

        return expr.replace(macro SUPER_CALL, superCall);
    }


    /**
     * Replace `MOCKED_CALL` with `[return [mockResult]]`
     *
     */
    static private function replaceMockedCall (expr:Expr, functionName:String, fn:Function) : Expr
    {
        if (fn.ret == null) {
            throw 'Unknown return type for $functionName';
        }

        var callExpr = macro __hu_mock__.getMockedCallResult(__call_id__);
        callExpr = callExpr.replaceArguments(functionName, fn);

        var mockedCall : Expr = switch (fn.ret) {
            case macro:StdTypes.Void:
                macro try {
                    $callExpr;
                    __hu_mock__.validateCall(__call_id__);
                } catch(e:hunit.exceptions.UnexpectedCallException) {
                    throw e;
                } catch(e:Dynamic) {
                    __hu_mock__.addCallException(__call_id__, e);
                    __hu_mock__.validateCall(__call_id__);
                    throw e;
                }
            case _ :
                macro try {
                    var result = $callExpr;
                    __hu_mock__.addCallResult(__call_id__, result);
                    __hu_mock__.validateCall(__call_id__);
                    return result;
                } catch(e:hunit.exceptions.UnexpectedCallException) {
                    throw e;
                } catch (e:Dynamic) {
                    __hu_mock__.addCallException(__call_id__, e);
                    __hu_mock__.validateCall(__call_id__);
                    throw e;
                }
        }

        return expr.replace(macro MOCKED_CALL, mockedCall);
    }


    /**
     * Replace `ARGUMENTS` with `arg1, arg2, arg3, <...>`
     *
     */
    static private function replaceArguments (expr:Expr, functionName:String, fn:Function) : Expr
    {
        if (fn.ret == null) {
            throw 'Unknown return type for $functionName';
        }

        var args = fn.args.map(function(a) return macro $i{a.name});
        var argsExpr : Expr = (
            args.length == 0
                ? macro []
                : macro [$a{args}]
        );

        return expr.replace(macro ARGUMENTS, argsExpr);
    }


    /**
     * Adds `override` accessor to field declaration if it does not have one.
     *
     */
    static public function ensureOverrides (field:Field) : Void
    {
        if (field.access == null) field.access = [];

        var hasOverrie = false;
        for (access in field.access) {
            switch (access) {
                case AOverride: hasOverrie = true;
                case _:
            }
        }

        if (!hasOverrie) field.access.push(AOverride);
    }


}//class FieldUtils