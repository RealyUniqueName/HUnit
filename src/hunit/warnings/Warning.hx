package hunit.warnings;

using StringTools;


/**
 * Base clas for warnings
 *
 */
class Warning
{

    /** Warning message */
    public var message (default, null) : String;


    /**
     * Cosntructor
     *
     */
    public function new (message:String) : Void
    {
        if (message == null || message.trim().length == 0) {
            message = defaultMessage();
        }

        this.message = message;
    }

    /**
     * Default warning message is used if provided one is empty.
     *
     */
    private function defaultMessage () : String
    {
        var className = Type.getClassName(Type.getClass(this)).split('.').pop();

        var words : Array<String> = [];
        var wordStart = -1;
        for (i in 0...className.length) {
            var char = className.charAt(i);

            if (char.toUpperCase() == char) {
                if (wordStart >= 0) {
                    var word = className.substring(wordStart, i);
                    if (wordStart > 0) {
                        word = word.toLowerCase();
                    }

                    words.push(word);
                }
                wordStart = i;
            }
        }
        if (wordStart >= 0) {
            words.push(className.substr(wordStart).toLowerCase());
        }

        return words.join(' ');
    }

}//class Warning