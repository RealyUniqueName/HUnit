package hunit.report;

import hunit.report.TestReport;



/**
 * Outputs test reports
 *
 */
interface IReportWriter
{

    /**
     * Output `report`
     *
     */
    public function write (report:TestReport) : Void ;

}//interface IReportWriter