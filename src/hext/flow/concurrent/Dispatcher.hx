package hext.flow.concurrent;

import hext.Callback;
import hext.ds.LinkedList;
import hext.flow.Dispatcher.Feedback;
import hext.flow.Dispatcher.Status;
import hext.flow.Event;
#if !js
    import hext.threading.ISynchronizer;
    import hext.threading.Synchronizer;
#end

/**
 * Threads-safe Dispatcher implementation preventing register, listen and trigger
 * faults when multiple threads access the same data.
 *
 * @{inherit}
 */
class Dispatcher<T> extends hext.flow.Dispatcher<T>
{
    /**
     * Stores the Synchronizer used to synchronize access.
     *
     * @var hext.threading.ISynchronizer
     */
    #if !js private var synchronizer:ISynchronizer; #end


    /**
     * @{inherit}
     */
    public function new():Void
    {
        super();
        #if !js this.synchronizer = new Synchronizer(); #end
    }

    /**
     * @{inherit}
     */
    override public function attach(event:Event, callback:Callback<T>):Bool
    {
        var listening:Bool;
        this.synchronizer.sync(function(parent):Void {
            listening = parent.attach(event, callback);
        }.bind(super));

        return listening;
    }

    /**
     * @{inherit}
     */
    override public function dettach(event:Event, callback:Callback<T>):Bool
    {
        var unlistened:Bool;
        this.synchronizer.sync(function(parent):Void {
            unlistened = parent.dettach(event, callback);
        }.bind(super));

        return unlistened;
    }

    /**
     * @{inherit}
     */
    override public function hasEvent(event:Event):Bool
    {
        var ret:Bool;
        this.synchronizer.sync(function(parent):Void {
            ret = parent.hasEvent(event);
        }.bind(super));

        return ret;
    }

    /**
     * @{inherit}
     */
    override public function register(event:Event):Bool
    {
        var registered:Bool;
        this.synchronizer.sync(function(parent):Void {
            registered = parent.register(event);
        }.bind(super));

        return registered;
    }

    /**
     * @{inherit}
     */
    override public function trigger(event:Event, arg:T):Feedback
    {
        if (this.hasEvent(event)) {
            this.synchronizer.sync(function():Void {
                var callbacks = this.map.get(event);
                this.executeCallbacks(Lambda.array(callbacks), arg); // make sure we iterate over a copy
            });

            return { status: Status.OK };
        }

        return { status: Status.NO_SUCH_EVENT };
    }

    /**
     * @{inherit}
     */
    override public function unregister(event:Event):Bool
    {
        var unregistered:Bool;
        this.synchronizer.sync(function(parent):Void {
            unregistered = parent.unregister(event);
        }.bind(super));

        return unregistered;
    }
}
