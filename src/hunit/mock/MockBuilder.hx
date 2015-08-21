package hunit.mock;

import hunit.exceptions.InvalidTestException;
import hunit.mock.MockData;
import hunit.TestCase;


/**
 * Methods to create mocks at runtime.
 *
 */
class MockBuilder<T>
{
    /** test case which this mock is being created for */
    private var test : TestCase;
    /** generated class for a mock */
    private var mockClass   : Class<T>;
    private var targetClass : Class<Dynamic>;
    /** Should all methods be stubbed by default? */
    private var fullStub (default,set) : Bool = false;
    /** Throw exceptions for each called method which was not configured with `stub()` or `expect()` */
    private var strictMode (default,set) : Bool = false;


    /**
     * Cosntructor
     *
     */
    public function new (test:TestCase, mockClass:Class<T>, targetClass:Class<Dynamic>) : Void
    {
        this.test        = test;
        this.mockClass   = mockClass;
        this.targetClass = targetClass;
    }


    /**
     * Create mock instance without calling original class constructor
     *
     */
    public function get () : T
    {
        var instance : T = Type.createEmptyInstance(mockClass);
        assignMockData(instance);

        return instance;
    }


    /**
     * Create new `MockData` for mock `instance`
     *
     */
    private function assignMockData (instance:T) : Void
    {
        var mockData = new MockData(this.test, targetClass, fullStub, strictMode);
        Reflect.setProperty(instance, '__hu_mock__', mockData);
    }


    /**
     * Setter `strictMode`
     *
     */
    private function set_strictMode (value:Bool) : Bool
    {
        if (fullStub) {
            throw new InvalidTestException('Cannot use `stubAll()` and `strict()` together.');
        }

        return strictMode = value;
    }


    /**
     * Setter `fullStub`
     *
     */
    private function set_fullStub (value:Bool) : Bool
    {
        if (strictMode) {
            throw new InvalidTestException('Cannot use `stubAll()` and `strict()` together.');
        }

        return fullStub = value;
    }

}//class MockBuilder