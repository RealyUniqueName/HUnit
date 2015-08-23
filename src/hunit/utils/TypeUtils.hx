package hunit.utils;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import tink.core.Outcome;
import tink.macro.ClassBuilder;

using hunit.Utils;


/**
 * `haxe.macro.Type`
 *
 */
class TypeUtils
{

    /**
     * Check if type describes an interface
     *
     */
    static public function isInterface (type:Type) : Bool
    {
        switch (type) {
            case TInst(t, p): return t.get().isInterface;
            case _          : return false;
        }
    }


    /**
     * Extract constructor arguments
     *
     */
    static public function getConstructorArgs (type:Type) : Array<FunctionArg>
    {
        var args : Array<FunctionArg> = [];

        switch (type) {
            case TInst(t, p):
                var constructor = new ClassBuilder(t.get()).getConstructor();
                switch (constructor.toHaxe().kind) {
                    case FFun(fn) : args = fn.args;
                    case _ :
                }
            case _:
        }

        return args;
    }


    /**
     * Collect all methods of specified `type` (with type `parameters` applied) and parent classes except constructor.
     *
     */
    static public function getMethods (type:Type, parameters:Array<Type>) : Array<Field>
    {
        var methods : Array<Field> = [];

        switch (type) {
            case TInst(t,_):
                type = TInst(t,parameters);

                switch (type.getFields(true)) {
                    case Success(fields):
                        for (field in fields) {
                            switch (field.kind) {
                                case FMethod(_):
                                    if (field.name != 'new') {
                                        methods.push(field.toField());
                                    }
                                case _:
                            }
                        }

                    case _:
                        Context.error('Failed to retrieve methods', Context.currentPos());
                }
            case _:
        }

        return methods;
    }


    /**
     * Get package + name. E.g. `my.example.MyClass`
     *
     */
    static public function getPackName (type:Type) : String
    {
        var pack = type.getFullName().split('.');
        //throw out module
        pack.splice(-2, -1);

        return pack.join('.');
    }


    /**
     * Get type full classpath. E.g. `my.example.Module.MyClass`
     *
     */
    static public function getFullName (type:Type) : String
    {
        var type : ClassType = switch (type) {
            case TInst(t,p): t.get();
            // case TAnonymous(a) : trace(a.toString()); null;
            case _         : throw 'Not implemented';
        }

        return type.module + '.' + type.name;
    }


    /**
     * Generate `TypePath` for specified `type` with type `parameters`
     *
     */
    static public function getTypePath (type:Type, parameters:Array<Type> = null) : TypePath
    {
        var pack        = type.getFullName().split('.');
        var sub         = pack.pop();
        var name        = pack.pop();

        if (parameters == null) {
            parameters = [];
        }

        var typePath : TypePath = {
            name   : name,
            pack   : pack,
            params : parameters.map(function(t) return TPType(t.toComplexType())),
            sub    : sub
        };

        return typePath;
    }


    /**
     * Returns amount of type parameters in `type`
     *
     */
    static public function countTypeParameters (type:Type) : Int
    {
        switch (type) {
            case TInst(_,p) : return p.length;
            // case TAnonymous(_.get() => td) : return 0;
            case _ : throw "Not implemented";
        }
    }


    /**
     * Generate TypeDefKind for classes which extend/implements specified `type` with type `parameters`.
     * Also adds additional `interfaces` implementations.
     *
     */
    static public function getDescendantTypeDefKind (type:Type, parameters:Array<Type> = null, interfaces:Array<Type> = null) : TypeDefKind
    {
        if (interfaces == null) {
            interfaces = [];
        }
        var interfaces : Array<TypePath> = interfaces.map(function(i) return i.getTypePath());

        var typePath = type.getTypePath(parameters);

        if (type.isInterface()) {
            return TDClass(null, interfaces.concat([typePath]));
        } else {
            return TDClass(typePath, interfaces);
        }
    }


    /**
     * Check if specified `type` implements `hunit.mock.IMock`.
     *
     */
    static public function isMock (type:Type) : Bool
    {
        switch (type) {
            case TInst(t, _) : return t.get().isMock();
            case _           : return false;
        }
    }

}//class TypeUtils