package hunit.exceptions;

import haxe.PosInfos;
import hunit.match.Match;



/**
 * If exception is expected, but was not thrown
 *
 */
class NoExpectedException extends TestFailException
{

    /**
     * Constructor
     *
     */
    public function new (exceptionMatch:Match<Dynamic>, ?pos:PosInfos) : Void
    {
        super('Expected exception was not thrown: ' + exceptionMatch.toString(), pos);
    }

}//class NoExpectedException