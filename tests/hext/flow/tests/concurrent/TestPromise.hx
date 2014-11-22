package hext.flow.tests.concurrent;

import hext.flow.concurrent.Promise;

/**
 * TestSuite for the hext.flow.concurrent.Promise class.
 */
class TestPromise extends hext.flow.tests.TestPromise
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.promise = new Promise<Int>();
    }

    /**
     * @{inherit}
     */
    override private function getPromise(resolves:Int = 1):hext.flow.concurrent.Promise<Dynamic>
    {
        return new Promise<Dynamic>(resolves);
    }
}
