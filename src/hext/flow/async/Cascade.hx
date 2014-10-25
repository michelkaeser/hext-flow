package hext.flow.async;

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
        var future:Future<T>     = new Future<T>();
        var tiers:Array<Tier<T>> = Lambda.array(this.tiers); // make sure we iterate over a copy

        var arg:Future<T> = new Future<T>();
        arg.resolve(init);
        var i:Int    = 0;
        var last:Int = tiers.length - 1;
        while (i <= last) {
            var next:Future<T>;
            if (i == last) {
                next = future;
            } else {
                next = new Future<T>();
            }
            this.executor.execute(function(tier:Tier<T>, arg:Future<T>, next:Future<T>):Void {
                var ret:T = tier(arg.get(true));
                next.resolve(ret);
            }.bind(tiers[i], arg, next));
            arg = next;
            ++i;
        }

        return future;
    }
}
