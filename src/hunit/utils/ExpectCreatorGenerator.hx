package hunit.utils;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import hunit.utils.StubCreatorGenerator;

using hunit.Utils;


/**
 * Generates `ExpectCreator` descendants
 *
 */
class ExpectCreatorGenerator extends StubCreatorGenerator
{

    /**
     * Cosntructor
     *
     */
    public function new (type:Type) : Void
    {
        super(type);
        typeNamePostfix = '_ExpectCreator';
    }


    /**
     * Get typed finisher for specified return type
     *
     */
    override private function getFinisherType (methodSignatureType:Null<ComplexType>, returnType:Null<ComplexType>) : Null<ComplexType>
    {
        var definition = macro class Dummy {
            function dummy () : hunit.call.builder.ExpectFinisher<$returnType> ;
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
    override private function getDummyDefinition () : TypeDefinition
    {
        return macro class DummyCreator extends hunit.call.builder.ExpectCreator {};
    }

}//class ExpectCreatorGenerator