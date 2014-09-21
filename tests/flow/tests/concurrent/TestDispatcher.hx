package flow.tests.concurrent;

import flow.concurrent.Dispatcher;

/**
 * TestSuite for the flow.concurrent.Dispatcher class.
 */
class TestDispatcher extends flow.tests.TestDispatcher
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.dispatcher = new Dispatcher<Int>();
    }
}
