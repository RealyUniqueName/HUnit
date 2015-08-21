package hunit.call;

import haxe.PosInfos;
import hunit.call.IExpect;
import hunit.match.Match;
import hunit.exceptions.*;
import hunit.mock.MockData;
import hunit.utils.Value;

using hunit.utils.Value;


/**
 * Expected method invocation
 *
 */
class Expect implements IExpect
{
    /** owner of this expectation */
    public var mockData (default,null) : MockData;
    /** method name */
    public var method (default,null) : String;
    /** expected arguments */
    public var arguments (default,null) : Array<Match<Dynamic>>;
    /** expected return value */
    public var returns (default,null) : Value<Match<Dynamic>>;
    /** expected exception */
    public var throws (default,null) : Value<Match<Dynamic>>;
    /** How many time this method with such parameters shoudld be called? */
    public var count (default,null) : CallCount;
    /** Where this expectation was created */
    public var pos (default,null) : PosInfos;
    /** How many times this expectations matched method calls during single test */
    public var timesMatched : Int = 0;


    /**
     * Constructor
     *
     */
    public function new (mockData:MockData, method:String, arguments:Array<Match<Dynamic>>, returns:Value<Match<Dynamic>>, throws:Value<Match<Dynamic>>, count:CallCount, ?pos:PosInfos) : Void
    {
        this.mockData  = mockData;
        this.method    = method;
        this.arguments = arguments;
        this.returns   = returns;
        this.throws    = throws;
        this.count     = count;
        this.pos       = pos;
    }


    /**
     * Check if `call` is an invocation of a method of the same object this instance expects.
     *
     */
    public function sameObjectMethod (call:Call) : Bool
    {
        return (mockData == call.mockData && method == call.method);
    }


    /**
     * Check if `method` with `arguments` and returned `result` or throwed `exception` match this expectation.
     *
     */
    public function match (call:Call) : Bool
    {
        if (mockData != call.mockData) return false;

        if (method != call.method) return false;

        if (arguments.length != call.arguments.length) {
            throw 'Arguments count does not match';
        }

        for (i in 0...arguments.length) {
            if (!arguments[i].match(call.arguments[i])) return false;
        }

        if (returns.hasValue()) {
            if (!call.result.hasValue()) return false;

            var expected = returns.getValue();
            var actual   = call.result.getValue();
            if (!expected.match(actual)) return false;
        }

        if (throws.hasValue()) {
            if (!call.exceptionValue.hasValue()) {
                return false;
            }

            var e = call.exceptionValue.getValue();
            if (!throws.getValue().match(e)) {
                return false;
            }
        }

        return true;
    }


    /**
     * Validate expectations are sutisfied. Throw exceptions otherwise.
     *
     */
    public function validate () : Void
    {
        mockData.validateExpectation(this);
    }


    /**
     * Check if this expectations was matched too many method calls (based on `count` & `timesMatched` properties)
     *
     */
    public function tooManyCalls () : Bool
    {
        return switch (count) {
            case Never           : timesMatched > 0;
            case Any             : false;
            case Once            : timesMatched > 1;
            case AtLeast(amount) : false;
            case Exactly(amount) : timesMatched > amount;
        }
    }


    /**
     * Convert this expectation to human-readable format
     *
     */
    public function toString () : String
    {
        var cls = mockData.mockClassName();
        var args = arguments.map(function(a) return '${a.toString()}').join(', ');

        var results : Array<String> = [];
        if (returns.hasValue()) {
            results.push('to return ${returns.getValue()}');
        }
        if (throws.hasValue()) {
            results.push('to throw ${throws.getValue()}');
        }

        switch (count) {
            case Any             : results.push('to be called zero or more times');
            case Never           : results.push('to be never called');
            case Once            : results.push('to be called once');
            case AtLeast(amount) : results.push('to be called at least $amount time' + (amount == 1 ? '' : 's'));
            case Exactly(amount) : results.push('to be called exactly $amount time' + (amount == 1 ? '' : 's'));
        }

        var last = results.pop();
        var toDo = (results.length == 0 ? last : results.join(', ') + ' and $last');
        var msg  = '$cls.$method($args) is expected $toDo';

        return msg;
    }

}//class Expect