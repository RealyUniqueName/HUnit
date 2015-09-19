package hunit.utils;


import haxe.macro.Context;
import haxe.macro.Expr;
import hunit.utils.MockTypeGenerator;


using hunit.Utils;


/**
 * Generates `MockBuilder` descendant class for each mocked type
 *
 */
class MockBuilderGenerator
{
    /** defined MockBuilder descendants */
    static private var definedTypes : Map<String,TypeDefinition> = new Map();

    private var mockGenerator : MockTypeGenerator;
    /** Generated MockBuilder descendant */
    private var definedType : TypeDefinition;


    /**
     * Constructor
     *
     */
    public function new (mockGenerator:MockTypeGenerator) : Void
    {
        this.mockGenerator = mockGenerator;
    }


    /**
     * Generates type definition and defines it in current context.
     *
     */
    public function defineType () : Void
    {
        if (definedType != null) return;

        var mockClassName = mockGenerator.getTypeDefinition().toString();

        definedType   = definedTypes.get(mockClassName);
        if (definedType != null) return;

        var mockComplexType = mockGenerator.getTypeDefinition().toComplexType();

        definedType = macro class DummyBuilder extends hunit.mock.MockBuilder<$mockComplexType> {}
        definedType.fields = definedType.fields.concat(getServiceFields());

        definedType.pack = ['haxe', 'unit', 'mock'];
        definedType.name = 'MockBuilder_' + mockClassName.replace('.', '_');

        //cache
        definedTypes.set(mockClassName, definedType);

        Context.defineType(definedType);
    }


    /**
     * Get `TypeDefinition` for generated MockBuilder descendant
     *
     */
    public function getTypeDefinition () : TypeDefinition
    {
        defineType();

        return definedType;
    }


    /**
     * Generate service fields
     *
     */
    private function getServiceFields () : Array<Field>
    {
        var mockDefinition  = mockGenerator.getTypeDefinition();
        var mockComplexType = mockDefinition.toComplexType();
        var constructorArgs = mockGenerator.getTypeDefinition().toType().getConstructorArgs();

        var def = macro class Dummy {
            /** Create a mock using original class constructor */
            public function create () : $mockComplexType ;

            /** Stub all methods */
            public function stubAll () {
                fullStub = true;

                return this;
            }

            /** Throw exceptions for each called method which was not configured with `stub()` or `expect()` */
            public function strict() {
                strictMode = true;

                return this;
            }
        }

        var createField = def.fields[0];
        switch (createField.kind) {
            case FFun(fn):
                var mockTypePath         = mockDefinition.toTypePath();
                var constructorArgsExprs = constructorArgs.map(function(a) return macro $i{a.name});
                constructorArgsExprs.unshift(macro createMockData());
                fn.args = constructorArgs;
                fn.expr = macro {
                    return new $mockTypePath($a{constructorArgsExprs});
                }

                createField.kind = FFun(fn);
            case _:
        }

        //stubAll() by default for interfaces
        if (mockGenerator.getTargetType().isInterface()) {
            var stubDef = macro class Dummy {
                override private function createMockData ()
                {
                    fullStub = true;
                    return super.createMockData();
                }
            }
            def.fields.push(stubDef.fields[0]);
        }

        return def.fields;
    }


}//class MockBuilderGenerator