package hunit.match;

using hunit.Utils;


/**
 * Match nonequal values
 *
 * Compares enums with `Type.enumEq()`
 * Compares functions with `Reflect.compareMethod()`
 * Compares other types with `==`
 */
class NotEqualMatch<T> extends EqualMatch<T>
{

    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        try {
            switch (Type.typeof(this.value)) {
                case TFunction: return !Reflect.compareMethods(this.value, value);
                case TEnum(_) : return !Type.enumEq(this.value, value);
                case _        : return this.value != value;
            }
        } catch (e:Dynamic) {
            return false;
        }
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        var code = Std.string(value).shortenString();

        return (value.hasToString() ? '!="$code"' : '!=$code');
    }

}//class EqualMatch