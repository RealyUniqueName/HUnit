package hunit.utils;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using hunit.Utils;



/**
 * Generates `StubCreator` descendants for every mocked type
 *
 */
class StubCreatorGenerator
{
    /** defined descendants */
    static private var definedTypes : Map<String,TypeDefinition> = new Map();

    /** Mocked type */
    private var target : Type;
    /** Generated descendant */
    private var definedType : TypeDefinition;
    /** Description */
    private var typeNamePostfix : String = '_StubCreator';


    /**
     * Cosntructor
     *
     */
    public function new (type:Type) : Void
    {
        target = type;
    }


    /**
     * Get targeted type
     *
     */
    public function getTarget () : Type
    {
        return target;
    }


    /**
     * Define creator type
     *
     */
    public function defineType () : Void
    {
        if (definedType != null) return;

        var targetClassName = getTarget().toString() + typeNamePostfix;

        definedType = definedTypes.get(targetClassName);
        if (definedType != null) return;

        var targetTypePath = getTarget().getTypePath();

        definedType = getDummyDefinition();
        definedType.fields = getCreatorFields();

        definedType.pack = targetTypePath.pack;
        definedType.name = targetTypePath.name + typeNamePostfix;

        //cache
        definedTypes.set(targetClassName, definedType);

        Context.defineType(definedType);
    }


    /**
     * Get definition for generated type
     *
     */
    public function getTypeDefinition () : TypeDefinition
    {
        defineType();

        return definedType;
    }


    /**
     * Generate fields for creator
     *
     */
    private function getCreatorFields () : Array<Field>
    {
        var methods = getTarget().getMethods([]).map(function(m) return stubMethod(m));
        //exclude `toString()` because creating `toString()` methods which return non-string values is not allowed in HXCPP
        methods = methods.filter(function(m) return m.name != 'toString');

        return methods;
    }


    /**
     * Create method stub which will expect Matchs instead of arguments and will return StubFinisher.
     * Modifies `method` instance and returns it.
     *
     */
    private function stubMethod (method:Field) : Field
    {
        var pos = Context.currentPos();

        switch (method.kind) {
            case FFun(fn) :
                var argArrayExpr : Array<Expr> = [];
                var args         : Array<FunctionArg> = fn.args.map(function (a) : FunctionArg {
                    argArrayExpr.push(macro @:pos(pos) $i{a.name});
                    return {
                        name : a.name,
                        opt  : true,
                        type : getMatchType(a.type)
                    }
                });

                fn.ret  = getFinisherType(getMethodSignatureType(fn), fn.ret);
                fn.args = args;
                fn.expr = getBodyExpr(method.name, argArrayExpr);

                method.kind = FFun(fn);
            case _ : throw "Unexpected field type";
        }//switch(method.kind)

        method.makePublic();

        return method;
    }


    /**
     * Get typed Match for specified value type
     *
     */
    private function getMatchType (valueType:Null<ComplexType>) : Null<ComplexType>
    {
        var definition = macro class Dummy {
            function dummy (arg:hunit.Match<$valueType>) ;
        }

        switch (definition.fields[0].kind) {
            case FFun(fn) : return fn.args[0].type;
            case _ :
        }

        throw "Unexpected behavior";
    }


    /**
     * Get typed finisher for specified return type
     *
     */
    private function getFinisherType (methodSignatureType:Null<ComplexType>, returnType:Null<ComplexType>) : Null<ComplexType>
    {
        var definition = macro class Dummy {
            function dummy () : hunit.call.builder.StubFinisher<$methodSignatureType, $returnType> ;
        }

        switch (definition.fields[0].kind) {
            case FFun(fn) : return fn.ret;
            case _ :
        }

        throw "Unexpected behavior";
    }


    /**
     * Get type definition dummy
     *
     */
    private function getDummyDefinition () : TypeDefinition
    {
        return macro class DummyCreator extends hunit.call.builder.StubCreator {};
    }


    /**
     * Generate expression for creator's method body
     *
     */
    private function getBodyExpr (method:String, arguments:Array<Expr>) : Expr
    {
        return macro {
            var args = [$a{arguments}].map(function(a) : hunit.match.Match<Dynamic> {
                if (a == null) {
                    return new hunit.match.AnyMatch();
                } else {
                    return a;
                }
            });
            return __hu_create($v{method}, args);
        }
    }


    /**
     * Returns method signature.
     *
     */
    private function getMethodSignatureType (fn:Function) : ComplexType
    {
        var args = fn.args.map(function(a) return a.type);

        return TFunction(args, fn.ret);
    }

}//class ExpectStubCreatorGenerator