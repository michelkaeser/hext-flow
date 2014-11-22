package hext.flow.concurrent;

import hext.Callback;
import hext.flow.State;
import hext.flow.WorkflowException;
#if !js
    import hext.threading.ISynchronizer;
    import hext.threading.Synchronizer;
#end

/**
 * Thread-safe Promise implementation.
 *
 * This version can be rejected/resolved by other threads and been awaited by them
 * as well (even by multiple threads).
 *
 * @{inherit}
 */
class Promise<T> extends hext.flow.Promise<T>
{
    /**
     * Stores the Mutex used to synchronize access to properties.
     *
     * @var hext.threading.ISynchronizer
     */
    #if !js private var synchronizer:ISynchronizer; #end


    /**
     * @{inherit}
     */
    public function new(resolves:Int = 1):Void
    {
        super(resolves);
        #if !js this.synchronizer = new Synchronizer(); #end
    }

    /**
     * @{inherit}
     */
    override public function done(callback:Callback<T>):Void
    {
        this.synchronizer.sync(function(parent):Void {
            parent.done(callback);
        }.bind(super));
    }

    /**
     * @{inherit}
     */
    override public function isDone():Bool
    {
        var ret:Bool;
        this.synchronizer.sync(function(parent):Void {
            ret = parent.isDone();
        }.bind(super));

        return ret;
    }

    /**
     * @{inherit}
     */
    override public function isRejected():Bool
    {
        var ret:Bool;
        this.synchronizer.sync(function(parent):Void {
            ret = parent.isRejected();
        }.bind(super));

        return ret;
    }

    /**
     * @{inherit}
     */
    override public function isResolved():Bool
    {
        var ret:Bool;
        this.synchronizer.sync(function(parent):Void {
            ret = parent.isResolved();
        }.bind(super));

        return ret;
    }

    /**
     * @{inherit}
     */
    override public function reject(arg:T):Void
    {
        this.synchronizer.sync(function():Void {
            if (this.state == State.NONE) {
                this.state = State.REJECTED;
                this.executeCallbacks(Lambda.array(this.callbacks.rejected).concat(Lambda.array(this.callbacks.done)), arg); // make sure we iterate over copy
            } else {
                throw new WorkflowException("Promise has already been rejected or resolved.");
            }
        });
        this.callbacks.done     = null;
        this.callbacks.rejected = null;
        this.callbacks.resolved = null;
    }

    /**
     * @{inherit}
     */
    override public function rejected(callback:Callback<T>):Void
    {
        this.synchronizer.sync(function(parent):Void {
            parent.rejected(callback);
        }.bind(super));
    }

    /**
     * @{inherit}
     */
    override public function resolve(arg:T):Void
    {
        this.synchronizer.sync(function():Void {
            if (this.state == State.NONE) {
                if (--this.resolves == 0) {
                    this.state = State.RESOLVED;
                    this.executeCallbacks(Lambda.array(this.callbacks.resolved).concat(Lambda.array(this.callbacks.done)), arg); // make sure we iterate over copy
                }
            } else {
                throw new WorkflowException("Promise has already been rejected or resolved.");
            }
        });
        this.callbacks.done     = null;
        this.callbacks.rejected = null;
        this.callbacks.resolved = null;
    }

    /**
     * @{inherit}
     */
    override public function resolved(callback:Callback<T>):Void
    {
        this.synchronizer.sync(function(parent):Void {
            parent.resolved(callback);
        }.bind(super));
    }

    /**
     * @{inherit}
     */
    public static function when<T>(promises:Iterable<Promise<T>>):Promise<T>
    {
        var promise:Promise<T> = new Promise<T>(1);
        for (p in promises) {
            p.synchronizer.sync(function():Void {
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
            });
        }

        if (--promise.resolves == 0) {
            throw new WorkflowException("Promises have already been rejected or resolved.");
        }

        return promise;
    }
}
