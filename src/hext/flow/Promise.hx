package hext.flow;

import hext.Callback;
import hext.Exception;
import hext.flow.State;
import hext.flow.WorkflowException;

using hext.ListTools;

/**
 * A Promise can be used to execute registered callbacks as soon as
 * the Promise has been rejected or resolved.
 *
 * This version is not thread safe and therefor not of much use, as it will execute
 * the callbacks in sync (when the last resolve/reject has been called).
 *
 * @generic T the type of the arguments being passed to the callbacks
 */
class Promise<T>
{
    /**
     * Stores the number of required resolves before the Promise gets marked as done.
     *
     * @var Int
     */
    private var resolves:Int;

    /**
     * Stores the callbacks to be executed for the various state events.
     *
     * @var { done:List<hext.Callback<T>>, rejected:List<hext.Callback<T>>, resolved:List<hext.Callback<T>> }
     */
    private var callbacks:{
        done:List<Callback<T>>,
        rejected:List<Callback<T>>,
        resolved:List<Callback<T>>
    };

    /**
     * Stores the state.
     *
     * @var hext.flow.State
     */
    private var state:State;


    /**
     * Constructor to initialize a new Promise.
     *
     * @param Int resolves the number of required resolves before the Promise gets marked as done
     */
    public function new(resolves:Int = 1):Void
    {
        this.callbacks = {
            done:     new List<Callback<T>>(),
            rejected: new List<Callback<T>>(),
            resolved: new List<Callback<T>>()
        };
        this.resolves  = resolves;
        this.state     = State.NONE;
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has been marked as done.
     *
     * @param hext.Callback<T> callback the callback to register
     *
     * @throws hext.flow.WorkflowException if the Promise has already been marked as done
     */
    public function done(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved.");
        }

        this.callbacks.done.add(callback);
    }

    /**
     * Executes the registered callbacks with the provided argument.
     *
     * @param Iterable<hext.Callback<T>> callbacks the callbacks to execute
     * @param T                          arg       the argument to pass to the callbacks
     */
    private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        for (callback in callbacks) { // callback = Callback<T>
            #if HEXT_DEBUG
                callback(arg);
            #else
                try {
                    callback(arg);
                } catch (ex:Dynamic) {}
            #end
        }
    }

    /**
     * Checks if the Promise has been marked as done.
     *
     * @return Bool
     */
    public function isDone():Bool
    {
        return this.state != State.NONE;
    }

    /**
     * Checks if the Promise has been rejected.
     *
     * @return Bool
     */
    public function isRejected():Bool
    {
        return this.state == State.REJECTED;
    }

    /**
     * Checks if the Promise has been resolved.
     *
     * @return Bool
     */
    public function isResolved():Bool
    {
        return this.state == State.RESOLVED;
    }

    /**
     * Rejects the Promise.
     *
     * A rejected Promise is marked as done immediately.
     *
     * @throws hext.flow.WorkflowException if the Promise has already been marked as done
     */
    public function reject(arg:T):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved.");
        }

        this.state = State.REJECTED;
        var callbacks:List<Callback<T>> = IterableTools.toList(this.callbacks.rejected);
        callbacks.addAll(this.callbacks.done);
        this.executeCallbacks(callbacks, arg);
        this.callbacks.done     = null;
        this.callbacks.rejected = null;
        this.callbacks.resolved = null;
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has rejected.
     *
     * @param hext.Callback<T> callback the callback to register
     *
     * @throws hext.flow.WorkflowException if the Promise has already been marked as done
     */
    public function rejected(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved.");
        }

        this.callbacks.rejected.add(callback);
    }

    /**
     * Resolves the Promise with the provided argument.
     *
     * The argument is passed to the registered callbacks when this is the last
     * required resolve() call, ignored otherwise.
     *
     * @param T arg the argument to pass to the callbacks
     *
     * @throws hext.flow.WorkflowException if the Promise has already been marked as done
     */
    public function resolve(arg:T):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved.");
        }

        if (--this.resolves == 0) {
            this.state = State.RESOLVED;
            var callbacks:List<Callback<T>> = IterableTools.toList(this.callbacks.resolved);
            callbacks.addAll(this.callbacks.done);
            this.executeCallbacks(callbacks, arg);
            this.callbacks.done     = null;
            this.callbacks.rejected = null;
            this.callbacks.resolved = null;
        }
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has resolved.
     *
     * @param hext.Callback<T> callback the callback to register
     *
     * @throws hext.flow.WorkflowException if the Promise has already been marked as done
     */
    public function resolved(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved.");
        }

        this.callbacks.resolved.add(callback);
    }

    /**
     * Returns a new Promise that will get marked as done when all passed
     * Promises have been marked as done.
     *
     * @see https://github.com/jdonaldson/promhx where I have stolen the idea
     *
     * @param Iterable<flow.Promise<T>> promises the Promises to wait for
     *
     * @return hext.flow.Promise<T> a new Promise summarizing the other ones
     *
     * @throws hext.flow.WorkflowException if all Promises have already been marked as done
     */
    public static function when<T>(promises:Iterable<Promise<T>>):Promise<T>
    {
        var promise:Promise<T> = new Promise<T>(1);
        for (p in promises) {
            if (!p.isDone()) {
                ++promise.resolves;
                p.done(function(arg:T):Void {
                    if (p.isRejected()) {
                        promise.reject(arg);
                    } else {
                        promise.resolve(arg);
                    }
                });
            }
        }

        if (--promise.resolves == 0) {
            throw new WorkflowException("Promises have already been rejected or resolved.");
        }

        return promise;
    }
}
