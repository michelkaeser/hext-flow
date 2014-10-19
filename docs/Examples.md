# Examples

> Various ready-to-use code examples showing how to use the `hext-flow`
> library.

## Cascade

```haxe
import hext.flow.async.Cascade;
import hext.flow.async.Future;
import hext.threading.ExecutionContext;

var c:Cascade<Int> = new Cascade<Int>(ExecutionContext.parallelExecutor);

c.add(function(arg:Int):Int {
    return arg + 2;
});
c.add(function(arg:Int):Int {
    return arg * 2;
});

var f:Future<Int> = c.plunge(2); // non-blocking call
trace(f.get(true));              // should output '8'
```

## Future

```haxe
import hext.flow.async.Future;
import hext.vm.Thread;

var f:Future<Int> = new Future<Int>();
Thread.create(function():Void {
    trace(f.get(true)); // blocks until Future is resolved, should output '5'
});

f.resolve(5);
Sys.sleep(1); // for demo, ensures Thread had time to do its work
```

## Dispatcher

```haxe
import hext.Nil;
import hext.flow.Dispatcher.Status;
import hext.flow.async.Dispatcher;
import hext.flow.async.Dispatcher.Feedback;
import hext.flow.async.Promise;
import hext.threading.ExecutionContext;
import hext.vm.Thread;

var d:Dispatcher<Int> = new Dispatcher<Int>(ExecutionContext.parallelExecutor);

d.register("event");
d.attach("event", function(arg:Int):Void {
    trace(arg); // should output '2'
});

var f:Feedback = d.trigger("event", 2); // non-blocking trigger
if (f.status == Status.TRIGGERED) {
    f.promise.await(); // blocks until all callbacks are executed
}
```

## Promise

```haxe
import hext.flow.async.Promise;
import hext.threading.ExecutionContext;

var p:Promise<Int> = new Promise<Int>(ExecutionContext.parallelExecutor);

p.done(function(arg:Int):Void {
    trace("Rejected or resolved");
});
p.rejected(function(arg:Int):Void {
    trace("Rejected");
});
p.resolved(function(arg:Int):Void {
    trace("Resolved");
});
Promise.when([p]).done(function(arg:Int):Void {
    trace("All callbacks executed");
});

p.resolve(5); // non-blocking resolve, triggers 'done' and 'resolved'
p.await();    // blocks until callbacks are executed
Sys.sleep(1); // demo only, ensure Promise.when Thread has done its work
```
