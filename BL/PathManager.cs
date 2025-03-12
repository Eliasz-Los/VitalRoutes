using System.Threading.Channels;
using DAL.EF;
using Domain;
using Domain.AStarAlgorithm;
using Microsoft.Extensions.Logging;

namespace BL;

public class PathManager
{
    private readonly ILogger<PathManager> _logger;
    private readonly FloorplanRepository _floorplanRepository;
    public PathManager(ILogger<PathManager> logger, FloorplanRepository floorplanRepository)
    {
        _logger = logger;
        _floorplanRepository = floorplanRepository;
    }

    public async Task<List<Point>> FindPath(Point start, Point end, String folderPath, String hospitalName, int floorNumber)
    {
        //Getting the image path
        var floorplan = _floorplanRepository.ReadFloorplanByHospitalNameAndFloorNumber(hospitalName, floorNumber);
        var imagePath = Path.Combine(folderPath, floorplan?.Image);
        //Analyzing the walkable points
        var (startP, endP, walkablePoints) = await Task.Run( () => FloorplanAnalyzer.GetWalkablePoints(imagePath, start ,end));
        if (walkablePoints.Count == 0)
        {
            _logger.LogError("No walkable points found.");
            return new List<Point>();
        }
        //Navigating the path
        var path = await Task.Run(() => AStarPathfinding.FindPath(startP, endP, walkablePoints));
        //var path = await Task.Run(() => AStarBidirectional.FindPathBidirectional(startP, endP, walkablePoints));
        _logger.LogInformation($"Path found: {path} {path.Count}");
        return path;
    }
}