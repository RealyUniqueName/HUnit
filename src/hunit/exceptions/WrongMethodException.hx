package hunit.exceptions;

import haxe.PosInfos;
import hunit.exceptions.TestFailException;



/**
 * Executed method name does not match expected method name
 *
 */
class WrongMethodException extends TestFailException
{

    /**
     * Constructor
     *
     */
    public function new (expected:String, executed:String, ?pos:PosInfos) : Void
    {
        var message = 'Expected method `$expected()` but `$executed()` was invoked.';

        super(message, pos);
    }

}//class WrongMethodException