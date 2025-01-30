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

    public async Task InvokeAsync(HttpContext context)
    {
        if (ThreadPool.PendingWorkItemCount > 500)
        {
            context.Response.StatusCode = StatusCodes.Status503ServiceUnavailable;
            await context.Response.WriteAsync("Service Unavailable");
        }
        else
        {
            await _next(context);
        }
    }
}
