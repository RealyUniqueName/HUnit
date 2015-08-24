package hunit.utils;

import haxe.rtti.CType;


/**
 * Utilities for fields retrieved from RTTI
 *
 */
class CTypeClassFieldsUtils
{
    /** If method starts with this string or has this meta, it is considered to be a test */
    static public inline var TEST_INDICATOR = 'test';


    /**
     * Check if field implements test
     *
     */
    static public function isTest (field:ClassField) : Bool
    {
        //field name starts  with 'test'
        if (field.name.substr(0, TEST_INDICATOR.length) == TEST_INDICATOR) {
            return true;

        } else {
            for (meta in field.meta) {
                //field has meta @test
                if (meta.name == TEST_INDICATOR) {
                    return true;
                }
            }
        }

        return false;
    }

}//class CTypeClassFieldsUtils