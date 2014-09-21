package flow;

import Map;
import flow.Event;
import std.Callback;
import std.ds.IList;
import std.ds.LinkedList;

/**
 * The Dispatcher class can be used to have a central Event dispatching service/instance.
 *
 * Objects can register new Events, listen for triggers and much more.
 *
 * Since this is a non-threaded version all Callbacks are executed in sync and the benefit of
 * using the class is not as large as when used in multi-threaded/async environments.
 *
 * @generic A the type of arguments the Callbacks accept
 */
class Dispatcher<T>
{
    /**
     * Stores a map of Events and their Callbacks.
     *
     * @var Map<Event, std.ds.IList<std.Callback<T>>>
     */
    private var map:Map<Event, IList<Callback<T>>>;


    /**
     * Constructor to initialize a new Dispatcher.
     */
    public function new():Void
    {
        this.map = cast new Map<Event, LinkedList<Callback<T>>>();
    }

    /**
     * Attachs the Callback to the Event.
     *
     * @param flow.Event            event    the Event to attach to
     * @param Null<std.Callback<T>> callback the Callback to add
     *
     * @return Bool true if attached
     */
    public function attach(event:Event, callback:Null<Callback<T>>):Bool
    {
        if (this.hasEvent(event) && callback != null) {
            var callbacks = this.map.get(event);
            if (!Lambda.exists(callbacks, function(fn:Callback<T>):Bool {
                return Reflect.compareMethods(callback, fn);
            })) {
                callbacks.add(callback);

                return true;
            }
        }

        return false;
    }

    /**
     * Dettachs the Callback from the Event.
     *
     * @param flow.Event            event    the Event to dettach from
     * @param Null<std.Callback<T>> callback the Callback to remove
     *
     * @return Bool true if dettached successfully
     */
    public function dettach(event:Event, callback:Null<Callback<T>>):Bool
    {
        if (this.hasEvent(event) && callback != null) {
            if (this.map.get(event).remove(callback)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Executes the Callbacks with the provided argument.
     *
     * @param Iterable<std.Callback<T>> callbacks the Callbacks to execute
     * @param T                         arg      the argument to pass to the Callbacks
     */
    private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        var callback:Callback<T>;
        for (callback in callbacks) {
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
     * Checks if the Event is already registered.
     *
     * @param flow.Event event the Event to search for
     *
     * @return Bool
     */
    public function hasEvent(event:Event):Bool
    {
        return this.map.exists(event);
    }

    /**
     * Registers the new Event.
     *
     * @param flow.Event event the Event to register
     *
     * @return Bool true if registered successfully
     */
    public function register(event:Event):Bool
    {
        if (!this.hasEvent(event)) {
            var callbacks:LinkedList<Callback<T>> = new LinkedList<Callback<T>>();
            this.map.set(event, callbacks);

            return true;
        }

        return false;
    }

    /**
     * Triggers the event (with the optional event argument).
     *
     * @param flow.Event event the Event to trigger
     * @param T          arg   the optional argument to pass to the Callbacks
     *
     * @return flow.Dispatcher.Feedback
     */
    public function trigger(event:Event, arg:T):Feedback
    {
        if (this.hasEvent(event)) {
            this.executeCallbacks(Lambda.array(this.map.get(event)), arg); // make sure we iterate over a copy

            return { status: Status.OK };
        }

        return { status: Status.NO_SUCH_EVENT };
    }

    /**
     * Unregisters the Event from the Dispatcher.
     *
     * @param flow.Event event the Event to unregister
     *
     * @return Bool true if unregistered successfully
     */
    public function unregister(event:Event):Bool
    {
        if (this.hasEvent(event)) {
            this.map.remove(event);

            return true;
        }

        return false;
    }
}


/**
 * Type returned by a trigger() call summarizing the execution
 * progress of the registered callbacks for the given Event.
 */
typedef Feedback =
{
    public var status:Status;
}


/**
 * Status marker used in Feedback typedef to tell the caller
 * if the trigger has been successful (and been executed),
 * the execution of the callbacks has been dispatched to another
 * service or the Event does not exist.
 */
enum Status
{
    OK;
    NO_SUCH_EVENT;
    NOT_DEFINED;
    TRIGGERED;
}
