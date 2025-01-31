This is a .NET 8 sample app to test how to shed load if the threadpool can't keep up with incoming requests, along with a load testing tool.

There are a few endpoints that can be hit
- /async-slow - awaits for 1 second, then returns OK
- /sync-slow - sleeps the thread for 1 second, then returns OK
- /very-bad-sync-slow - uses sync over async, blocks 2 threads for 1 second, then returns OK
- /healthcheck - makes a sql query, returns OK without delay
- /sql-async-slow - awaits a query that takes 1 second to execute, returns OK

Run each of these commands in a new terminal:
- `docker compose up --build`
- `docker exec -it dotnet-nginx-testing-web-1 /root/.dotnet/tools/dotnet-counters monitor --process-id 1 --providers Microsoft.AspNetCore.Hosting Microsoft.AspNetCore.Http.Connections Microsoft-AspNetCore-Server-Kestrel System.Runtime`
- `docker exec -it dotnet-nginx-testing-bombardier-1 /bombardier-scripts/run-tests.sh --route-name "async-slow" --thread-pool-limiter 100 --host nginx:18151`

Or to run a one-off test, `docker exec dotnet-nginx-testing-bombardier-1 bombardier nginx:18151/async-slow -c 500 -t 30s`

The different mechanisms of throttling:
- Add "thread-pool-limiter: 200" as a header, where 200 is the value of the maximum number of items on PendingWorkItemCount before requests will be rejected. This will check the value of ThreadPool.PendingWorkItemCount as an approximation for how busy the app backend is, and reject requests if they are over a fixed threshold (500). Note that it's expected that a small number of items may be present here at all times, as async continuations will be scheduled this way. Kestrel queues connections on the threadpool [here](https://github.com/dotnet/aspnetcore/blob/4442a188f9200a57635373dcd640893c0e8dcc78/src/Servers/Kestrel/Core/src/Internal/ConnectionDispatcher.cs#L68). The source for this is in `ThreadPoolCheckMiddleware.cs`
- Use a nginx to limit the maximum concurrent connections to the backend. This is accomplished by using `limit_conn_zone $server_addr zone=servers18152:10m;` and `limit_conn servers18152 400;`. The server on port 18151 has a limit of 2000 (much higher than the minthread count), and thus sync over async blocking code will be more visible on this instance. Port 18152 has a limit of 400. When using 18152, you should never see the threadpool queue length grow out of control, which protects the app against synchronous blocking requests growing unbounded. However, it will also cause async requests that could otherwise be satistfied to be turned away.

There is a list of TEST_CASES in run-tests.sh. Modify that to hit the routes you want while adjusting the minthread count and throttling middleware.
