package hext.flow.concurrent;

#if !js
    import hext.ds.SynchronizedList;
#end
import hext.flow.Cascade.Tier;

/**
 * Threads-safe Cascade implementation.
 *
 * @{inherit}
 */
class Cascade<T> extends hext.flow.Cascade<T>
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
