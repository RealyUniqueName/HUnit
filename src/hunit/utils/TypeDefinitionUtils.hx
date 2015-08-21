package hunit.utils;

import haxe.macro.Expr;
import haxe.macro.Type;


using hunit.Utils;



/**
 * `haxe.macro.TypeDefinition`
 *
 */
class TypeDefinitionUtils
{
    /**
     * Get ComplexType for mock class
     *
     */
    static public function toComplexType (typeDefinition:TypeDefinition) : ComplexType
    {
        return typeDefinition.toString().toComplex();
    }


    /**
     * Convert to `haxe.macro.Type`
     *
     */
    static public function toType (typeDefinition:TypeDefinition) : Type
    {
        return typeDefinition.toString().getType();
    }


    /**
     * Get expression which can be used as `Class<Dynamic>` in macro reification
     *
     */
    static public function toClassExpr (typeDefinition:TypeDefinition) : ExprOf<Class<Dynamic>>
    {
        if (typeDefinition.pack.length == 0) {

            return macro $i{typeDefinition.name};

        } else {
            var full = typeDefinition.pack.copy();
            full.push(typeDefinition.name);

            return macro $p{full};
        }
    }


    /**
     * Convert to TypePath
     *
     */
    static public function toTypePath (typeDefinition:TypeDefinition) : TypePath
    {
        var typePath : TypePath = {
            name   : typeDefinition.name,
            pack   : typeDefinition.pack,
            params : []
        };

        return typePath;
    }


    /**
     * Convert type definition to fully qualified class name.
     *
     */
    static public function toString (typeDefinition:TypeDefinition) : String
    {
        var full = typeDefinition.pack.copy();
        full.push(typeDefinition.name);

        return full.join('.');
    }

}//class TypeDefinitionUtils