package flow;

import lib.ds.IList;
import lib.ds.LinkedList;

/**
 * The Cascade (waterfall) class can be used to execute functions
 * (so called Tiers) in order, passing the return value of each Tier
 * to the next one.
 *
 * @generic T the type of argument/return values the Tiers will pass
 */
class Cascade<T>
{
    /**
     * Stores the Tiers.
     *
     * @var lib.ds.IList<flow.Cascade.Tier<T>>
     */
    private var tiers:IList<Tier<T>>;


    /**
     * Constructor to initialize a new Cascade.
     */
    public function new():Void
    {
        this.tiers = new LinkedList<Tier<T>>();
    }

    /**
     * Adds the Tier to the end of the Cascade.
     *
     * @param flow.Cascade.Tier<T> callback the Tier to add
     *
     * @return flow.Cascade<T> this
     */
    public function add(callback:Tier<T>):Cascade<T>
    {
        this.tiers.add(callback);
        return this;
    }

    /**
     * Descends all the Tiers and returns the final return value.
     *
     * @param T arg the argument to pass to the first Tier
     *
     * @return T the return value of the last Tier
     */
    public function descend(arg:T):T
    {
        var tier:Tier<T>;
        for (tier in Lambda.array(this.tiers)) { // make sure we iterate over a copy
            arg = tier(arg);
        }

        return arg;
    }

    #if !lua
        /**
         * @see flow.Cascade.add
         */
        @:deprecated('"then" is not an allowed function name in Lua. Use add() instead.')
        public function then(callback:Tier<T>):Cascade<T>
        {
            this.tiers.add(callback);
            return this;
        }
    #end
}


/**
 * Each step of a Cascade is represented by a Tier.
 * That Tier gets the return value from the previous Tier
 * and must return a value, so following Tiers get an input
 * argument as well.
 */
typedef Tier<T> = T->T;
