package hunit.call.builder;

import haxe.PosInfos;
import hunit.call.Stub;
import hunit.call.Expect;
import hunit.match.Match;
import hunit.mock.MockData;
import hunit.call.CallCount;


/**
 * Build expectations
 *
 */
class ExpectCreator
{
    /** Position where `expect()` was called */
    private var pos : PosInfos;
    /** mock which this builder is working for */
    private var mockData : MockData;


    /**
     * Constructor
     *
     */
    public function new (mockData:MockData, ?pos:PosInfos) : Void
    {
        this.pos      = pos;
        this.mockData = mockData;
    }


    /**
     * Start stub creation
     *
     */
    private function __hu_create<T> (method:String, arguments:Array<Match<Dynamic>>) : ExpectFinisher<T>
    {
        var expect = new Expect(mockData, method, arguments, Nothing, Nothing, AtLeast(1), pos);
        mockData.expect(expect);

        return new ExpectFinisher<T>(expect);
    }


}//class ExpectCreator