package flow;

import flow.State;
import flow.WorkflowException;

/**
 * A Future can be understood as a pledge that it will contain a
 * valid value at some time (that is not right now).
 *
 * This is useful if you know that some data will somewhen be available
 * but you are not sure when (but need to wait for it).
 *
 * This version is not thread safe and therefor not of much use, as it will
 * simply throw an error when the Future's value has not been set yet.
 *
 * @generic T the type of value you expect
 */
class Future<T>
{
    /**
     * Stores the value that was passed when resolving.
     *
     * @var Null<T>
     */
    private var value:Null<T>;

    /**
     * Stores the state.
     *
     * @var flow.State
     */
    private var state:State;


    /**
     * Constructor to initialize a new Future.
     */
    public function new():Void
    {
        this.value = null;
        this.state = State.NONE;
    }

    /**
     * Returns the value once it is set.
     *
     * @param Bool block either to wait until a value is set or not
     *
     * @return T the value set
     *
     * @throws flow.WorkflowException if the Future has not been resolved yet (since the non-threaded version can't wait)
     */
    public function get(block:Bool = true):T
    {
        if (!this.isReady()) {
            throw new WorkflowException("Future has not been resolved yet.");
        }

        return this.value;
    }

    /**
     * Checks if the Future is ready (e.g. it is either rejected or resolved).
     *
     * @return Bool
     */
    public function isReady():Bool
    {
        return this.state != State.NONE;
    }

    /**
     * Checks if the Future has been rejected.
     *
     * @return Bool
     */
    public function isRejected():Bool
    {
        return this.state == State.REJECTED;
    }

    /**
     * Checks if the Future has been resolved.
     *
     * @return Bool
     */
    public function isResolved():Bool
    {
        return this.state == State.RESOLVED;
    }

    /**
     * Rejects the Future, thus marking it as failed.
     *
     * @throws flow.WorkflowException if the Future has already been marked as ready
     */
    public function reject():Void
    {
        if (this.isReady()) {
            throw new WorkflowException("Future has already been rejected or resolved.");
        }

        this.state = State.REJECTED;
    }

    /**
     * Resolves the Future by setting its value to the provided value.
     *
     * @param T value the value to set
     *
     * @throws flow.WorkflowException if the Future has already been marked as ready
     */
    public function resolve(value:T):Void
    {
        if (this.isReady()) {
            throw new WorkflowException("Future has already been resolved.");
        }

        this.value  = value;
        this.state = State.RESOLVED;
    }
}
