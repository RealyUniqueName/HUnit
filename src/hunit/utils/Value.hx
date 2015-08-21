package hunit.utils;



/**
 * Represents some value or no value at all
 *
 */
enum Value<T>
{
    Nothing;
    Thing(v:T);
}//enum Value


/**
 * Tools to verify and extract value
 *
 */
class ValueTools
{

    /**
     * Check if `holder` contains a value
     *
     */
    static public function hasValue<T> (holder:Null<Value<T>>) : Bool
    {
        if (holder == null) return false;
        switch (holder) {
            case Nothing  : return false;
            case Thing(_) : return true;
        }

        return false;
    }


    /**
     * Extract value.
     *
     */
    static public function getValue<T> (holder:Null<Value<T>>) : T
    {
        if (holder == null) {
            throw new Exception('No value here');
        }

        switch (holder) {
            case Nothing  : throw new Exception('No value here');
            case Thing(v) : return v;
        }

        throw new Exception('No value here');
    }

}//class ValueTools