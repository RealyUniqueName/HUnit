package hunit.match;

import hunit.match.Match;
import hunit.Utils;
import Type;

using StringTools;
using hunit.Utils;


/**
 * Match strings which match regular expression
 *
 */
class ERegMatch<T> extends Match<T>
{
    /** Compare against this expression */
    public var regexp (default,null) : EReg;


    /**
     * Cosntructor
     *
     */
    public function new (regexp:EReg, previous:Match<T> = null, chainLogic:MatchChainLogic = null) : Void
    {
        super(previous, chainLogic);
        this.regexp = regexp;
    }


    /**
     * Check mathing
     *
     */
    override private function checkMatch (value:Dynamic) : Bool
    {
        return regexp.match(Std.string(value));
    }


    /**
     * Get string representation
     *
     */
    override private function shortCode () : String
    {
        return extractPattern();
    }


    /**
     * Try to retreive pattern string
     *
     */
    private function extractPattern () : String
    {
        var pattern : String =
        #if php        '~/' + Reflect.getProperty(regexp, 'pattern') + '/' + Reflect.getProperty(regexp, 'options');
        #elseif js     '~' + Reflect.getProperty(regexp, 'r').toString();
        #elseif cs     '~/' + Std.string(Reflect.getProperty(regexp, 'regex')) + '/';
        #elseif java   '~/' + Std.string(Reflect.getProperty(regexp, 'pattern')) + '/';
        #elseif flash  '~' + Std.string(Reflect.getProperty(regexp, 'r'));
        #elseif python '~/' + Std.string(Reflect.getProperty(regexp, 'pattern').pattern) + '/' + getRegexpOptions();
        #else 'EReg';
        #end

        return pattern;
    }


#if python
    private function getRegexpOptions () : String
    {
        var flags : Int = Reflect.getProperty(regexp, 'pattern').flags;
        var options = '';

        if (flags & python.lib.Re.I != 0) options += 'i';
        if (flags & python.lib.Re.M != 0) options += 'm';
        if (flags & python.lib.Re.S != 0) options += 's';

        return options;
    }
#end

}//class ERegMatch