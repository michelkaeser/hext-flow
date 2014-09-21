package flow.concurrent;

#if !js
    import std.ds.SynchronizedList;
#end
import flow.Cascade.Tier;

/**
 * Threads-safe Cascade implementation.
 *
 * @{inherit}
 */
class Cascade<T> extends flow.Cascade<T>
{
    /**
     * @{inherit}
     */
    public function new():Void
    {
        super();
        #if !js this.tiers = new SynchronizedList<Tier<T>>(this.tiers); #end
    }
}
