package hunit.call.builder;

import hunit.utils.Value;
import hunit.call.CallCount;

using hunit.utils.Value;


/**
 * Additional modifications of just created stub
 *
 */
@:access(hunit.call.Stub)
class StubFinisher<SIGNATURE,RETURNS>
{
    /** Modified stub */
    private var stub : Stub;
    /** expectation for this stub */
    private var expect : Null<Expect>;


    /**
     * Constructor
     *
     */
    public function new (stub:Stub) : Void
    {
        this.stub = stub;
    }


    /**
     * Set custom implementation for stubbed method.
     *
     */
    public function implement (implementation:SIGNATURE) : StubFinisher<SIGNATURE,RETURNS>
    {
        if (stub.returns.hasValue() || stub.throws.hasValue()) {
            throw new Exception('Either stub exception or return value is already set');
        }
        stub.implementation = Thing(implementation);

        return this;
    }


    /**
     * Set return value
     *
     */
    public function returns (value:RETURNS) : StubFinisher<SIGNATURE,RETURNS>
    {
        if (stub.returns.hasValue() || stub.implementation.hasValue()) {
            throw new Exception('Either stub return value or implementation is already set');
        }
        stub.returns = Thing(value);

        return this;
    }


    /**
     * Make this stub invocation throw an `exception`
     *
     */
    public function throws<T> (exception:T) : StubFinisher<SIGNATURE,RETURNS>
    {
        if (stub.throws.hasValue() || stub.implementation.hasValue()) {
            throw new Exception('Either stub exception or implementation is already set');
        }
        stub.throws = Thing(exception);

        return this;
    }


    /**
     * Expect this stub to be never invoked
     *
     */
    public function never () : StubFinisher<SIGNATURE,RETURNS>
    {
        if (expect != null) throw new Exception('Stub call expectation is already set');
        expect = stub.expect(Never);

        return this;
    }


    /**
     * Expect this stub to be invoked any amount of times
     *
     */
    public function any () : StubFinisher<SIGNATURE,RETURNS>
    {
        if (expect != null) throw new Exception('Stub call expectation is already set');
        expect = stub.expect(Any);

        return this;
    }


    /**
     * Expect this stub to be invoked once
     *
     */
    public function once () : StubFinisher<SIGNATURE,RETURNS>
    {
        if (expect != null) throw new Exception('Stub call expectation is already set');
        expect = stub.expect(Once);

        return this;
    }


    /**
     * Expect this stub to be invoked at least `amount` times
     *
     */
    public function atLeast (amount:Int) : StubFinisher<SIGNATURE,RETURNS>
    {
        if (expect != null) throw new Exception('Stub call expectation is already set');
        expect = stub.expect(AtLeast(amount));

        return this;
    }


    /**
     * Expect this stub to be invoked exactly `amount` times
     *
     */
    public function exactly (amount:Int) : StubFinisher<SIGNATURE,RETURNS>
    {
        if (expect != null) throw new Exception('Stub call expectation is already set');
        expect = stub.expect(Exactly(amount));

        return this;
    }

}//class StubFinisher