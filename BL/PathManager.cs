using System.Threading.Channels;
using Domain;
using Domain.AStarAlgorithm;
using Microsoft.Extensions.Logging;

namespace BL;

public class PathManager
{
    private readonly ILogger<PathManager> _logger;

    public PathManager(ILogger<PathManager> logger)
    {
        _logger = logger;
    }

    //TODO fix dto
    public async Task<List<Point>> FindPath(Point start, Point end, String image)
    {
        
        var (startP, endP, walkablePoints) = await Task.Run( () => FloorplanAnalyzer.GetWalkablePoints(image, start ,end));
        if (walkablePoints.Count == 0)
        {
            Console.WriteLine("No walkable points found.");
            return new List<Point>();
        }
        var path = await Task.Run(() => AStarPathfinding.FindPath(startP, endP, walkablePoints));
        _logger.LogInformation($"Path found: {path} {path.Count}");
        return path;
    }
}