package hext.flow;

import Map;
import hext.Callback;
import hext.IterableTools;
import hext.flow.Event;

using Lambda;

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
     * @var Map<hext.flow.Event, List<hext.Callback<T>>>
     */
    private var map:Map<Event, List<Callback<T>>>;


    /**
     * Constructor to initialize a new Dispatcher.
     */
    public function new():Void
    {
        this.map = cast new Map<Event, List<Callback<T>>>();
    }

    /**
     * Attachs the Callback to the Event.
     *
     * @param hext.flow.Event  event    the Event to attach to
     * @param hext.Callback<T> callback the Callback to add
     *
     * @return Bool true if attached
     */
    public function attach(event:Event, callback:Callback<T>):Bool
    {
        if (this.hasEvent(event)) {
            var callbacks = this.map.get(event);
            if (!callbacks.exists(function(fn:Callback<T>):Bool {
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
     * @param hext.flow.Event  event    the Event to dettach from
     * @param hext.Callback<T> callback the Callback to remove
     *
     * @return Bool true if dettached successfully
     */
    public function dettach(event:Event, callback:Callback<T>):Bool
    {
        if (this.hasEvent(event)) {
            if (this.map.get(event).remove(callback)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Executes the Callbacks with the provided argument.
     *
     * @param Iterable<hext.Callback<T>> callbacks the Callbacks to execute
     * @param T                          arg      the argument to pass to the Callbacks
     */
    private function executeCallbacks(callbacks:Iterable<Callback<T>>, arg:T):Void
    {
        for (callback in callbacks) { // callback = Callback<T>;
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
     * Checks if the Event is already registered.
     *
     * @param hext.flow.Event event the Event to search for
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
     * @param hext.flow.Event event the Event to register
     *
     * @return Bool true if registered successfully
     */
    public function register(event:Event):Bool
    {
        if (!this.hasEvent(event)) {
            this.map.set(event, new List<Callback<T>>());

            return true;
        }

        return false;
    }

    /**
     * Triggers the event (with the optional event argument).
     *
     * @param hext.flow.Event event the Event to trigger
     * @param T               arg   the optional argument to pass to the Callbacks
     *
     * @return flow.Dispatcher.Feedback
     */
    public function trigger(event:Event, arg:T):Feedback
    {
        if (this.hasEvent(event)) {
            this.executeCallbacks(IterableTools.toList(this.map.get(event)), arg); // make sure we iterate over a copy

            return { status: Status.OK };
        }

        return { status: Status.NO_SUCH_EVENT };
    }

    /**
     * Unregisters the Event from the Dispatcher.
     *
     * @param hext.flow.Event event the Event to unregister
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
