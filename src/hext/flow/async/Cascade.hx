package hext.flow.async;

import hext.IterableTools;
import hext.flow.Cascade.Tier;
import hext.flow.async.Future;
import hext.threading.IExecutor;

/**
 * This Cascade implementation is a thread-safe, asynchronous implementation.
 *
 * Each Tier is executed by the asynchronous Executor.
 *
 * @{inherit}
 */
class Cascade<T> extends hext.flow.concurrent.Cascade<T>
{
    /**
     * Stores the Executor used to process the Tiers.
     *
     * @var hext.threading.IExecutor
     */
    private var executor:IExecutor;


    /**
     * Constructor to initialize a new asynchronous Cascade.
     *
     * @param hext.threading.IExecutor the Tier Executor to use
     */
    public function new(executor:IExecutor):Void
    {
        super();
        this.executor = executor;
    }

    /**
     * Asynchronous descends all the Tiers.
     *
     * @param T init the argument to pass to the first Tier
     *
     * @return hext.flow.async.Future<T> a Future that will get resolved by the last Tier
     */
    public function plunge(init:T):Future<T>
    {
        var future:Future<T>    = new Future<T>();
        var tiers:List<Tier<T>> = IterableTools.toList(this.tiers);
        this.executor.execute(function(arg:T):Void {
            for (tier in tiers) {
                arg = tier(arg);
            }
            future.resolve(arg);
        }.bind(init));

        return future;
    }
}
