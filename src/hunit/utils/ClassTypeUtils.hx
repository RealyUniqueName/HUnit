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

    /** Cached default values for method arguments in classes which does not proved default values when typed */
    static private var cachedArgs : Map<String, Map<String, Map<String,Expr> >> = new Map();


    /**
     * Macro for caching externs method arguments
     */
    static public function cacheMethodArguments () : Array<Field>
    {
        var ref = Context.getLocalClass();
        if (ref == null) return null;
        var cls = ref.get();
        if (!cls.isExtern && !cls.isInterface) return null;

        for (field in Context.getBuildFields()) {
            switch (field.kind) {
                case FFun(_.args => args) :
                    for (arg in args) {
                        if (arg.value != null) {
                            switch (arg.value) {
                                case macro null :
                                case _          : cacheArgValue(ref.toString(), field.name, arg.name, arg.value);
                            }
                        }
                    }
                case _:
            }
        }

        return null;
    }


    /**
     * Store argument value in cache
     */
    static private function cacheArgValue (className:String, method:String, arg:String, value:Expr) : Void
    {
        var methodsMap = cachedArgs.get(className);
        if (methodsMap == null) {
            methodsMap = new Map();
            cachedArgs.set(className, methodsMap);
        }
        var argsMap = methodsMap.get(method);
        if (argsMap == null) {
            argsMap = new Map();
            methodsMap.set(method, argsMap);
        }

        argsMap.set(arg, value);
    }


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


    /**
     * Try to find default value for `argument` of `method` in `type`
     */
    static public function findMethodArgumentValue (ref:Ref<ClassType>, method:String, argument:String) : Null<Expr>
    {
        var cls = ref.get();

        if (cls.isInterface || cls.isInterface) {
            var methods = cachedArgs.get(ref.toString());
            if (methods == null) return null;
            var args = methods.get(method);
            if (args == null) return null;
            return args.get(argument);

        } else if (cls.superClass != null) {
            return cls.superClass.t.findMethodArgumentValue(method, argument);
        }

        return null;
    }

}//class ClassTypeUtils