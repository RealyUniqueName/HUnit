package hunit.exceptions;

import haxe.CallStack.StackItem;
import haxe.PosInfos;
import hunit.exceptions.UnexpectedException;
import hunit.match.Match;



/**
 * Describes expected exception
 *
 */
class ExpectedExceptionData
{
    /** exception constraint */
    public var match (default,null) : Match<Dynamic>;
    /** if validated exception is expected */
    public var satisfied (default,null) : Bool = false;
    /** Position where `TestCase.expectException()` was called */
    public var pos (default,null) : PosInfos;


    /**
     * Constructor
     *
     */
    public function new (match:Match<Dynamic>, ?pos:PosInfos) : Void
    {
        this.match = match;
        this.pos   = pos;
    }


    /**
     * Validate `e`.
     *
     * @throws hunit.exceptions.UnexpectedException If `e` is not an expected exception
     */
    public function validate (e:Dynamic, exceptionStack:Array<StackItem>) : Void
    {
        satisfied = match.match(e);

        if (!satisfied) {
            throw new UnexpectedException(e, exceptionStack);
        }
    }


}//class ExpectedExceptionData