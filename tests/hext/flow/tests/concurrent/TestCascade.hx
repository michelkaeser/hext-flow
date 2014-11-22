package hext.flow.tests.concurrent;

import hext.flow.concurrent.Cascade;

/**
 * TestSuite for the hext.flow.concurrent.Cascade class.
 */
class TestCascade extends hext.flow.tests.TestCascade
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.cascade = new Cascade<Int>();
    }
}
