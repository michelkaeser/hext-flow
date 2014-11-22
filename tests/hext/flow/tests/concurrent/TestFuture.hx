package hext.flow.tests.concurrent;

import hext.flow.concurrent.Future;

/**
 * TestSuite for the hext.flow.concurrent.Future class.
 */
class TestFuture extends hext.flow.tests.TestFuture
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.future = new Future<Int>();
    }
}
