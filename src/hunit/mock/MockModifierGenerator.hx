package hunit.mock;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.macro.Member;
import tink.core.Outcome;

using hunit.Utils;


/**
 * Generates class which grants write access to all properties of target type
 *
 */
class MockModifierGenerator
{
    /** defined modifiers */
    static private var definedTypes : Map<String,TypeDefinition> = new Map();

    /** mocked type */
    private var target : Type;
    /** Generated type of MockModifier */
    private var definedType : TypeDefinition;


    /**
     * Constructor
     *
     */
    public function new (type:Type) : Void
    {
        target = type;
    }


    /**
     * Get mocked type
     *
     */
    public function getTarget () : Type
    {
        return target;
    }


    /**
     * Get MockModifier type definition
     *
     */
    public function getTypeDefinition () : TypeDefinition
    {
        defineType();

        return definedType;
    }


    /**
     * Define creator type
     *
     */
    public function defineType () : Void
    {
        if (definedType != null) return;
        var typeNamePostfix = '_MockModifier';

        var modifierClassName = getTarget().toString() + typeNamePostfix;

        definedType = definedTypes.get(modifierClassName);
        if (definedType != null) return;

        var targetTypePath = getTarget().getTypePath();
        var pack = targetTypePath.pack;
        var name = targetTypePath.name + typeNamePostfix;
        var pos  = Context.currentPos();

        var targetPack = getTarget().getTypePath().pack.join('.').parse(pos);

        definedType = {
            pack   : pack,
            name   : name,
            pos    : pos,
            kind   : TDClass(),
            fields : getFields(),
            meta   : [{name:':access', params:[macro $targetPack], pos:pos}]
        }
        definedTypes.set(modifierClassName, definedType);

        Context.defineType(definedType);
    }


    /**
     * Get fields for mock modifier type
     *
     */
    private function getFields () : Array<Field>
    {
        var targetComplexType = getTarget().toComplexType();
        var def = macro class Dummy {
            var __hu_mock__ : $targetComplexType;
            public function new (mock) __hu_mock__ = mock;
        }

        var fields = def.fields;

        var pos = Context.currentPos();
        switch (getTarget().getFields()) {
            case Failure(_):
            case Success(mockFields):
                for (field in mockFields) {
                    if (field.name == '__hu_mock__') continue;
                    var member : Member = field.toField();

                    switch (member.getVar()) {
                        case Success(v):
                            if (v.set != 'never') {
                                var name       = field.name;
                                var setterBody = macro __hu_mock__.$name = value;

                                fields.push(Member.prop(name, v.type, pos, true, false));
                                fields.push(Member.setter(name, 'value', pos, setterBody));
                            }
                        case Failure(_):
                    }
                }
        }

        return fields;
    }

}//class MockModifierGenerator