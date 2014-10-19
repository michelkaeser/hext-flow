package hext.flow.tests.concurrent;

import hext.flow.concurrent.Dispatcher;

/**
 * TestSuite for the hext.flow.concurrent.Dispatcher class.
 */
class TestDispatcher extends hext.flow.tests.TestDispatcher
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.dispatcher = new Dispatcher<Int>();
    }
}
