package hxdispatch.tests.async;

import hxdispatch.async.Dispatcher;

/**
 * TestSuite for the hxdispatch.async.Dispatcher class.
 *
 * TODO: async specific tests
 * TODO: mock ThreadExecutor
 */
class TestDispatcher extends hxdispatch.tests.concurrent.TestDispatcher
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.dispatcher = new Dispatcher<Int>(new hxstd.threading.ThreadExecutor());
    }


    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testAttach():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.dispatcher.register("event");
        assertTrue(this.dispatcher.attach("event", function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        }));
        this.dispatcher.trigger("event", input);
        Sys.sleep(0.2); // await async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testAttachDuplicate():Void
    {
        var executes:Int = 0;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            ++executes;
        });
        assertTrue(this.dispatcher.attach("event", function(arg:Int):Void {
            ++executes;
        }));
        this.dispatcher.trigger("event", 0);
        Sys.sleep(0.2); // await async Promise
        assertEquals(executes, 2);
    }

    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testAttachDuplicateReference():Void
    {
        var executes:Int = 0;
        this.dispatcher.register("event");
        var callback = function(arg:Int):Void {
            ++executes;
        };
        this.dispatcher.attach("event", callback);
        assertFalse(this.dispatcher.attach("event", callback));
        this.dispatcher.trigger("event", 0);
        Sys.sleep(0.2); // await async Promise
        assertEquals(executes, 1);
    }

    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testDettach():Void
    {
        var executes:Int = 0;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            ++executes;
        });
        assertFalse(this.dispatcher.dettach("event", function(arg:Int):Void {
            ++executes;
        }));
        this.dispatcher.trigger("event", 0);
        Sys.sleep(0.2); // await async Promise
        assertEquals(executes, 1);
    }

    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testTrigger():Void
    {
        var executed:Bool = false;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            executed = true;
        });
        this.dispatcher.trigger("event", 0);
        Sys.sleep(0.2); // await async Promise
        assertTrue(executed);
    }

    /**
     * Overriden since async Dispatcher returns another Status code.
     *
     * @{inherit}
     */
    override public function testTriggerExistingEvent():Void
    {
        this.dispatcher.register("event");
        assertEquals(this.dispatcher.trigger("event", 0).status, hxdispatch.Dispatcher.Status.TRIGGERED);
    }

    /**
     * Overriden since trigger() is async and we have to make sure the Callbacks are executed for this test.
     *
     * @{inherit}
     */
    override public function testTriggerPassesArgument():Void
    {
        var input:Int = 5;
        var value:Int = 0;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            value = arg;
        });
        this.dispatcher.trigger("event", input);
        Sys.sleep(0.2); // await async Promise
        assertEquals(input, value);
    }
}
