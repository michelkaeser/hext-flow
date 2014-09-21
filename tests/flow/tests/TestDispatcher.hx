package flow.tests;

import flow.Dispatcher;

/**
 * TestSuite for the flow.Dispatcher class.
 */
class TestDispatcher extends haxe.unit.TestCase
{
    /**
     * Stores the Dispatcher on which the tests are run.
     *
     * @var flow.Dispatcher<Int>
     */
    private var dispatcher:Dispatcher<Int>;


    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.dispatcher = new Dispatcher<Int>();
    }

    /**
     *@{inherit}
     */
    override public function tearDown():Void
    {
        this.dispatcher = null;
    }


    /**
     * Checks that Callbacks added via attach() are executed/thus added.
     *
     * Attn: This test depends on the register() and trigger() methods - make sure they work
     * before looking for errors in attach().
     */
    public function testAttach():Void
    {
        var input:Int = 5;
        var executed:Bool = false;
        this.dispatcher.register("event");
        assertTrue(this.dispatcher.attach("event", function(arg:Int):Void {
            assertEquals(input, arg);
            executed = true;
        }));
        this.dispatcher.trigger("event", input);
        assertTrue(executed);
    }

    /**
     * Checks that attaching the same Callback twice (but not per reference) works.
     *
     * Attn: This test depends on the register() and trigger() methods - make sure they work
     * before looking for errors in attach().
     */
    public function testAttachDuplicate():Void
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
        assertEquals(executes, 2);
    }

    /**
     * Checks that attaching the same Callback twice only adds it once.
     *
     * Attn: This test depends on the register() and trigger() methods - make sure they work
     * before looking for errors in attach().
     */
    public function testAttachDuplicateReference():Void
    {
        var executes:Int = 0;
        this.dispatcher.register("event");
        var callback = function(arg:Int):Void {
            ++executes;
        };
        this.dispatcher.attach("event", callback);
        assertFalse(this.dispatcher.attach("event", callback));
        this.dispatcher.trigger("event", 0);
        assertEquals(executes, 1);
    }

    /**
     * Checks that the attach() method returns false when trying to attach
     * a Callback to a non-existing Event.
     * This is needed so the caller knows the Callback is not added.
     */
    public function testAttachNonExistingEvent():Void
    {
        assertFalse(this.dispatcher.attach("event", function(arg:Int):Void {}));
    }

    /**
     * Checks that dettach() doesn't removes the Callback from the Event's Callback list when
     * not passed as reference.
     *
     * Attn: This test depends on the register() and trigger() methods - make sure they work
     * before looking for errors in dettach().
     */
    public function testDettach():Void
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
        assertEquals(executes, 1);
    }

    /**
     * Checks that dettach() removes the Callback from the Event's Callback list.
     *
     * Attn: This test depends on the register() and trigger() methods - make sure they work
     * before looking for errors in dettach().
     */
    public function testDettachReference():Void
    {
        var executes:Int = 0;
        var callback = function(arg:Int):Void {
            ++executes;
        };
        this.dispatcher.register("event");
        this.dispatcher.attach("event", callback);
        assertTrue(this.dispatcher.dettach("event", callback));
        this.dispatcher.trigger("event", 0);
        assertEquals(executes, 0);
    }

    /**
     * Checks that the dettach() method returns false when trying to dettach
     * a Callback from a non-existing Event.
     * This is needed so the caller knows nothing was done
     */
    public function testDettachNonExistingEvent():Void
    {
        assertFalse(this.dispatcher.dettach("event", function(arg:Int):Void {}));
    }

    /**
     * Checks the hasEvent() method.
     *
     * Attn: This test depends on the register() method - make sure tests for this class pass
     * before looking for errors in the hasEvent() method.
     */
    public function testHasEvent():Void
    {
        var event:hxdispatch.Event = "event";
        assertFalse(this.dispatcher.hasEvent(event));
        this.dispatcher.register(event);
        assertTrue(this.dispatcher.hasEvent(event));
    }

    /**
     * Checks the register() method really adds the Event to the Dispatcher.
     *
     * Attn: This test depends on hasEvent() method - make sure it works before
     * looking for errors in register() method.
     */
    public function testRegister():Void
    {
        assertTrue(this.dispatcher.register("event"));
        assertTrue(this.dispatcher.hasEvent("event"));
    }

    /**
     * Checks the register() method returns false when adding the same Event twice.
     */
    public function testRegisterTwice():Void
    {
        this.dispatcher.register("event");
        assertFalse(this.dispatcher.register("event"));
    }

    /**
     * Checks that the trigger() method executes registered Callbacks.
     *
     * Attn: This tests depends on the register() and attach() methods - make sure they work before
     * looking for errors in trigger() method.
     */
    public function testTrigger():Void
    {
        var executed:Bool = false;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            executed = true;
        });
        this.dispatcher.trigger("event", 0);
        assertTrue(executed);
    }

    /**
     * Checks that the trigger() method passes the correct argument to the Callbacks.
     *
     * Attn: This tests depends on the register() and attach() methods - make sure they work before
     * looking for errors in trigger() method.
     */
    public function testTriggerPassesArgument():Void
    {
        var input:Int = 5;
        var value:Int = 0;
        this.dispatcher.register("event");
        this.dispatcher.attach("event", function(arg:Int):Void {
            value = arg;
        });
        this.dispatcher.trigger("event", input);
        assertEquals(input, value);
    }

    /**
     * Checks that the trigger() method returns a "OK" status when triggering
     * an existing Event.
     *
     * Attn: This tests depends on the register() method - make sure if works before
     * looking for errors in trigger() method.
     */
    public function testTriggerExistingEvent():Void
    {
        this.dispatcher.register("event");
        assertEquals(this.dispatcher.trigger("event", 0).status, Dispatcher.Status.OK);
    }

    /**
     * Checks that the trigger() method returns a "NO_SUCH_EVENT" status when triggering
     * a non-existing Event.
     */
    public function testTriggerNonExistingEvent():Void
    {
        assertEquals(this.dispatcher.trigger("event", 0).status, Dispatcher.Status.NO_SUCH_EVENT);
    }

    /**
     * Checks the unregister() method really removes the Event to the Dispatcher.
     *
     * Attn: This test depends on register() and hasEvent() methods - make sure they work before
     * looking for errors in unregister() method.
     */
    public function testUnregister():Void
    {
        this.dispatcher.register("event");
        assertTrue(this.dispatcher.unregister("event"));
        assertFalse(this.dispatcher.hasEvent("event"));
    }

    /**
     * Checks the unregister() method returns false when removing the same Event twice.
     *
     * Attn: This test depends on register() method - make sure it works before
     * looking for errors in unregister() method.
     */
    public function testUnregisterTwice():Void
    {
        this.dispatcher.register("event");
        this.dispatcher.unregister("event");
        assertFalse(this.dispatcher.unregister("event"));
    }
}
