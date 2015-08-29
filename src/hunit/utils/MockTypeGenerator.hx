package hunit.utils;

import hunit.utils.MockBuilderGenerator;
import hunit.utils.TestMacroUtils;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.MacroStringTools;


using hunit.Utils;


/**
 * Generates types for mocked classes
 *
 */
class MockTypeGenerator
{
    /** cache of already defined types */
    static private var definedTypes : Map<String, TypeDefinition> = new Map();

    /** Generated mock class */
    private var definedType : TypeDefinition = null;
    /** Type to mock */
    private var target : String;
    /** haxe.macro.Type instance for target type */
    private var targetType : Type;
    /** Type parameters for target type */
    private var targetTypeParameters : Array<Type>;
    /** cached instance of `MockBuilderGenerator` */
    private var mockBuilder : MockBuilderGenerator;


    /**
     * Cosntructor
     *
     */
    public function new (type:Expr, parameters:Expr) : Void
    {
        target               = type.toString();
        targetType           = target.resolve();
        targetTypeParameters = parameters.toTypeList().map(function(t) return t.follow());

        if (targetType.countTypeParameters() != targetTypeParameters.length) {
            Context.error('Amount of type parameters does not match with type definition', Context.currentPos());
        }
    }


    /**
     * Get `haxe.macro.Type` instance for target type
     *
     */
    public function getTargetType () : Type
    {
        return targetType;
    }


    /**
     * Get type parameters used for mocked type.
     *
     */
    public function getTargetTypeParameters () : Array<Type>
    {
        return targetTypeParameters;
    }


    /**
     * Generate mock class and define it.
     *
     */
    public function defineType () : Void
    {
        if (definedType != null) return;

        var targetPackName = getTargetType().getPackName();

        definedType = definedTypes.get(targetPackName);
        if (definedType != null) return;

        var targetTypeParametersNames = getTargetTypeParameters().map(function(type:Type) : String {
            return type.toString().replace('.', '_');
        });

        var pack   = targetPackName.split('.');
        var name   = pack.pop() + '_' + targetTypeParametersNames.join('_') + '_Mock';
        //throw out module name
        pack.pop();

        definedType = {
            pack   : pack,
            name   : name,
            pos    : Context.currentPos(),
            kind   : getTargetType().getDescendantTypeDefKind(getTargetTypeParameters(), ['hunit.mock.IMock'.getType()]),
            fields : getMockFields(),
            meta   : [
                {name:':hack', pos:Context.currentPos()},
                {name:':mock', pos:Context.currentPos()}
            ]
        }
        definedTypes.set(targetPackName, definedType);

// for (field in definedType.fields) {
//     if (field.name == 'withOptionalBasicType') switch (field.kind) {
//         case FFun(_.args[0].type => at) : trace(at);
//         case _:
//     }
// }

        Context.defineType(definedType);
    }


    /**
     * Get TypeDefinition for mock class
     *
     */
    public function getTypeDefinition () : TypeDefinition
    {
        defineType();

        return definedType;
    }


    /**
     * Get `MockBuilder` descendant generator for generated mock type
     *
     */
    public function getMockBuilder () : MockBuilderGenerator
    {
        if (mockBuilder == null) {
            mockBuilder = new MockBuilderGenerator(this);
        }

        return mockBuilder;
    }


    /**
     * Generate fields for mock class
     *
     */
    private function getMockFields () : Array<Field>
    {
        var fields  : Array<Field> = getServiceFields();
        var methods : Array<Field> = getTargetType().getMethods(getTargetTypeParameters()).filter(function(m) return !m.isInlined());

        //for interfaces
        if (getTargetType().isInterface()) {
            methods = methods.map(function(m:Field) {
                return m.implementMethod(macro {
                    var __call_id__ = __hu_mock__.methodInvoked($v{m.name}, ARGUMENTS);
                    __hu_mock__.validateStrictMode(__call_id__);
                    MOCKED_CALL;
                });
            });

        //for classes
        } else {
            methods = methods.map(function(m:Field) {
                return m.overrideMethod(macro {
                    var __call_id__ = __hu_mock__.methodInvoked($v{m.name}, ARGUMENTS);
                    __hu_mock__.validateStrictMode(__call_id__);
                    if (__hu_mock__.isMethodMocked(__call_id__)) {
                        MOCKED_CALL;
                    } else {
                        SUPER_CALL;
                    }
                });
            });
        }

        //workaroung @:final meta
        for (m in methods) {
            if (m.meta == null) {
                m.meta = [];
            }
            m.meta.push({name:':hack', pos:Context.currentPos()});
        }

        return fields.concat(methods);
    }


    /**
     * Generate service fields
     *
     */
    private function getServiceFields () : Array<Field>
    {
        var definition = macro class Dummy {
            private var __hu_mock__ : hunit.mock.MockData;
            /** mock constructor for interfaces */
            public function new () {}
        }

        //leave constructor for interfaces only
        if (!getTargetType().isInterface()) {
            definition.fields.pop();
        }

        return definition.fields;
    }

}//class MockTypeGenerator
