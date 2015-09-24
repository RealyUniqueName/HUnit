package hunit.call.builder;

import haxe.PosInfos;
import hunit.exceptions.InvalidTestException;
import hunit.Match;
import hunit.match.Match in RealMatch;
import hunit.utils.Value;
import hunit.call.CallCount;

using hunit.utils.Value;


/**
 * Additional modifications of just created expect
 *
 */
@:access(hunit.call.Expect)
class ExpectFinisher<RETURNS>
{
    /** Modified expectation */
    private var expect : Expect;


    /**
     * Constructor
     *
     */
    public function new (expect:Expect) : Void
    {
        this.expect = expect;
    }


    /**
     * Expect this call to return `value`
     *
     */
    public function returns (value:Match<RETURNS>) : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Expected return value is already set');
        expect.returns = Thing((value:RealMatch<Dynamic>));

        return this;
    }


    /**
     * Expect `exception` to be thrown
     *
     */
    public function throws (exception:Match<Dynamic>) : ExpectFinisher<RETURNS>
    {
        if (expect.throws.hasValue()) throw new Exception('Expected exception is already set');
        expect.throws = Thing((exception:RealMatch<Dynamic>));

        return this;
    }


    /**
     * Make expected method execute original code instead or doing nothing if `mock(MockedClass).stubAll()` was invoked.
     *
     * @throws hunit.exceptions.InvalidTestException If expected method has direct stubs configured with `stub(mockInstance)`
     */
    public function unstub (?pos:PosInfos) : ExpectFinisher<RETURNS>
    {
        try {
            expect.mockData.unstub(expect.method, pos);
        } catch(e:InvalidTestException) {
            expect.mockData.removeExpect(expect);

            throw e;
        }

        return this;
    }


    /**
     * Expect this call to be never invoked
     *
     */
    public function never () : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Calls expectation is already set');
        expect.count = Never;

        return this;
    }


    /**
     * Expect this call to be invoked any amount of times
     *
     */
    public function any () : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Calls expectation is already set');
        expect.count = Any;

        return this;
    }


    /**
     * Expect this call to be invoked once
     *
     */
    public function once () : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Calls expectation is already set');
        expect.count = Once;

        return this;
    }


    /**
     * Expect this call to be invoked at least `amount` times
     *
     */
    public function atLeast (amount:Int) : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Calls expectation is already set');
        expect.count = AtLeast(amount);

        return this;
    }


    /**
     * Expect this call to be invoked exactly `amount` times
     *
     */
    public function exactly (amount:Int) : ExpectFinisher<RETURNS>
    {
        if (expect.returns.hasValue()) throw new Exception('Calls expectation is already set');
        expect.count = Exactly(amount);

        return this;
    }

}//class ExpectFinisher