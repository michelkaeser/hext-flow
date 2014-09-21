package flow.tests.concurrent;

import flow.concurrent.Promise;

/**
 * TestSuite for the flow.concurrent.Promise class.
 */
class TestPromise extends flow.tests.TestPromise
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
    override private function getPromise(resolves:Int = 1):flow.concurrent.Promise<Dynamic>
    {
        return new Promise<Dynamic>(resolves);
    }
}
