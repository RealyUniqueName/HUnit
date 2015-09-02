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
    /** Cache for extended types by `extendWith()` */
    static private var extendedTypes : Map<String,TypeDefinition> = new Map();


    /**
     * Extend parametrized `type` with `params` type parameters
     *
     */
    static public function extendWith (type:Type, params:Array<Type>) : Type
    {
        var fullName = type.getPackName() + '_MockBase_' + params.map(function(t) return t.toString().replace('.', '_')).join('_');

        var definition = extendedTypes.get(fullName);

        if (definition == null) {
            var pack  = fullName.split('.');
            var name  = pack.pop();
            var tpath = type.getTypePath(params);

            definition = macro class Dummy extends $tpath { }

            definition.pack = pack;
            definition.name = name;

            extendedTypes.set(fullName, definition);
            Context.defineType(definition);
        }

        return fullName.getType();
    }


    /**
     * Resolve type to one which can be mocked
     *
     */
    static public function resolve (typeName:String, type:Type = null) : Type
    {
        if (type == null) {
            type = typeName.getType();
        }
        var resolvedType = type.follow();

        switch (resolvedType) {
            // //typedefs of anonymous structures
            // case TAnonymous(_.get() => a):

            //classes & interfaces
            case TInst(_,_):
            //other
            case _:
                var module = Context.getLocalModule();
                if (module.length > 0) {
                    typeName = '$module.$typeName';
                }
                Context.error('Mocking types like $typeName is not supported.', Context.currentPos());
        }

        return resolvedType;
    }


    /**
     * Find last typedef in a chain of typedefs
     *
     */
    static public function getLastTypedef (type:Type) : Type
    {
        var next = type.follow(true);
        var last = type;

        while (true) {
            switch (next) {
                case TType(_, _):
                    last = next;
                    next = last.follow(true);
                case _:
                    break;
            }
        }

        return last;
    }


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
                var classType = t.get();
                var constructor = new ClassBuilder(classType).getConstructor();

                switch (constructor.toHaxe().kind) {
                    case FFun(fn) : args = fn.args;
                    case _ :
                }
            case _:
        }

        return args;
    }


    /**
     * Get names of constructor arguments
     *
     */
    static public function getConstructorArgsNames (type:Type) : Array<String>
    {
        var args : Array<String> = [];

        switch (type) {
            case TInst(t, p):
                var classType = t.get();
                if (classType.constructor != null) {
                    var texpr = classType.constructor.get().expr();

                    switch (texpr.expr) {
                        case TFunction(fn):
                            args = fn.args.map(function(a) return a.v.name);
                        case _:
                    }
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
            case TInst(t,p):
                if (parameters.length > 0) {
                    type = TInst(t,parameters);
                }

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
        pack.splice(-2, 1);

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
            params : parameters.map(function(t) return TPType(t.toValidComplexType())),
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


    /**
     * Check if this type represent one of [Int, Float, Bool]
     *
     */
    static public function isBasicType (type:Type) : Bool
    {
        return switch (type) {
            case TAbstract(_.toString() => typeName, _): ['Int', 'Float', 'Bool', 'Void'].indexOf(typeName) >= 0;
            case _: false;
        }
    }


    /**
     * Convert to complex type with special handling of `Null<StdTypes.*>` case
     *
     */
    static public function toValidComplexType (type:Type) : ComplexType
    {
        switch (type) {
            case TType(_.toString() => 'Null', _[0] => TAbstract(_.toString() => name, [])):
                if (['Int', 'Bool', 'Float'].indexOf(name) >= 0) {
                    return TPath({
                        name   : 'Null',
                        pack   : [],
                        params : [TPType(TPath({name:name, pack:[], params:[]}))]
                    });
                }
            case _:
        }

        return type.toComplexType();
    }

}//class TypeUtils