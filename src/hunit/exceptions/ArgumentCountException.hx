package hunit.exceptions;

import haxe.PosInfos;
import hunit.exceptions.TestFailException;



/**
 * Method invoked with wrong amount of arguments.
 *
 */
class ArgumentCountException extends TestFailException
{

    /**
     * Constructor
     *
     */
    public function new (method:String, expected:Int, actual:Int, ?pos:PosInfos) : Void
    {
        var message = '$method(): expected $expected arguments;  got $actual';

        super(message, pos);
    }

}//class ArgumentCountException