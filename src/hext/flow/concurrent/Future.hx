package hext.flow.concurrent;

import hext.flow.State;
import hext.flow.WorkflowException;
import hext.threading.ISynchronizer;
import hext.threading.Synchronizer;

/**
 * Thread-safe Future implementation.
 *
 * This version can be rejected/resolved by other threads and been awaited by them
 * as well (even by multiple threads).
 *
 * @{inherit}
 */
class Future<T> extends hext.flow.Future<T>
{
    /**
     * Stores the Mutex used to synchronize access to properties.
     *
     * @var hext.threading.ISynchronizer
     */
    private var synchronizer:ISynchronizer;


    /**
     * @{inherit}
     */
    public function new():Void
    {
        super();
        this.synchronizer = new Synchronizer();
    }

    /**
     * @{inherit}
     */
    override public function get(block:Bool = true):T
    {
        var value:T;
        this.synchronizer.sync(function(parent):Void {
            value = parent.get(block);
        }.bind(super));

        return value;
    }

    /**
     * @{inherit}
     */
    override public function isReady():Bool
    {
        var ret:Bool;
        this.synchronizer.sync(function(parent):Void {
            ret = parent.isReady();
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
    override public function reject():Void
    {
        this.synchronizer.sync(function(parent):Void {
            parent.reject();
        }.bind(super));
    }

    /**
     * @{inherit}
     */
    override public function resolve(value:T):Void
    {
        this.synchronizer.sync(function(parent):Void {
            parent.resolve(value);
        }.bind(super));
    }
}
