package hext.flow.async;

import hext.flow.Dispatcher.Status;
#if flash
    import hext.flow.concurrent.Promise;
#else
    import hext.flow.async.Promise;
#end
import hext.Callback;
import hext.IterableTools;
import hext.Nil;
import hext.threading.ExecutionContext;
import hext.threading.IExecutor;

/**
 * This Dispatcher implementation is a thread-safe, asynchronous implementation.
 *
 * Each Callback is executed by the asynchronous Executor.
 *
 * @{inherit}
 */
class Dispatcher<T> extends hext.flow.concurrent.Dispatcher<T>
{
    /**§
     * Stores the Executor used to process Callbacks.
     *
     * @var hext.threading.IExecutor
     */
    private var executor:IExecutor;


    /**
     * Constructor to initialize a new asynchronous Dispatcher.
     *
     * @param hext.threading.IExecutor the Callback Executor to use
     */
    public function new(executor:IExecutor):Void
    {
        super();
        this.executor = executor;
    }

    /**
     * @{inherit}
     */
    override public function trigger(event:Event, arg:T):Feedback
    {
        #if !js this.mutex.acquire(); #end
        if (this.hasEvent(event)) {
            var callbacks:List<Callback<T>> = IterableTools.toList(this.map.get(event)); // make sure the list doesnt change anymore
            #if !js this.mutex.release(); #end
            var promise:Promise<Nil> = new Promise<Nil>(ExecutionContext.preferedExecutor, callbacks.length);
            for (callback in callbacks) { // callback = Callback<T>
                this.executor.execute(function(fn:Callback<T>, arg:T):Void {
                    try {
                        fn(arg);
                    } catch (ex:Dynamic) {}
                    promise.resolve(null);
                }.bind(callback, arg));
            }

            return { status: Status.TRIGGERED, promise: promise };
        } else {
            #if !js this.mutex.release(); #end
        }

        return { status: Status.NO_SUCH_EVENT };
    }
}


/**
 * @{inherit}
 */
typedef Feedback =
{> hext.flow.Dispatcher.Feedback,
    @:optional public var promise:Promise<Nil>;
};
