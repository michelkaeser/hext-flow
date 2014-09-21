package flow;

import flow.State;
import flow.WorkflowException;
import std.Callback;
import std.Exception;
import std.ds.IList;
import std.ds.LinkedList;

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
     * @var { done:std.ds.IList<std.Callback<T>>, rejected:std.ds.IList<std.Callback<T>>, resolved:std.ds.IList<std.Callback<T>> }
     */
    private var callbacks:{
        done:IList<Callback<T>>,
        rejected:IList<Callback<T>>,
        resolved:IList<Callback<T>>
    };

    /**
     * Stores the state.
     *
     * @var flow.State
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
            done:     new LinkedList<Callback<T>>(),
            rejected: new LinkedList<Callback<T>>(),
            resolved: new LinkedList<Callback<T>>()
        };
        this.resolves  = resolves;
        this.state     = State.NONE;
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has been marked as done.
     *
     * @param std.Callback<T> callback the callback to register
     *
     * @throws flow.WorkflowException if the Promise has already been marked as done
     */
    public function done(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved");
        }

        this.callbacks.done.add(callback);
    }

    /**
     * Executes the registered callbacks with the provided argument.
     *
     * @param Iterable<std.Callback<T>> callbacks the callbacks to execute
     * @param T                         arg       the argument to pass to the callbacks
     */
    private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        var callback:Callback<T>;
        for (callback in callbacks) { // make sure we iterate over a copy
            #if FLOW_DEBUG
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
     * @throws flow.WorkflowException if the Promise has already been marked as done
     */
    public function reject(arg:T):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved");
        }

        this.state = State.REJECTED;
        this.executeCallbacks(Lambda.array(this.callbacks.rejected).concat(Lambda.array(this.callbacks.done)), arg); // make sure we iterate over copy

        this.callbacks.done     = null;
        this.callbacks.rejected = null;
        this.callbacks.resolved = null;
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has rejected.
     *
     * @param std.Callback<T> callback the callback to register
     *
     * @throws flow.WorkflowException if the Promise has already been marked as done
     */
    public function rejected(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved");
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
     * @throws flow.WorkflowException if the Promise has already been marked as done
     */
    public function resolve(arg:T):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved");
        }

        if (--this.resolves == 0) {
            this.state = State.RESOLVED;
            this.executeCallbacks(Lambda.array(this.callbacks.resolved).concat(Lambda.array(this.callbacks.done)), arg); // make sure we iterate over copy

            this.callbacks.done     = null;
            this.callbacks.rejected = null;
            this.callbacks.resolved = null;
        }
    }

    /**
     * Method allowing to register callbacks to be executed when the Promise
     * has resolved.
     *
     * @param std.Callback<T> callback the callback to register
     *
     * @throws flow.WorkflowException if the Promise has already been marked as done
     */
    public function resolved(callback:Callback<T>):Void
    {
        if (this.isDone()) {
            throw new WorkflowException("Promise has already been rejected or resolved");
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
     * @return flow.Promise<T> a new Promise summarizing the other ones
     *
     * @throws flow.WorkflowException if all Promises have already been marked as done
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
            throw new WorkflowException("Promises have already been rejected or resolved");
        }

        return promise;
    }
}
