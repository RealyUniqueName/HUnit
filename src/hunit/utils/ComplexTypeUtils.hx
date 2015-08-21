package hunit.utils;

import haxe.macro.Expr;
import haxe.macro.Context;

using hunit.Utils;


/**
 * `haxe.macro.ComplexType`
 *
 */
class ComplexTypeUtils
{

    /**
     * Create a copy of complex type
     *
     */
    static public function copy (complexType:Null<ComplexType>) : Null<ComplexType>
    {
        return (complexType == null ? null : complexType.toString().toComplex());
    }

}//class ComplexTypeUtils