package flow.tests;

import flow.Future;

/**
 * TestSuite for the flow.Future class.
 */
class TestFuture extends haxe.unit.TestCase
{
    /**
     * Stores the Future on which the tests are run.
     *
     * @var flow.Future<Int>
     */
    private var future:Future<Int>;


    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.future = new Future<Int>();
    }

    /**
     *@{inherit}
     */
    override public function tearDown():Void
    {
        this.future = null;
    }


    /**
     * Checks if the get() method returns the correct value.
     *
     * This test also ensures, that the get() method accepts a Bool argument.
     */
    public function testGet():Void
    {
        var value:Int = 5;
        this.future.resolve(5);
        assertEquals(value, this.future.get(false));
    }

    /**
     * Checks that the get() method throws an Exception when no value has been set yet.
     */
    public function testGetThrowsWorkflowException():Void
    {
        try {
            this.future.get(false);
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the isReady() method works correctly.
     */
    public function testIsReady():Void
    {
        assertFalse(this.future.isReady());

        this.future.resolve(5);
        assertTrue(this.future.isReady());
    }

    /**
     * Checks if the isRejected() method works correctly.
     */
    public function testIsRejected():Void
    {
        assertFalse(this.future.isRejected());

        this.future.reject();
        assertTrue(this.future.isRejected());
    }

    /**
     * Checks if the isRejected() method works correctly when the Future has been resolved.
     */
    public function testIsRejectedWhenResolved():Void
    {
        this.future.resolve(5);
        assertFalse(this.future.isRejected());
    }

    /**
     * Checks if the isResolved() method works correctly.
     */
    public function testIsResolved():Void
    {
        assertFalse(this.future.isResolved());

        this.future.resolve(5);
        assertTrue(this.future.isResolved());
    }

    /**
     * Checks if the isResolved() method works correctly when the Future has been rejected.
     */
    public function testIsResolvedWhenRejected():Void
    {
        this.future.reject();
        assertFalse(this.future.isResolved());
    }

    /**
     * Checks if the reject() method throws an Exception when one tries to reject the
     * Future twice.
     */
    public function testRejectThrowsWorkflowException():Void
    {
        this.future.reject();
        try {
            this.future.reject();
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the resolve() method throws an Exception when one tries to resolve the
     * Future twice.
     */
    public function testResolveThrowsWorkflowException():Void
    {
        this.future.resolve(5);
        try {
            this.future.resolve(5);
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }
}
