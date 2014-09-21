package flow.tests.concurrent;

import flow.concurrent.Future;

/**
 * TestSuite for the flow.concurrent.Future class.
 */
class TestFuture extends flow.tests.TestFuture
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.future = new Future<Int>();
    }
}
