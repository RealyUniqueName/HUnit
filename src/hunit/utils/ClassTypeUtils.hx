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

    // /** Cached default values for method arguments in classes which does not proved default values when typed */
    // static private var cachedArgs : Map<String, Map<String, Map<String,Expr> >> = new Map();
    /** Description */
    static private var cachedMethods : Map<String, Map<String, Function>> = new Map();


    /**
     * Macro for caching externs method arguments
     */
    static public function cacheMethodSignatures () : Array<Field>
    {
        var ref = Context.getLocalClass();
        if (ref == null) return null;

        var methods = new Map<String, Function>();
        for (field in Context.getBuildFields()) {
            switch (field.kind) {
                case FFun(fn) :
                    methods.set(field.name, fn);
                case _:
            }
        }

        cachedMethods.set(ref.toString(), methods);

        return null;
    }

    /**
     * Get `methodName` cached with `ClassTypeUtils.cacheMethodSignatures()`
     */
    static public function getCachedMethod (classType:ClassType = null, className:String, methodName:String) : Null<Function>
    {
        if (classType == null) {
            var type = className.getType();
            switch (type) {
                case TInst(t,_): classType = t.get();
                case _:
            }
        }

        var methods = cachedMethods.get(className);
        if (methods == null) return null;

        var field = methods.get(methodName);
        if (field != null) return field;

        if (classType.superClass != null) {
            var ref = classType.superClass.t;
            return getCachedMethod(ref.get(), ref.toString(), methodName);
        }

        return null;
    }


    // /**
    //  * Get own and inherited methods of `classType`.
    //  *
    //  * @param classType
    //  * @param filter Don't add methods wich names are listed here
    //  */
    // static public function getMethods (classType:ClassType, filter:Array<String>) : Array<Field>
    // {
    //     var fields : Array<Field> = [];

    //     for (classField in classType.fields.get()) {
    //         if (classField.name.skipField(filter)) continue;

    //         var field = classField.toField();
    //         switch(field.kind) {
    //             case FFun(_) : fields.push(field);
    //             case _:
    //         }
    //     }

    //     if (classType.superClass != null) {
    //         filter = filter.concat(fields.map(function(f) return f.name));
    //         fields = fields.concat(classType.superClass.t.get().getMethods(filter));
    //     }

    //     return fields;
    // }


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


    /**
     * Try to find default value for `arg` of `method` in `type`
     */
    static public function findMethodArgumentValue (ref:Ref<ClassType>, method:String, arg:String) : Null<Expr>
    {
        var cls = ref.get();
        var className = ref.toString();

        var methods = cachedMethods.get(className);
        if (methods != null) {
            var fn = methods.get(method);
            if (fn != null) {
                var args = fn.args;
                if (args != null) {
                    for (a in args) {
                        if (a.name == arg) {
                            return a.value;
                        }
                    }
                }
            }
        }

        if (cls.superClass != null) {
            return cls.superClass.t.findMethodArgumentValue(method, arg);
        }

        return null;
    }

}//class ClassTypeUtils