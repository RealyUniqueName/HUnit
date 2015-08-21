package hunit.exceptions;

import haxe.PosInfos;
import hunit.exceptions.TestFailException;
import hunit.match.Match;



/**
 * Method invoked with wrong arguments.
 *
 */
class ArgumentsException extends TestFailException
{

    /**
     * Constructor
     *
     */
    public function new (method:String, expected:Array<Match>, actual:Array<Dynamic>, ?pos:PosInfos) : Void
    {
        var actualStr = actual.map(function(a) return Std.string(a)).join(', ');
        var message   = '`$method($expected)` expected, but  `method($actualStr)` invoked';

        super(message, pos);
    }

}//class ArgumentsException