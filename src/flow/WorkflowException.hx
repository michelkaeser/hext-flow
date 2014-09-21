package flow;

import haxe.PosInfos;
import std.Exception;

/**
 * Exception to signalize problems in the workflow/code flow
 * or errors/problems caused by synchronization between threads.
 */
class WorkflowException extends Exception
{
    /**
     * @{inherit}
     */
    public function new(msg:Dynamic = "Error in workflow logic/synchronization", ?info:PosInfos):Void
    {
        super(msg, info);
    }
}
