package hunit.call.builder;

import haxe.PosInfos;
import hunit.call.Stub;
import hunit.call.Expect;
import hunit.match.Match;
import hunit.mock.MockData;



/**
 * Build stubs
 *
 */
class StubCreator
{
    /** Position where `stub()` was called */
    private var pos : PosInfos;
    /** mock which this builder is working for */
    private var mockData : MockData;


    /**
     * Constructor
     *
     */
    public function new (mockData:MockData, ?pos:PosInfos): Void
    {
        this.mockData = mockData;
        this.pos = pos;
    }


    /**
     * Start stub creation
     *
     */
    private function __hu_create<S,R> (method:String, arguments:Array<Match<Dynamic>>) : StubFinisher<S,R>
    {
        var stub = new Stub(mockData, method, arguments, Nothing, Nothing, pos);
        mockData.stub(stub);

        return new StubFinisher<S,R>(stub);
    }


}//class StubCreator