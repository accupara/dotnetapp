using System;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("Starting long-running application...");
        var startTime = DateTime.Now;

        int iteration = 0;
        while ((DateTime.Now - startTime).TotalMinutes < 60)
        {
            iteration++;
            Console.WriteLine($"Iteration {iteration}: Running for {(int)(DateTime.Now - startTime).TotalSeconds} seconds...");

            // Breakpoint can be placed here
            await Task.Delay(5000); // Wait 5 seconds per loop
        }

        Console.WriteLine("Application completed after 1 hour.");
    }
}
