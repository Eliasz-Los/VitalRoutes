﻿using System.Collections.Concurrent;
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
        int margin = 350; //250 was goe maar 500 kon wel getekend worden
        
        
        using (Image<Rgba32> image = Image.Load<Rgba32>(imagePath))
        {
            // Bounded Search Space zodat het nie alle punten/pixels moet overlopen
            int minX = (int)Math.Max(0, Math.Min(startCoords.XWidth, endCoords.XWidth) - margin);
            int maxX = (int)Math.Min(image.Width, Math.Max(startCoords.XWidth, endCoords.XWidth) + margin);
            int minY = (int)Math.Max(0, Math.Min(startCoords.YHeight, endCoords.YHeight) - margin);
            int maxY = (int)Math.Min(image.Height, Math.Max(startCoords.YHeight, endCoords.YHeight) + margin);
            
            image.ProcessPixelRows(accessor =>
            {
                for (int y = minY; y < maxY; y++)
                {
                    var rowSpan = accessor.GetRowSpan(y);
                    for (int x = minX; x < maxX; x++)
                    {
                        var pixel = rowSpan[x];
                        if (!IsBlackWall(pixel))
                        {
                            var p = new Point(x, y);
                            walkablePoints.Add(p);
                            if (x == (int)startCoords.XWidth && y == (int)startCoords.YHeight) startPoint = p;
                            if (x == (int)endCoords.XWidth && y == (int)endCoords.YHeight) endPoint = p;
                        }
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
