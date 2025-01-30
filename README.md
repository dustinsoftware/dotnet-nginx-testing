This is a .NET 8 sample app to test how to shed load if the threadpool can't keep up with incoming requests, along with a load testing tool.

There are a few endpoints that can be hit
- /weatherforecast - the sample endpoint provided by the webapi template
- /async-slow - awaits for 1 second, then returns OK
- /sync-slow - sleeps the thread for 1 second, then returns OK
- /very-bad-sync-slow - uses sync over async, blocks 2 threads for 1 second, then returns OK
- /healthcheck - makes a sql query, returns OK without delay
- /sql-async-slow - awaits a query that takes 1 second to execute, returns OK

Run each of these commands in a new terminal:
- `docker compose up --build`
- `docker exec -it dotnet-nginx-testing-web-1 /root/.dotnet/tools/dotnet-counters monitor --process-id 1`
- `docker exec -it dotnet-nginx-testing-bombardier-1 /bombardier-scripts/run-tests.sh`

There is a list of TEST_CASES in run-tests.sh. Modify that to hit the routes you want while adjusting the minthread count and throttling middleware.
