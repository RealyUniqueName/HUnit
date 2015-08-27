package hunit.report;

import haxe.PosInfos;



typedef TestNotice = {
    caseName : String,
    testName : String,
    message  : String,
    pos      : PosInfos
}