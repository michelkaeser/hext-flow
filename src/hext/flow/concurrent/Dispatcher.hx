package hext.flow.concurrent;

import hext.Callback;
import hext.flow.Dispatcher.Feedback;
import hext.flow.Dispatcher.Status;
import hext.flow.Event;
#if !js
    import hext.vm.Mutex;
#end

using hext.IterableTools;

/**
 * Threads-safe Dispatcher implementation preventing register, listen and trigger
 * faults when multiple threads access the same data.
 *
 * @{inherit}
 */
class Dispatcher<T> extends hext.flow.Dispatcher<T>
{
    /**
     * Stores the Mutex used to synchronize access.
     *
     * @var hext.vm.Mutex
     */
    #if !js private var mutex:Mutex; #end


    /**
     * @{inherit}
     */
    public function new():Void
    {
        super();
        #if !js this.mutex = new Mutex(); #end
    }

    /**
     * @{inherit}
     */
    override public function attach(event:Event, callback:Callback<T>):Bool
    {
        var listening:Bool;
        #if !js this.mutex.acquire(); #end
        listening = super.attach(event, callback);
        #if !js this.mutex.release(); #end

        return listening;
    }

    /**
     * @{inherit}
     */
    override public function dettach(event:Event, callback:Callback<T>):Bool
    {
        var unlistened:Bool;
        #if !js this.mutex.acquire(); #end
        unlistened = super.dettach(event, callback);
        #if !js this.mutex.release(); #end

        return unlistened;
    }

    /**
     * @{inherit}
     */
    override public function hasEvent(event:Event):Bool
    {
        var ret:Bool;
        #if !js this.mutex.acquire(); #end
        ret = super.hasEvent(event);
        #if !js this.mutex.release(); #end

        return ret;
    }

    /**
     * @{inherit}
     */
    override public function register(event:Event):Bool
    {
        var registered:Bool;
        #if !js this.mutex.acquire(); #end
        registered = super.register(event);
        #if !js this.mutex.release(); #end

        return registered;
    }

    /**
     * @{inherit}
     */
    override public function trigger(event:Event, arg:T):Feedback
    {
        if (this.hasEvent(event)) {
            #if !js this.mutex.acquire(); #end
            var callbacks:List<Callback<T>> = this.map.get(event);
            this.executeCallbacks(callbacks.toList(), arg); // make sure we iterate over a copy
            #if !js this.mutex.release(); #end

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
        #if !js this.mutex.acquire(); #end
        unregistered = super.unregister(event);
        #if !js this.mutex.release(); #end

        return unregistered;
    }
}
