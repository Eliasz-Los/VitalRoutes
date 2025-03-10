using System.Collections.Concurrent;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

namespace Domain.AStarAlgorithm;

public class FloorplanAnalyzer
{
    /*
     * Blijft synchronous zodat de analyze vna de image nog nie meer complex wordt voor het systeem.
     * Het bevat al multithreading en concurrentie list.
     */
    public static (Point start, Point end, HashSet<Point>) GetWalkablePoints(string imagePath, Point startCoords, Point endCoords)
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
                        walkablePoints.Add(point);
                       

                        if (Math.Abs(x - startCoords.XWidth) < 1e-10 && Math.Abs(y - startCoords.YHeight) < 1e-10) startPoint = point;
                        if (Math.Abs(x - endCoords.XWidth) < 1e-10 && Math.Abs(y - endCoords.YHeight) < 1e-10) endPoint = point;
                    }
                }
                /*if (x % 100 == 0)
                {
                    Console.WriteLine($"Processed {x} columns. Out of {image.Width}."); // Progress indicator
                }*/
            });
            
        }
        
        if (startPoint == null || endPoint == null)
        {
            throw new Exception("Start or end point is not walkable.");
        }
        Console.WriteLine($"Total walkable points: {walkablePoints.Count}");

        return (startPoint, endPoint, new HashSet<Point>(walkablePoints) ); //walkablePoints.ToHashSet()
    }

    public static bool IsBlackWall(Rgba32 pixel)
    {
        return pixel is { R: 0, G: 0, B: 0 }; // black
    }
}