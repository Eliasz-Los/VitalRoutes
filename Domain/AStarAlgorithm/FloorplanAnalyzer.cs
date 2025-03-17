using System.Collections.Concurrent;
using Microsoft.Extensions.ObjectPool;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

namespace Domain.AStarAlgorithm;

public class FloorplanAnalyzer
{
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
      //  return pixel.R < 10 && pixel.G < 10 && pixel.B < 10;

    }
}
