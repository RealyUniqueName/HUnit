package unit;

import hunit.TestCase;


class ModifyDummy {
    public var publicVar (default,null)       : String;
    private var privateProperty (default,set) : String;
    private var privateVar                    : String;

    public function new () {}
    public function getPrivateVarValue () return privateVar;
    public function getPrivatePropertyValue () return privateProperty;
    private function set_privateProperty (v) return privateProperty = v;
}


/**
 * Check `TestCase.modify()`
 *
 */
class ModifyTest extends TestCase
{

    /**
     * Check write access to private variable
     *
     */
    public function testPrivateVar () : Void
    {
        var m = mock(ModifyDummy).get();

        modify(m).privateVar = 'hello';

        assert.equal('hello', m.getPrivateVarValue());
    }


    /**
     * Check write access to public variable with null` set access
     *
     */
    public function testPublicVarWithNullSet () : Void
    {
        var m = mock(ModifyDummy).get();

        modify(m).publicVar = 'hello';

        assert.equal('hello', m.publicVar);
    }


    /**
     * Check write access to private property
     *
     */
    public function testPrivateProperty () : Void
    {
        var m = mock(ModifyDummy).get();

        modify(m).privateProperty = 'hello';

        assert.equal('hello', m.getPrivatePropertyValue());
    }

}//class ModifyTest