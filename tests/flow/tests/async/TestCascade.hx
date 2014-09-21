package flow.tests.async;

import flow.async.Cascade;

/**
 * TestSuite for the flow.async.Cascade class.
 *
 * TODO: mock ThreadExecutor
 */
class TestCascade extends flow.tests.concurrent.TestCascade
{
    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.cascade = new Cascade<Int>(new lib.threading.ThreadExecutor());
    }


    /**
     * Checks that the plunge() method returns the input argument when no Tiers
     * have been added yet. Also makes sure, it returns a Future.
     */
    public function testPlunge():Void
    {
        var input:Int = 5;
        var f = untyped this.cascade.plunge(input);
        Sys.sleep(0.2); // await async Future
        assertEquals(input, f.get(true));
    }

    /**
     * Checks if the plunge() method iterates over a copy of the added Tiers.
     *
     * It could be that Tiers add other Tiers to the Cascade, which could bring
     * problem with it. Therefor the plunge() method should iterate over a copy
     * of all "til-then" added Tiers.
     *
     * Attn: This test depends on the add() method - make sure all tests for that
     * method work before looking for errors in plunge() when this test fails.
     */
    public function testPlungeIteratesOverCopy():Void
    {
        this.cascade.add(function(arg:Int):Int {
            this.cascade.add(function(arg:Int):Int {
                return arg * 2;
            });
            return arg;
        });

        var f = untyped this.cascade.plunge(2);
        Sys.sleep(0.2); // await async Future
        assertEquals(f.get(true), 2);

        f = untyped this.cascade.plunge(2);
        Sys.sleep(0.2); // await async Future
        assertEquals(f.get(true), 4);
    }
}
