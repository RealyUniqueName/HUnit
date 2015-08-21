package hunit.exceptions;

import haxe.PosInfos;
import hunit.exceptions.TestFailException;
import hunit.call.Expect;



/**
 * If some expectation was not satisfied
 *
 */
class UnmetExpectationException extends TestFailException
{

    /**
     * Constructor
     *
     */
    public function new (expect:Expect, reason:String = '', ?pos:PosInfos) : Void
    {
        var file = expect.pos.fileName;
        var line = expect.pos.lineNumber;
        var msg  = '$expect' + (reason.length != 0 ? '$reason' : '');

        super(msg, pos);
    }

}//class UnmetExpectationException