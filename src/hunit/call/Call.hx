package hunit.call;

import haxe.CallStack;
import haxe.PosInfos;
import hunit.mock.MockData;
import hunit.utils.Value;
import hunit.Utils;

using hunit.utils.Value;


/**
 * Contains data of single method call
 */
class Call
{
    /** call id */
    public var id (default,null) : Int;
    /** mock which owns called method */
    public var mockData (default,null) : MockData;
    /** called method */
    public var method (default,null) : String;
    /** arguments passed to method */
    public var arguments (default,null) : Array<Dynamic>;
    /** returned value */
    public var result : Value<Dynamic>;
    /** Description */
    public var stack (default,null) : Array<StackItem>;
    /** thrown exception */
    public var exceptionValue (default,set) : Value<Dynamic>;
    /** exception stack if any */
    public var exceptionStack (default,null) : Array<StackItem>;
    /** Whether this call was stubbed (true) or called the original method (false) */
    public var isStub (default,null) : Bool = false;
    /** if call was stubbed with specific stub, this is the stub configuration */
    public var stub (default,null) : Null<Stub>;
    /** Where this method was invoked from */
    public var pos (default,null) : PosInfos;


    /**
     * Cosntructor
     *
     */
    public function new (id:Int, mockData:MockData, method:String, arguments:Array<Dynamic>, stack:Array<StackItem>, pos:PosInfos, isStub:Bool, stub:Stub = null) : Void
    {
        this.id        = id;
        this.mockData  = mockData;
        this.method    = method;
        this.arguments = arguments;
        this.isStub    = isStub;
        this.stub      = stub;
        this.pos       = pos;
        this.stack     = stack;

        result = Nothing;
        exceptionValue = Nothing;
    }


    /**
     * Get string representation
     *
     */
    public function toString () : String
    {
        var str = '';
        if (result.hasValue()) {
            var value = result.getValue();
            str = 'returned ' + Utils.shortenQuote(value) + '';
        }

        if (exceptionValue.hasValue()) {
            var e = exceptionValue.getValue();
            var exceptionMsg = (
                Std.is(e, Exception)
                    ? Utils.shortenString(cast(e, Exception).message)
                    : Utils.shortenQuote(e)
            );

            str = 'threw $exceptionMsg';
        }

        var className = mockData.mockClassName();
        var args      = arguments.map(function(a) return Utils.shortenQuote(a)).join(', ');
        var msg       = '$className.${method}($args) $str';

        return msg;
    }


    /**
     * Setter `exceptionValue`
     *
     */
    private function set_exceptionValue (value:Value<Dynamic>) : Value<Dynamic>
    {
        if (value.hasValue()) {
            exceptionStack = CallStack.exceptionStack().concat(stack);
        }

        return exceptionValue = value;
    }

}//class Call