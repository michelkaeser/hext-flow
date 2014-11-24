package hext.flow.concurrent;

import hext.flow.State;
import hext.flow.WorkflowException;
import hext.vm.Mutex;

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
     * @var hext.vm.Mutex
     */
    private var mutex:Mutex;


    /**
     * @{inherit}
     */
    public function new():Void
    {
        super();
        this.mutex = new Mutex();
    }

    /**
     * @{inherit}
     */
    override public function get(block:Bool = true):T
    {
        var value:T;
        this.mutex.acquire();
        try {
            value = super.get(block);
        } catch (ex:Dynamic) {
            this.mutex.release();
            throw ex;
        }
        this.mutex.release();

        return value;
    }

    /**
     * @{inherit}
     */
    override public function isReady():Bool
    {
        var ready:Bool;
        this.mutex.acquire();
        ready = super.isReady();
        this.mutex.release();

        return ready;
    }

    /**
     * @{inherit}
     */
    override public function isRejected():Bool
    {
        var rejected:Bool;
        this.mutex.acquire();
        rejected = super.isRejected();
        this.mutex.release();

        return rejected;
    }

    /**
     * @{inherit}
     */
    override public function isResolved():Bool
    {
        var resolved:Bool;
        this.mutex.acquire();
        resolved = super.isResolved();
        this.mutex.release();

        return resolved;
    }

    /**
     * @{inherit}
     */
    override public function reject():Void
    {
        this.mutex.acquire();
        try {
            super.reject();
        } catch (ex:Dynamic) {
            this.mutex.release();
            throw ex;
        }
        this.mutex.release();
    }

    /**
     * @{inherit}
     */
    override public function resolve(value:T):Void
    {
        this.mutex.acquire();
        try {
            super.resolve(value);
        } catch (ex:Dynamic) {
            this.mutex.release();
            throw ex;
        }
        this.mutex.release();
    }
}
