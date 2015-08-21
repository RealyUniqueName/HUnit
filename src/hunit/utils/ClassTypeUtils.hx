package hunit.utils;


import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;


using hunit.Utils;


/**
 * `haxe.macro.ClassType`
 *
 */
class ClassTypeUtils
{

    /**
     * Get own and inherited methods of `classType`.
     *
     * @param classType
     * @param filter Don't add methods wich names are listed here
     */
    static public function getMethods (classType:ClassType, filter:Array<String>) : Array<Field>
    {
        var fields : Array<Field> = [];

        for (classField in classType.fields.get()) {
            if (classField.name.skipField(filter)) continue;

            var field = classField.toField();
            switch(field.kind) {
                case FFun(_) : fields.push(field);
                case _:
            }
        }

        if (classType.superClass != null) {
            filter = filter.concat(fields.map(function(f) return f.name));
            fields = fields.concat(classType.superClass.t.get().getMethods(filter));
        }

        return fields;
    }


    /**
     * Is field with `name` listed in `filter` list?
     *
     */
    static private function skipField (name:String, filter:Array<String>) : Bool
    {
        return filter.indexOf(name) >= 0;
    }


    /**
     * Check if `classType` is `hunit.mock.IMock` or implements it.
     *
     */
    static public function isMock (classType:ClassType) : Bool
    {
        var name = classType.pack.concat([classType.name]).join('.');
        if (name == 'hunit.mock.IMock') {
            return true;
        }

        for (iface in classType.interfaces) {
            var cls = iface.t.get();
            name    = cls.pack.concat([cls.name]).join('.');

            if (name == 'hunit.mock.IMock') {
                return true;
            }
            if (cls.superClass != null && cls.superClass.t.get().isMock()) {
                return true;
            }
        }

        return (classType.superClass == null ? false : classType.superClass.t.get().isMock());
    }

}//class ClassTypeUtils