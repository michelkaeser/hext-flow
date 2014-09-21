package flow.tests;

import flow.Cascade;

/**
 * TestSuite for the flow.Cascade class.
 */
class TestCascade extends haxe.unit.TestCase
{
    /**
     * Stores the Cascade on which the tests are run.
     *
     * @var flow.Cascade<Int>
     */
    private var cascade:Cascade<Int>;


    /**
     * @{inherit}
     */
    override public function setup():Void
    {
        this.cascade = new Cascade<Int>();
    }

    /**
     *@{inherit}
     */
    override public function tearDown():Void
    {
        this.cascade = null;
    }


    /**
     * Checks if the descend() method works correctly.
     *
     * Since meaningful Cascade tests rely on various methods, we simple check here that
     * if no Tier has been added yet, the input argument is returned.
     */
    public function testDescend():Void
    {
        var input:Int = 5;
        assertEquals(input, this.cascade.descend(input));
    }

    /**
     * Checks that the descend() method does NOT catch exceptions thrown in Tiers.
     *
     * If an exception is thrown, we cannot assume the following Tiers still work correctly.
     *
     * Attn: This test depends on the add() method - make sure all tests for that
     * method work before looking for errors in descend() when this test fails.
     */
    public function testDescendDoesNotCatchExceptions():Void
    {
        this.cascade.add(function(arg:Int):Int {
            throw "Exception in Tier";
            return arg;
        });
        this.cascade.add(function(arg:Int):Int {
            return arg;
        });

        try {
            this.cascade.descend(5);
            assertFalse(true);
        } catch (ex:String) {
            assertTrue(true);
        }
    }

    /**
     * Checks if the descend() iterates over a copy of the added Tiers.
     *
     * It could be that Tiers add other Tiers to the Cascade, which could bring
     * problem with it. Therefor the descend() method should iterate over a copy
     * of all "til-then" added Tiers.
     *
     * Attn: This test depends on the add() method - make sure all tests for that
     * method work before looking for errors in descend() when this test fails.
     */
    public function testDescendIteratesOverCopy():Void
    {
        this.cascade.add(function(arg:Int):Int {
            this.cascade.add(function(arg:Int):Int {
                return arg * 2;
            });
            return arg;
        });
        assertEquals(this.cascade.descend(2), 2);
        assertEquals(this.cascade.descend(2), 4);
    }

    /**
     * Checks if the add() method works correctly.
     *
     * Attn: This test depends on the descend() method - make sure all tests for that
     * method work before looking for errors in add() when this test fails.
     */
    public function testThen():Void
    {
        this.cascade.add(function(arg:Int):Int {
            return arg * 2;
        });
        assertEquals(this.cascade.descend(2), 4);
    }

    /**
     * Checks if add() adds the Tiers in the correct order.
     *
     * Attn: This test depends on the descend() method - make sure all tests for that
     * method work before looking for errors in add() when this test fails.
     */
    public function testThenOrder():Void
    {
        this.cascade.add(function(arg:Int):Int {
            return arg * 2;
        });
        this.cascade.add(function(arg:Int):Int {
            return arg + 2;
        });
        assertEquals(this.cascade.descend(2), 6);
    }
}
