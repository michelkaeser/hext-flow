package flow;

/**
 * Statuses representing the various states a Future/Promise etc. can have.
 */
enum State
{
    NONE;     // newly initialized
    REJECTED;
    RESOLVED;
}
