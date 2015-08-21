package hunit.report;

import hunit.exceptions.TestFailException;
import hunit.exceptions.UnexpectedCallException;
import hunit.exceptions.UnexpectedException;
import hunit.report.TestReport;
import haxe.PosInfos;
import hunit.Utils;

using StringTools;


/**
 * Default output
 *
 */
class DefaultWriter implements IReportWriter
{
    /** Counts every written item */
    private var itemsWriteCounter : Int = 0;
    /** Printer method */
    private var printer : Dynamic->Void;


    /**
     * Cosntructor
     *
     */
    public function new (printer:Dynamic->Void) : Void
    {
        this.printer = printer;
    }


    /**
     * Output `report`
     *
     */
    public function write (report:TestReport) : Void
    {
        if (report.fails.length > 0) {
            printer('FAILURES:\n\n');

            for (fail in report.fails) {
                writeFail(fail);
            }
        }

        itemsWriteCounter = 0;

        if (report.warnings.length > 0) {
            printer('WARNINGS:\n');

            for (warning in report.warnings) {
                writeWarning(warning);
            }
        }
    }


    /**
     * Write single fail
     *
     */
    private function writeFail (item:TestFail) : Void
    {
        var pos     = item.exception.pos;
        var message = item.exception.message;
        var e       = item.exception;

        if (Std.is(e, TestFailException)) {
            if (Std.is(e, UnexpectedCallException)) {
                pos = null;
                message += cast(e, Exception).stringStack().replace('\n', '\n\t');
            }

        } else {
            pos = null;

            var customMessage = false;
            if (Std.is(e, UnexpectedException)) {
                var e = cast(e, UnexpectedException);
                customMessage = true;

                if (Std.is(e.original, Exception)){
                    message = 'ERROR: ' + cast(e.original, Exception).toString();
                } else {
                    message = 'ERROR: $e';
                }
            }

            if (!customMessage) {
                message = 'ERROR: ' + e.message + '\n\n' + e.toString();
            }
        }

        writeItem(item.caseName, item.testName, message, pos);
    }


    /**
     * Write single warning
     *
     */
    private function writeWarning (item:TestWarning) : Void
    {
        writeItem(item.caseName, item.testName, item.warning.message, null);
    }


    /**
     * Render single item of a report
     *
     */
    private function writeItem (caseName:String, test:String, message:String, pos:Null<PosInfos>) : Void
    {
        itemsWriteCounter ++;

        var idx = itemsWriteCounter;

        printer('$idx) $caseName::$test()\n');
        printer('$message\n');
        printer('\n');

        if (pos != null) {
            printer('\t${pos.fileName}:${pos.lineNumber}\n');
            printer('\n');
        }
    }

}//class DefaultWriter