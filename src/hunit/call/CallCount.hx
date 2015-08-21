package hunit.call;



/**
 * How many times method should be invoked
 *
 */
enum CallCount
{

    Never;
    Any;
    Once;
    AtLeast(amount:Int);
    Exactly(amount:Int);

}