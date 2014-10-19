package hext.flow.async;

import hext.flow.Cascade.Tier;
#if !js
    import hext.flow.async.Future;
#end
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
     * @param T arg the argument to pass to the first Tier
     *
     * @return hext.flow.async.Future<T> a Future that will get resolved by the last Tier
     */
    public function plunge(arg:T):#if js Void #else Future<T> #end
    {
        #if !js var future:Future<T> = new Future<T>(); #end
        var tiers:Array<Tier<T>>     = Lambda.array(this.tiers); // make sure we iterate over a copy
        this.executor.execute(function(arg:T):Void {
            var tier:Tier<T>;
            for (tier in tiers) {
                arg = tier(arg);
            }
            #if !js future.resolve(arg); #end
        }.bind(arg));

        #if !js return future; #end
    }
}
