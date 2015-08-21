package hunit.exceptions;

import haxe.CallStack;
import haxe.PosInfos;
import hunit.call.Call;
import hunit.call.Expect;
import hunit.exceptions.TestFailException;
import hunit.Utils;


using hunit.utils.Value;


/**
 * Method invoked with unexpected arguments/result/exception
 *
 */
class UnexpectedCallException extends TestFailException
{


    /**
     * Generate message for exception
     *
     */
    static private function generateMessage (call:Call, expect:Expect = null) : String
    {
        var expectMsg = '';
        if (expect != null) {
            var s = (expect.timesMatched == 1 ? '' : 's');
            expectMsg = ' $expect, but called ${expect.timesMatched} time$s and last one was';
        }

        var msg = 'Unexpected call:$expectMsg $call';

        return msg;
    }


    /**
     * Cosntructor
     *
     * @param className Mocked type.
     * @param call      Method invocation details.
     * @param expect    Expected behavior (if identified)
     * @param pos
     */
    public function new (call:Call, expect:Expect = null, reason:String = null, ?pos:PosInfos) : Void
    {
        var msg = (reason != null ? reason : generateMessage(call, expect));

        super(msg, pos);

        stack = Exception.processCallStackOnCreation(call.stack);
    }


}//class UnexpectedCallException