using Domain;
using Domain.AStarAlgorithm;
using Microsoft.Extensions.Logging;

namespace BL;

public class PathManager
{
    public async Task<List<Point>> FindPath(Point start, Point end, String image)
    {
        //TODO: algemeen maken ipv hardcoded
        /*
        string imagePath = @"C:\Users\peril\Documents\KDG4\TheLab\Project\VitalRoutes\BackendApi\Floorplans\UZ_Groenplaats\floor_minus1C.png";
        */
        
        var (startP, endP, walkablePoints) = await Task.Run( () => FloorplanAnalyzer.GetWalkablePoints(image, start ,end));
        if (walkablePoints == null || walkablePoints.Count == 0)
        {
            Console.WriteLine("No walkable points found.");
            return new List<Point>();
        }
        var path = await Task.Run(() => AStarPathfinding.FindPath(startP, endP, walkablePoints));
        return path;
    }
}