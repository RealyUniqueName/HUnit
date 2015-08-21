package hunit.exceptions;

import haxe.CallStack;
import haxe.PosInfos;



/**
 * Excpetions thrown by third-party code
 *
 */
class UnexpectedException extends Exception
{
    /** Original exception */
    public var original (default,null) : Dynamic;
    /** Original exception stack. This is required for JS target. */
    private var originalExceptionStack : Array<StackItem>;

    /**
     * Cosntructor
     *
     */
    public function new (e:Dynamic, exceptionStack:Array<StackItem>, ?pos:PosInfos) : Void
    {
        // trace(CallStack.toString(exceptionStack));
        originalExceptionStack = exceptionStack;
        original = e;

        super(Std.string(e), pos);
    }


    /**
     * Get string representation of this exception
     *
     */
    override public function toString () : String
    {
        if (Std.is(original, Exception)) {
            var className = Type.getClassName(Type.getClass(this));
            return '$className: ' + cast(original, Exception).toString();
        } else {
            return super.toString();
        }
    }


    /**
     * Build call stack using original exception stack
     *
     */
    override private function buildStack (stack:Array<StackItem>) : Array<StackItem>
    {
        var exceptionStack = originalExceptionStack;

        //Exception already provides all required data
        if (Std.is(original, Exception)) {
            pos = cast(original, Exception).pos;
            exceptionStack = cast(original, Exception).stack.copy();

        //try to extract required data from other types of exceptions
        } else {
            //target platform does not provide exception stack
            if (exceptionStack.length == 0) {
                exceptionStack = stack;

            //if exception stack is provided, get original exception position
            } else {
                switch (exceptionStack[0]) {
                    case FilePos(null, file, line):
                        pos.fileName   = file;
                        pos.lineNumber = line;
                    case FilePos(Method(className, methodName), file, line):
                        pos.className  = className;
                        pos.methodName = methodName;
                        pos.fileName   = file;
                        pos.lineNumber = line;
                    case Method(className, methodName):
                        pos.methodName = methodName;
                        pos.className  = className;
                    case _:
                }
            }
        }

        return super.buildStack(exceptionStack);
    }

}//class UnexpectedException