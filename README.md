HUnit
=================
HUnit - crossplatform unit testing framework for Haxe language with built-in mocking, stubbing and spying.

Contents
-----------------
* [Why yet another unit testing framework?](#why-yet-another-unit-testing-framework)
* [Features](#features)
* [Installation](#installation)
* [Basic usage](#basic-usage)
* [Advanced usage](#advanced-usage)
* [Test cases](#test-cases)
* [Test reports](#test-reports)
* [Mocking](#mocking)
* [Mocking types with @:autoBuild macros](#mocking-types-with-autobuild-macros)
* [Stubbing](#stubbing)
* [Verifying method calls](#verifying-method-calls)
* [Validating exceptions](#validating-exceptions)
* [Assertions](#assertions)
* [Matchers](#matchers)
* [Compilation flags](#compilation-flags)
* [Meta for test methods](#meta-for-test-methods)
* [Limitations](#limitations)


Why yet another unit testing framework?
-----------------
Indeed, there are great frameworks like [utest](http://lib.haxe.org/p/utest/) and [munit](http://lib.haxe.org/p/munit/) already.
There is no strong reason for creating another one.
Short story:
In the beginning I was fine with standard `haxe.unit` package. Then with my project growth I need some more functionality,
which I implemented in some minor extensions for `haxe.unit`. At some point I became in need of mocking. [Mockatoo](http://lib.haxe.org/p/mockatoo/)
was great, but did not work on all targets, so i implemented simple mocking. And so on, and so forth...
Suddenly I looked at all that stuff and saw almost all `haxe.unit` code overriden by my 'extensions'.
So I decided to separate them into standalone unit testing framework.


Features
-----------------
* Assertions! Wow!
* Validating exceptions;
* Mocking, stubbing and verifying calls;
* Easy test suite setup;
* Grouping tests, which allows to include/exclude some tests when you want to check some specific things without running other tests.
* Verbose failure messages;
* All targets support.


Installation
-----------------
```
haxelib install hunit
```


Basic usage
-----------------
If you don't need any special configuration for your test suite, your `test.hxml` should look like this:
```
#path to your project sources
-cp src
#plug HUnit
-lib hunit
#path to the directory with test cases
-D HUNIT_DIR=tests
#use HUnit as entry point
-main HUnit
#for better stack traces
-debug
#project specific setup
-neko Test.n
```
Now all you need is to write your test cases.


Advanced usage
----------------
If you need some configuration before running any tests, you can use your own entry point like this:
```haxe
import hunit.TestSuite;
import hunit.TestReport;

class Test {
    static public function main () {
        //perform your setup
        //<...>

        //instantiate test suite
        var suite = new hunit.TestSuite();
        //add all tests in specified directory
        //this is a macro method, so you can use it on all targets
        //path should be specified relative to current .hx file
        suite.addDirectory('unit');
        //add some tests from other sources
        suite.add(new some.other.tests.ExampleTest());
        //start testing
        suite.run();

        //Finalize your testing. E.g. process test suite report
        var report : TestReport = suite.report;
        //<...>
    }
}
```


Test cases
-----------------
Test case classes should extend `hunit.TestCase`:
```haxe
class SomeFeatureTest extends hunit.TestCase
{
    /** Setup environment before the first test in current test case */
    override public function setupTestCase () : Void { }

    /** Setup new environment before each test */
    override public function setup () : Void { }

    /** Perform some cleaning after each test */
    override public function tearDown () : Void { }

    /** Perform some cleaning after last test in this test case */
    override public function tearDownTestCase () : Void { }

    /** Show `msg` in test suite report without affecting tests results */
    public function notice (msg:String) : Void { }

    /**
     * Test methods should start with `test` prefix or should be marked with `@test` meta
     */
    public function testSomeStuff()
    {
        var expected = 1;
        var actual   = 2 - 1;
        assert.equal(expected, actual, '2-1 and 1 should be equal');
    }

    @test
    public function someOtherStuff()
    {
        var expected = 'hello';
        var actual   = 'hell' + 'o';
        assert.equal(expected, actual);
    }
}
```


Test reports
-----------------
You can implement `hunit.IReportWriter` and pass it to `hunit.TestSuite` constructor to be able to create reports in xml
or json or to do whatever you want with tests results.

Mocking
-----------------
Right now mocking is only supported for classes and interfaces.
Abstracts and typedefs are candidates to be implemented.
Let's imagine we want to mock following class:
```haxe
class MyClass<T> {
    public var item : T;
    public function new (initial:T)
    {
        item = initial;
    }

    public function changeValue(newValue:T) : T
    {
        item = newValue;
        return newValue;
    }
}
```
Now, to mock it we use `mock()`  method of `hunit.TestCase`:
```haxe
class MyTest extends hunit.TestCase
{
    public function testMocking ()
    {
        //create mock without invoking original constructor. Pass list of type parameters as an array to second argument
        var m = mock(MyClass, [String]).get();
        //constructor was not invoked, thus `m.item` should not be initialized
        assert.isNull(m.item);

        //create mock using original constructor
        var m = mock(MyClass, [String]).create('Hello, world');
        //since we invoked constructor, `m.item` should be set
        assert.equal('Hello, world', m.item);

        //ensure we created `MyClass` instance
        assert.type(MyClass, m);
        //ensure we created a mock
        assert.type(hunit.mock.IMock, m);
    }
}
```

Mocking types with @:autoBuild macros
-----------------
If you are trying to mock some type which has `@:autoBuild` macros you can experience random bugs and unexpected behavior.
To avoid such issues check for `@:mock` meta in your macros and skip type building for types whith this meta.


Stubbing
-----------------
So you want to stub some methods? Easy!
```haxe
public function testStubbing ()
{
    var m = mock(MyClass, [String]).create('Hello');
    //`m.item` is set to 'Hello'
    assert.equal('Hello', m.item);

    //stub method `changeValue` of `m` instance
    stub(m).changeValue();
    m.changeValue('some other stuff');
    //still 'Hello'
    assert.equal(item, m.item);

    //want your stub to return predefined value? Here you are
    stub(m).changeValue().returns('World');
    var actual = m.changeValue('some other stuff');
    assert.equal('World', actual);
    assert.equal('Hello', m.item);

    //want your stub to throw an exception?
    stub(m).changeValue().throws('Terrible error');
    try {
        m.changeValue('oops');
    } catch (e:Dynamic) {
        assert.equal('Terrible error', e);
        assert.equal('Hello', m.item);
    }

    //need different behavior for different argument values?
    stub(m).changeValue('Hello').returns('World');
    stub(m).changeValue('oops').throws('Terrible error');

    //implement custom behavior
    sutb(m).changeValue().implement(function (item:String) {
        //do some crazy stuff
    });

    //stub all methods by default
    var m = mock(MyClass, [String]).stubAll().create('Hello');
    //but one method should use original behavior
    expect(m).changeValue().unstub();
}
```
You can pass matchers instead of exact values to stubbed method arguments. Read below for more on matchers.
By default stubbed methods return `null` or type specific default value for `Int`, `Bool`, `Float` on static platforms.


Verifying method calls
-----------------
If you need to ensure your tested unit calls some methods, you can use `expect()` of `hunit.TestCase`
```haxe
public function testInvocation ()
{
    var m = mock(MyClass, [String]).create('Hello');
    //Or if you want your test to fail if any method except expected one is invoked, add `strict()`:
    var m = mock(MyClass, [String]).strict().create('Hello');

    //test will fail if `changeValue()` method of `m` will not be executed with 'World' argument
    expect(m).changeValue('World');

    //fail if `changeValue()` will not return 'World'
    expect(m).changeValue().returns('World');

    //fail if `changeValue()` will not throw specified exception
    expect(m).changeValue().throws('Terrible error');

    //fail if `changeValue()` will be called less than two times
    expect(m).changeValue().atLeast(2);

    //or fail if combination of above expectations will not be satisfied
    expect(m).changeValue('World').returns('World').atLeast(2);

    //you can also expect invocations of stubbed methods
    stub(m).changeValue('World').returns('World').exactly(2);

    var testedUnit = function () {
        m.changeValue('World');
    }
}
```
You can pass matchers instead of exact values to expected arguments, return values or exception. Read below for more on matchers.
Specify the amount of expected calls using these methods:

* `any()` (default) Never fail because of invocations count;
* `once()` Test passes if method will be called one time only;
* `never()` Test passes if method will be never called;
* `atLeast(amount)` Test passes if method will be called at least `amount` times;
* `exactly(amount)` Test passes if method will be called exactly `amount` times.


Validating exceptions
-----------------
If you want to be sure some unit throws exception.
```
public function testMethodThrowsException ()
{
    expectException('Terrible error');

    var testedUnit = function () throw 'Terrible error';

    testedUnit();
}
```
This test will pass only if 'Terrible error' will be raised.
Instead of exact value you can pass matchers to `expectException()`.  Read below for more on matchers.


Assertions
-----------------
These are implemented assertions, which you can invoke on `assert` property of `hunit.TestCase`.
Use `message` argument to print custom message if assertion fails.
Don't pass `pos` argument unless you know what you're doing.
```haxe
/** Validate `value` against matcher. More on matchers below. */
assert.match<T> (match:Match<T>, value:T, message:String = null, ?pos:PosInfos);

/**
 * Success if `expected` and `actual` are equal.
 * Compares enums with `Type.enumEq()`, callbacks with `Reflect.compareMethods()` and everything else with `==`.
 */
assert.equal<T> (expected:T, actual:T, message:String = null, ?pos:PosInfos);

/** Success if `expected` and `actual` are not equal */
assert.notEqual<T> (expected:T, actual:T, message:String = null, ?pos:PosInfos);

/** Success if type of `value` is of `expectedType` */
assert.type (expectedType:Class<Dynamic>, value:Dynamic, message:String = null, ?pos:PosInfos);

/** Success if `value` is null */
assert.isNull (value:Dynamic, message:String = null, ?pos:PosInfos);

/** Success if `value` is not null */
assert.notNull (value:Dynamic, message:String = null, ?pos:PosInfos);

/** Success if `value` is `true` */
assert.isTrue (value:Bool, message:String = null, ?pos:PosInfos);

/** Success if `value` is `false` */
assert.isFalse (value:Bool, message:String = null, ?pos:PosInfos);

/** Success if `pattern` regexp match `value`*/
assert.regexp (pattern:EReg, value:String, message:String = null, ?pos:PosInfos);

/**
 * Success if `expected` and `actual` are similar objects/arrays/maps.
 *
 * Asserting with objects:
 * All fields of `expected` object must have corresponding fields in `actual` object to pass this assertion.
 * Object `actual` is allowed to have fields, which do not exist in `expected` object.
 * It's not necessary for `expected` and `actual` to be instances of the same type.
 * Fields values of `expected` object can be matchers.
 *
 * Asserting with arrays:
 * To pass this assertion `actual` and `expected` arrays must be of the same length and
 * have corresponding elements match each other.
 * Elements of `expected` array can be matchers.
 *
 * Asserting with maps:
 * `expected` and `actual` maps must have the same set of keys and their corresponding values must match each other.
 * Values of `expected` map can be matchers.
 */
assert.similar (expected:Dynamic, actual:Dynamic, message:String = null, ?pos:PosInfos);

/** Force test failure */
assert.fail (message:String = null, ?pos:PosInfos);

/** Add warning to test report */
assert.warn (message:String = null, ?pos:PosInfos);

/** Mark test as successful if there are no other assertions in test */
assert.success (?pos:PosInfos);
```


Matchers
-----------------
Matchers are used to check if verified values match expected values.
They are available as methods of `match` property of `hunit.TestCase`.

You can use matchers as arguments for stubbed or expected method calls, expected method result and expected exceptions:
```haxe
var m = mock(MyClass, [String]).get();

//match any string argument
expect(m).changeValue(match.type(String));
//match any string which match specified regular expression
stub(m).changeValue(match.regexp(~/ello$/i));

//expect method to return a value which is not equal to 'World'
expect(m).changeValue().returns(match.notEqual('World'));

//expect method to throw any exception
expect(m).changeValue().throws(match.any());

//expect raising object exception with field `message` which is equal with 'Terrible error' and `code` field not equal with `10`
expectException(match.similar(
    {
        message : 'Terrible error',
        code    : match.notEqual(10)
    }
));

//you can also chain matchers so that verified value will match only if all matchers are satisfied
//Chain of matchers is processed "as is" without any priority.
expect(m).changeValue( match.regexp(~/ello/i).and.notEqual('Hello').or.equal('World') );
```
Here is a list of implemented matchers:
```haxe
/** Match any value */
match.any ();

/** Match values of specified `type` */
match.type<T> (type:Class<T>);

/** Match strings which match `pattern` */
match.regexp (pattern:EReg);

/** Match objects whose fields values match corresponding fields values of `pattern`. */
match.similar (pattern:Dynamic);

/** Match values which are equal to `value` */
match.equal<T> (value:T);

/** Match values which are not equal to `value` */
match.notEqual<T> (value:T);

/** Match if `verify()` returns `true` when invoked against verified value */
match.callback<T> (verify:T->Bool);
```


Compilation flags
-----------------
* `-main HUnit`
If your test suite does not need any special configuration, you can use `HUnit` as main class for test suite.
* `-D HUNIT_TEST_DIR=path/to/dir`
Adds all tests in path/to/dir to test suite if combined with `-main HUnit`.
Path should be specified relative to current working directory from which `haxe` compiler is executed.
* `-D HUNIT_EXCLUDE=some.tests,some.SingleTest,<...>`
Exclude specified packages and/or classes from test suite
* `-D HUNIT_GROUP=group1,group2,<...>`
Run tests assigned to specified groups only. Tests can be assigned to some groups by adding meta `@group(group1,group4,group8)` to test methods.
* `-D HUNIT_EXCLUDE_GROUP=group1,group2,<...>`
Do not run tests assigned to specified groups.


Meta for test methods
---------------------
* `@test`
Method is considered to be a test if marked with this meta.
* `@group('group1', 'group2', <...>)`
Assign test to specified groups.
* `@incomplete('Because something is not implemented')`
Mark test as incomplete. This meta will add warning to test report.
* `@depends('testAnotherThing', 'testDifferentThing')`
If `testAnotherThing` fails or `testDifferentThig` fails, then test with this meta will be skipped. All these tests must be in one TestCase.


Limitations
-----------
It's not allowed to stub or expect `toString()` methods. HXCPP does not allow methods named `toString()` to return values
other than strings, while HUnit needs to return another type to chain configuration methods for stubs and expects.
If you really need to operate `toString()` create another method like `asString()` and use it.

