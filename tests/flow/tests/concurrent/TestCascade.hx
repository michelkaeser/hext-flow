package flow.tests.concurrent;

import flow.concurrent.Cascade;

/**
 * TestSuite for the flow.concurrent.Cascade class.
 */
class TestCascade extends flow.tests.TestCascade
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.cascade = new Cascade<Int>();
    }
}
