package hunit.call;

import haxe.Constraints.Function;
import haxe.PosInfos;
import hunit.call.CallCount;
import hunit.call.Expect;
import hunit.call.IExpect;
import hunit.match.Match;
import hunit.mock.MockData;
import hunit.utils.Value;


using hunit.utils.Value;


/**
 * Expected method invocation
 *
 */
class Stub
{
    /** owner of this expectation */
    public var mockData (default,null) : MockData;
    /** method name */
    public var method (default,null) : String;
    /** expected arguments */
    public var arguments (default,null) : Array<Match<Dynamic>>;
    /** expected return value */
    public var returns (default,null) : Value<Dynamic>;
    /** expected exception */
    public var throws (default,null) : Value<Dynamic>;
    /** Custom implementation for stubbed mehtod. Value should be a callback */
    public var implementation : Value<Dynamic>;
    /** Where this stub was created */
    public var pos (default,null) : PosInfos;


    /**
     * Constructor
     *
     */
    public function new (mockData:MockData, method:String, arguments:Array<Match<Dynamic>>, returns:Value<Dynamic>, throws:Value<Dynamic>, ?pos:PosInfos) : Void
    {
        this.mockData  = mockData;
        this.method    = method;
        this.arguments = arguments;
        this.returns   = returns;
        this.throws    = throws;
        this.pos       = pos;
    }


    /**
     * Expect this stub to be invoked `count` times
     *
     */
    public function expect (count:CallCount, ?pos:PosInfos) : Expect
    {
        var expect = new Expect(
            mockData,
            method,
            arguments,
            Nothing,
            Nothing,
            count,
            pos
        );
        mockData.expect(expect);

        return expect;
    }


    /**
     * Check if `method` invoked with `arguments` this stub.
     *
     */
    public function match (method:String, arguments:Array<Dynamic>) : Bool
    {
        if (this.method != method) return false;

        if (arguments.length != this.arguments.length) {
            throw 'Arguments count does not match';
        }

        for (i in 0...this.arguments.length) {
            if (!this.arguments[i].match(arguments[i])) return false;
        }

        return true;
    }


}//class Stub