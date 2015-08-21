package hunit.call;



/**
 * Interface for classes which describe some expected behavior
 *
 */
interface IExpect
{

    /**
     * Validate expectations are sutisfied. Throw exceptions otherwise.
     *
     */
    public function validate () : Void ;

}//interface IExpect