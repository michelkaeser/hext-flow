package flow.async;

import lib.Callback;
import lib.threading.ExecutionContext;
import lib.threading.IExecutor;
#if !js
    import lib.vm.MultiLock;
#end

/**
 * TODO
 */
class Promise<T> extends flow.concurrent.Promise<T>
{
    /**
     * Stores either the Callbacks are being executed or not.
     *
     * @var Bool
     */
    private var executing:Bool;

    /**
     * Stores the Executor used to process Callbacks.
     *
     * @var lib.threading.IExecutor
     */
    private var executor:IExecutor;

    #if !js
        /**
         * Stores the Lock used to block await() callers.
         *
         * @var lib.vm.MultiLock
         */
        private var lock:MultiLock;

        /**
         * Stores the temporary number of required tryUnlocks from Callbacks.
         *
         * @var Int
         */
        private var unlocks:Int;
    #end


    /**
     * @param lib.threading.IExecutor the Callback Executor to use
     *
     * @{inherit}
     */
    public function new(executor:IExecutor, resolves:Int = 1):Void
    {
        super(resolves);

        this.executing     = false;
        this.executor      = executor;
        #if !js
            this.lock      = new MultiLock();
            this.unlocks   = 0;
        #end
    }

    /**
     * Blocks the calling Thread until the Promise has been marked as done
     * and Callbacks have been processed.
     */
    #if !js
        public function await():Void
        {
            this.mutex.acquire();
            if (!this.isDone() || this.isExecuting()) {
                this.mutex.release();
                #if java
                    this.lock.wait();
                #else
                    while (!this.lock.wait(0.01) && (!this.isDone() || this.isExecuting())) {}
                #end
            } else {
                this.mutex.release();
            }
        }
    #end

    /**
     * Checks if the Promise is still executing its Callbacks.
     *
     * @return Bool
     */
    public function isExecuting():Bool
    {
        #if !js this.mutex.acquire(); #end
        var ret:Bool = this.executing;
        #if !js this.mutex.release(); #end

        return ret;
    }

    /**
     * @{inherit}
     */
    override private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        if (Lambda.empty(callbacks)) {
            #if !js this.unlock(); #end
        } else {
            #if !js this.mutex.acquire(); #end
            this.executing = true;
            #if !js
                this.unlocks = (untyped callbacks).length;
                this.mutex.release();
            #end

            var callback:Callback<T>;
            for (callback in callbacks) { // make sure we iterate over a copy
                this.executor.execute(function(fn:Callback<T>, arg:T):Void {
                    try {
                        fn(arg);
                    } catch (ex:Dynamic) {}
                    #if !js this.tryUnlock(); #end
                }.bind(callback, arg));
            }
        }
    }

    #if !js
        /**
         * Tries to unlock the waiting Threads by checking if all Callbacks have been executed.
         */
        private function tryUnlock():Void
        {
            this.mutex.acquire();
            if (--this.unlocks == 0) {
                this.executing = false;
                this.unlock();
            }
            this.mutex.release();
        }

        /**
         * Unlocks the Lock that is used to block waiters in await() method.
         */
        private function unlock():Void
        {
            this.mutex.acquire();
            this.lock.release();
            this.mutex.release();
        }
    #end

    /**
     * @{inherit}
     */
    public static function when<T>(promises:Iterable<Promise<T>>, ?executor:IExecutor):Promise<T>
    {
        if (executor == null) {
            executor = ExecutionContext.preferedExecutor;
        }

        var promise:Promise<T> = new Promise<T>(executor, 1);
        for (p in promises) {
            #if !js p.mutex.acquire(); #end
            if (!p.isDone() || p.isExecuting()) {
                ++promise.resolves;
                p.done(function(arg:T):Void {
                    if (p.isRejected()) {
                        promise.reject(arg);
                    } else {
                        promise.resolve(arg);
                    }
                });
            }
            #if !js p.mutex.release(); #end
        }

        if (--promise.resolves == 0) {
            throw new WorkflowException("Promises have already been rejected or resolved.");
        }

        return promise;
    }
}
