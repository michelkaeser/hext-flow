package hxdispatch.tests.async;

import hxdispatch.async.Future;
import hxstd.vm.Thread;

/**
 * TestSuite for the hxdispatch.async.Future class.
 */
class TestFuture extends hxdispatch.tests.concurrent.TestFuture
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.future = new Future<Int>();
    }


    /**
     * Ensures that the get(true) call blocks the calling Thread.
     */
    public function testGetBlocksThread():Void
    {
        var input:Int = 4;
        Thread.create(function():Void {
            assertEquals(input, this.future.get(true));
        });
        this.future.resolve(input);
        Sys.sleep(0.1); // wait for Thread
    }

    /**
     * Ensures that the get() method throws a hxdispatch.WorkflowExceiton when being called
     * with argument 'false' and the value is not yet available.
     */
    public function testGetFalseThrowsWorkFlowException():Void
    {
        try {
            this.future.get(false);
            assertFalse(true);
        } catch (ex:hxdispatch.WorkflowException) {
            assertTrue(true);
        }
    }
}
