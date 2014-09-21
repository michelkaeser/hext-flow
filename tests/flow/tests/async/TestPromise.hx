package hxdispatch.tests.async;

import hxdispatch.async.Promise;

/**
 * TestSuite for the hxdispatch.async.Promise class.
 *
 * TODO: async specific tests
 * TODO: mock ThreadExecutor
 */
class TestPromise extends hxdispatch.tests.concurrent.TestPromise
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.promise = new Promise<Int>(new hxstd.threading.ThreadExecutor());
    }

    /**
     * @{inherit}
     */
    override private function getPromise(?resolves:Int = 1):hxdispatch.async.Promise<Dynamic>
    {
        return new Promise<Dynamic>(new hxstd.threading.ThreadExecutor(), resolves);
    }


    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testDoneWhenRejected():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.reject(input);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testDoneWhenResolved():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testExecuteCallbacksCatchesException():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            throw "Exception in Callback";
        });
        this.promise.done(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testMultipleResolves():Void
    {
        var executed:Bool = false;
        this.promise = this.getPromise(2);
        this.promise.done(function(arg:Int):Void {
            executed = true;
        });

        this.promise.resolve(0);
        assertFalse(executed);

        this.promise.resolve(0);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testRejected():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.rejected(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.reject(5);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testRejectedWhenResolved():Void
    {
        var executed:Bool = false;
        this.promise.rejected(function(arg:Int):Void {
            executed = true;
        });
        this.promise.resolve(0);
        Sys.sleep(0.5); // "wait" for async Promise
        assertFalse(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testResolved():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        });
        this.promise.resolve(input);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testResolvedWhenRejected():Void
    {
        var executed:Bool = false;
        this.promise.resolved(function(arg:Int):Void {
            executed = true;
        });
        this.promise.reject(0);
        Sys.sleep(0.5); // "wait" for async Promise
        assertFalse(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testWhen():Void
    {
        var p  = this.getPromise();
        var p2 = this.getPromise();
        var executed:Bool = false;

        Promise.when([p, p2]).done(function(arg:Int):Void {
            executed = true;
        });
        p.resolve(0); p2.resolve(0);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testWhenPassesArgument():Void
    {
        var p  = this.getPromise();
        var p2 = this.getPromise();
        var input:Int = 5;
        var value:Int = 0;

        Promise.when([p, p2]).done(function(arg:Int):Void {
            value = arg;
        });
        p.resolve(0); p2.resolve(input);
        Sys.sleep(0.5); // "wait" for async Promise
        assertEquals(input, value);
    }

    /**
     * Overriden since async Promise will not wait until the Callback sets the executed Bool to true.
     *
     * @{inherit}
     */
    override public function testWhenRejected():Void
    {
        var p  = this.getPromise();
        var p2 = this.getPromise();
        var executed:Bool = false;

        Promise.when([p, p2]).done(function(arg:Dynamic):Void {
            executed = true;
        });
        p.reject(0);
        Sys.sleep(0.5); // "wait" for async Promise
        assertTrue(executed);
    }
}
