using System.Collections.Concurrent;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using Point = Domain.Point;

namespace PathfindingConsole;

public class FloorplanAnalyzer
{
    public static (Point start, Point end, HashSet<Point>) GetWalkablePoints(string imagePath, (double x, double y) startCoords, (double x, double y) endCoords)
    {
        // ConcurrentBag is thread-safe
        var walkablePoints = new ConcurrentBag<Point>();
        Point startPoint = null;
        Point endPoint = null;
        
        using (Image<Rgba32> image = Image.Load<Rgba32>(imagePath))
        {
            Parallel.For(0, image.Width, x =>
            {
                for (int y = 0; y < image.Height; y++)
                {
                    var pixel = image[x, y];
                    if (!IsBlackWall(pixel))
                    {
                        var point = new Point(x, y);
                        lock (walkablePoints)
                        {
                            walkablePoints.Add(point);
                        }

                        if (Math.Abs(x - startCoords.x) < 1e-10 && Math.Abs(y - startCoords.y) < 1e-10) startPoint = point;
                        if (Math.Abs(x - endCoords.x) < 1e-10 && Math.Abs(y - endCoords.y) < 1e-10) endPoint = point;
                    }
                }
                if (x % 100 == 0)
                {
                    Console.WriteLine($"Processed {x} columns. Out of {image.Width}."); // Progress indicator
                }
            });
            
        }
        
        if (startPoint == null || endPoint == null)
        {
            throw new Exception("Start or end point is not walkable.");
        }
        Console.WriteLine($"Total walkable points: {walkablePoints.Count}");

        return (startPoint, endPoint, walkablePoints.ToHashSet());
    }

    public static bool IsBlackWall(Rgba32 pixel)
    {
        return pixel is { R: 0, G: 0, B: 0 }; // black
    }
}