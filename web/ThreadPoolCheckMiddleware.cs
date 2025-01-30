using Microsoft.AspNetCore.Http;
using System.Threading;
using System.Threading.Tasks;

public class ThreadPoolCheckMiddleware
{
    private readonly RequestDelegate _next;

    public ThreadPoolCheckMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ILogger<ThreadPoolCheckMiddleware> logger)
    {
        var pendingWorkItemCount = ThreadPool.PendingWorkItemCount;

        if (int.TryParse(context.Request.Headers["thread-pool-limiter"], out var limitCount) && pendingWorkItemCount > limitCount)
        {
            context.Response.StatusCode = StatusCodes.Status503ServiceUnavailable;
            logger?.LogWarning("High pending work item count: {PendingWorkItemCount}", pendingWorkItemCount);
            await context.Response.WriteAsync("Service Unavailable");
        }
        else
        {
            await _next(context);
        }
    }
}
