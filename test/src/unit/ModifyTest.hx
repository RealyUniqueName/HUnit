package unit;

import hunit.TestCase;


class ModifyDummy {
    public var publicVar (null,null)      : String = 'world';
    private var privateProperty (get,set) : String;
    private var privateVar                : String = 'world';
    private var privatePropertyValue      : String = 'world';

    public function new () {}
    private function get_privateProperty ()  return privatePropertyValue;
    private function set_privateProperty (v) return privatePropertyValue = v;
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
    public function testPrivateVarSet () : Void
    {
        var m = mock(ModifyDummy).create();

        modify(m).privateVar = 'hello';

        assert.equal('hello', Reflect.getProperty(m, 'privateVar'));
    }


    /**
     * Check write access to public variable with `null` set access
     *
     */
    public function testPublicVarWithNullSetSet () : Void
    {
        var m = mock(ModifyDummy).create();

        modify(m).publicVar = 'hello';

        assert.equal('hello', Reflect.getProperty(m, 'publicVar'));
    }


    /**
     * Check write access to private property
     *
     */
    public function testPrivatePropertySet () : Void
    {
        var m = mock(ModifyDummy).create();

        modify(m).privateProperty = 'hello';

        assert.equal('hello', Reflect.getProperty(m, 'privatePropertyValue'));
    }


    /**
     * Check read access to private variable
     *
     */
    public function testPrivateVarGet () : Void
    {
        var m = mock(ModifyDummy).create();

        var value = modify(m).privateVar;

        assert.equal('world', value);
    }


    /**
     * Check read access to public variable with `null` get access
     *
     */
    public function testPublicVarWithNullSetGet () : Void
    {
        var m = mock(ModifyDummy).create();

        var value = modify(m).publicVar;

        assert.equal('world', value);
    }


    /**
     * Check read access to private property
     *
     */
    public function testPrivatePropertyGet () : Void
    {
        var m = mock(ModifyDummy).create();

        var value = modify(m).privateProperty;

        assert.equal('world', value);
    }

}//class ModifyTest