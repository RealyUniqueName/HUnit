package hunit.report;




typedef TestSkip = {
    caseName : String,
    testName : String,
    //list of dependencies from @depends() meta
    depends : Array<String>
}