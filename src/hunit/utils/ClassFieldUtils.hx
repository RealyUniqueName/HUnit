package hunit.utils;


import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;


using hunit.Utils;


/**
 * `haxe.macro.ClassField`
 *
 */
class ClassFieldUtils
{

    static public function toField(classField:ClassField) : Field
    {
        if (classField.params.length != 0) {
            throw "Invalid TAnonymous";
        }

        var kind = classField.toFieldType(classField.type);

        var access = [(classField.isPublic ? APublic : APrivate)];
        if (classField.isInlined()) access.push(AInline);

        var field : Field =  {
            name   : classField.name,
            doc    : classField.doc,
            access : access,
            kind   : kind,
            pos    : classField.pos,
            meta   : classField.meta.get(),
        }

        return field;
    }//function toField()


    /**
     * Check if field is inlined
     *
     */
    static public function isInlined (field:ClassField) : Bool
    {
        return switch (field.kind) {
            case FMethod(MethInline) : true;
            case _                   : false;
        }
    }


    /**
     * Convert classField.kind to field.kind
     *
     */
    static public function toFieldType (classField:ClassField, fieldType:Type) : FieldType
    {
        var fieldKind : FieldKind = classField.kind;
        var kind      : FieldType = null;
        switch([ fieldKind, fieldType ]) {
            case [ FVar(read, write), ret ]:

                kind = FProp(
                    varAccessToString(read, "get"),
                    varAccessToString(write, "set"),
                    ret.toValidComplexType(),
                    null
                );

            case [ FMethod(_), TFun(args, ret) ]:
                kind = FFun({
                    args: [
                        for (i in 0...args.length) {
                            name  : args[i].name,
                            opt   : args[i].opt,
                            type  : args[i].t.toValidComplexType(),
                            value : classField.getArgumentExpr(i)
                        }
                    ],
                    ret  : ret.toValidComplexType(),
                    expr : null,
                });

            case [ FMethod(q), TLazy(getType) ]:
                var lazyId : Int = LazyTypes.register(getType);

                switch (getType()) {
                    case TFun(args, ret):

                        kind = FFun({
                            args: [
                                for (argIndex in 0...args.length) {
                                    var a = args[argIndex];
                                    {
                                        name  : a.name,
                                        opt   : a.opt,
                                        type  : a.t.toValidComplexType(), //LazyTypes.getArgType(lazyId, argIndex),
                                        value : classField.getArgumentExpr(argIndex)
                                    }
                                }
                            ],
                            ret  : ret.toValidComplexType(),//LazyTypes.getReturnType(lazyId),
                            expr : null,
                        });

                    default: throw "Invalid TAnonymous";
                }//switch (getType())

            default:
                throw "Invalid TAnonymous";
        }//switch (fieldKind)

        return kind;
    }//function toFieldType()


    static private function varAccessToString(va : VarAccess, getOrSet : String) : String
    {
        return switch (va) {
            case AccNormal        : "default";
            case AccNo            : "null";
            case AccNever         : "never";
            case AccResolve       : throw "Invalid TAnonymous";
            case AccCall          : getOrSet;
            case AccInline        : "default";
            case AccRequire(_, _) : "default";
        }
    }


    /**
     * Find default expression for specified argument
     *
     */
    static public function getArgumentExpr (field:ClassField, index:Int) : Null<Expr>
    {
        var texpr = field.expr();
        if (texpr == null) return null;

        switch (field.expr().expr) {
            case TFunction(_.args => args):
                var arg = args[index];
                if (arg.value != null) {
                    return switch (arg.value) {
                        case TInt(i)    : macro $v{i};
                        case TFloat(s)  : macro $v{s};
                        case TString(s) : macro $v{s};
                        case TBool(b)   : macro $v{b};
                        case TNull      : macro null;
                        case TThis      : macro this;
                        case TSuper     : macro super;
                    }
                }
            case _:
        }

        return null;
    }

}//class ClassFieldUtils