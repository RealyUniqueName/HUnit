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

        var kind = classField.kind.toFieldType(classField.type);

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
    static public function toFieldType (fieldKind:FieldKind, fieldType:Type) : FieldType
    {
        var kind : FieldType = null;
        switch([ fieldKind, fieldType ]) {
            case [ FVar(read, write), ret ]:

                kind = FProp(
                    varAccessToString(read, "get"),
                    varAccessToString(write, "set"),
                    ret.toComplexType(),
                    null
                );

            case [ FMethod(_), TFun(args, ret) ]:

                kind = FFun({
                    args: [
                        for (a in args) {
                            name : a.name,
                            opt  : a.opt,
                            type : a.t.toComplexType(),
                        }
                    ],
                    ret  : ret.toComplexType(),
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
                                        name : a.name,
                                        opt  : a.opt,
                                        type : a.t.toComplexType()//LazyTypes.getArgType(lazyId, argIndex),
                                    }
                                }
                            ],
                            ret  : ret.toComplexType(),//LazyTypes.getReturnType(lazyId),
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

}//class ClassFieldUtils