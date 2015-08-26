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
        if (complexType == null) return null;

        return complexType.toString().toValidComplex();
    }


    /**
     * Check if this type represent one of [Int, Float, Bool]
     *
     */
    static public function isBasicType (complexType:Null<ComplexType>) : Bool
    {
        return (complexType == null ? false : complexType.toType().isBasicType());
    }


    /**
     * Convert string to complex type taking module name and type parameters into account.
     *
     */
    static public function toValidComplex (typeName:String) : ComplexType
    {
        var params : Array<TypeParam> = [];
        if (typeName.strHasTypeParameters()) {
            var tpList = typeName.substring(typeName.indexOf('<') + 1, typeName.lastIndexOf('>'));
            params = createTypeParameters(tpList);
            typeName = typeName.substring(0, typeName.indexOf('<'));
        }

        var pack : Array<String> = typeName.toString().split('.');
        var sub  = pack.pop();
        var name = pack.pop();

        if (name == null) {
            name = sub;
            sub  = null;
        //not a module name
        } else if (name.charAt(0).toLowerCase() == name.charAt(0)) {
            pack.push(name);
            name = sub;
            sub  = null;
        }

        return TPath({name:name, pack:pack, sub:sub, params:params});
    }


    /**
     * Create list of type parameters based on string
     *
     */
    static private function createTypeParameters (tpList:String) : Array<TypeParam>
    {
        var params : Array<String> = [];

        var subCount = 0;
        var start    = 0;

        for (i in 0...tpList.length) {
            switch (tpList.charAt(i)) {
                case '<' : subCount++;
                case '>' : subCount--;
                case ',' :
                    if (subCount == 0) {
                        params.push(tpList.substring(start, i));
                        start = i + 1;
                    }
                case _:
            }
        }
        if (start < tpList.length) {
            params.push(tpList.substr(start));
        }

        var result : Array<TypeParam> = params.map(function(p) return TPType(p.toValidComplex()));

        return result;
    }


    /**
     * Check if type name ins `str` specifies type parameters
     *
     */
    static private function strHasTypeParameters (str:String) : Bool
    {
        return str.indexOf('<') >= 0;
    }

}//class ComplexTypeUtils