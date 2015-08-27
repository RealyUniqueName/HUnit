package hunit.warnings;

import hunit.warnings.Warning;


/**
 * When test is marked as icomplete
 *
 */
class IncompleteTestWarning extends Warning
{

    /**
     * Default warning message is used if provided one is empty.
     *
     */
    override private function defaultMessage () : String
    {
        return 'Incomplete test.';
    }

}//class IncompleteTestWarning