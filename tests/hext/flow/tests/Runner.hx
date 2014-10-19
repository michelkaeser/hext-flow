package hext.flow.tests;

#if cpp
    import mcover.coverage.MCoverage;
    import mcover.coverage.CoverageLogger;
#end
import haxe.Timer;
import haxe.unit.TestRunner;

/**
 * TestSuite runner for classes in hext.flow package.
 */
class Runner
{
    public static function main():Void
    {
        var r = new TestRunner();

        r.add( new hext.flow.tests.TestCascade() );
        r.add( new hext.flow.tests.TestDispatcher() );
        r.add( new hext.flow.tests.TestFuture() );
        r.add( new hext.flow.tests.TestPromise() );

        #if (cpp || cs || flash || java || js || neko)
            r.add( new hext.flow.tests.concurrent.TestCascade() );
            r.add( new hext.flow.tests.concurrent.TestDispatcher() );
            r.add( new hext.flow.tests.concurrent.TestPromise() );

            #if (cpp || cs || java || neko)
                r.add( new hext.flow.tests.concurrent.TestFuture() );
                r.add( new hext.flow.tests.async.TestCascade() );
                r.add( new hext.flow.tests.async.TestDispatcher() );
                r.add( new hext.flow.tests.async.TestFuture() );
                r.add( new hext.flow.tests.async.TestPromise() );
            #end
        #end

        var start:Float  = Timer.stamp();
        var success:Bool = r.run();
        #if sys Sys.println("The test suite took: " + (Timer.stamp() - start) + " ms."); #end
        #if cpp MCoverage.getLogger().report(); #end

        #if sys
            Sys.exit(success ? 0 : 1);
        #end
    }
}
