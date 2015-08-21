package hunit.report;

import haxe.PosInfos;
import hunit.warnings.Warning;



typedef TestWarning = {
    caseName : String,
    testName : String,
    warning  : Warning
}