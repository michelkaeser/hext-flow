package flow.async;

import flow.Dispatcher.Status;
#if flash
    import flow.concurrent.Promise;
#else
    import flow.async.Promise;
#end
import lib.Callback;
import lib.Nil;
import lib.threading.ExecutionContext;
import lib.threading.IExecutor;

/**
 * This Dispatcher implementation is a thread-safe, asynchronous implementation.
 *
 * Each Callback is executed by the asynchronous Executor.
 *
 * @{inherit}
 */
class Dispatcher<T> extends flow.concurrent.Dispatcher<T>
{
    /**
     * Stores the Executor used to process Callbacks.
     *
     * @var lib.threading.IExecutor
     */
    private var executor:IExecutor;


    /**
     * Constructor to initialize a new asynchronous Dispatcher.
     *
     * @param lib.threading.IExecutor the Callback Executor to use
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
            var callbacks = Lambda.array(this.map.get(event)); // make sure the list doesnt change anymore
            #if !js this.mutex.release(); #end
            var promise:Promise<Nil> = new Promise<Nil>(ExecutionContext.preferedExecutor, callbacks.length);

            var callback:Callback<T>;
            for (callback in callbacks) {
                this.executor.execute(function(arg:T):Void {
                    #if FLOW_DEBUG
                        try {
                            callback(arg);
                        } catch (ex:Dynamic) {
                            promise.resolve(null);
                            throw ex;
                        }
                    #else
                        try {
                            callback(arg);
                        } catch (ex:Dynamic) {}
                    #end
                    promise.resolve(null);
                }, arg);
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
{> flow.Dispatcher.Feedback,
    @:optional public var promise:Promise<Nil>;
};
