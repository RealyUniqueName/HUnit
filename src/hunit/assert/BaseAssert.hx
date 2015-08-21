package hunit.assert;

import haxe.PosInfos;
import hunit.exceptions.AssertException;
import hunit.TestState;



/**
 * Base class for assertions
 *
 */
class BaseAssert
{

    /** Position where assertion was permormed */
    private var pos : PosInfos;


    /**
     * Constructor
     *
     */
    public function new (?pos:PosInfos) : Void
    {
        this.pos = pos;
    }


    /**
     * Validate assertion
     *
     */
    public function validate () : Void
    {
        throw 'To be overriden';
    }


    /**
     * Process failed assertion.
     *
     * @throws hunit.exceptions.AssertException
     */
    private function failed (message:String) : Void {
        throw new AssertException(message, pos);
    }


}//class BaseAssert