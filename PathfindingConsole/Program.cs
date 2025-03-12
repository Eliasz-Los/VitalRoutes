
using System.Diagnostics;
using System.Threading.Channels;
using Domain;
using Domain.AStarAlgorithm;
using PathfindingConsole;

string imagePath = @"C:\Users\peril\Documents\KDG4\TheLab\Project\VitalRoutes\BackendApi\Floorplans\UZ_Groenplaats\floor_minus1.png";

//string imagePath = @"C:\Users\peril\Documents\KDG4\TheLab\Project\VitalRoutes\BackendApi\Floorplans\UZ_Groenplaats\floor_minus1C.png";
/*
 *  Gelijksvloer, 2573.0, 1621.0: 4010.0,345.0
 *  Rechtboven naar fietsenstalling:  4010.0,345.0 :1473.0, 808.0
 *  Kelder:
 * (1507.0,1148.0),room -100 (2096.0,1466.0), room -111 (3427.0,1031.0), room -110 (3116.0,370.0), room -109 (2978.0,840.0)
 *  BL128: 3983.0 1058.0
 */



Stopwatch stopwatch = new Stopwatch();
stopwatch.Start();

Point startCoord = new Point(807.0, 1289.0);
Point endCoord = new Point(3858.0, 262.0);

var (start, end, walkablePoints) = FloorplanAnalyzer.GetWalkablePoints(imagePath, startCoord,endCoord);
if (walkablePoints == null || walkablePoints.Count == 0)
{
    Console.WriteLine("No walkable points found.");
    return;
}

var floorplan = new Floorplan("Kelder", 1, "1:100","floor_minus1.png" ) 
{
    Points = walkablePoints
};

Console.WriteLine($"Start point: ({start.XWidth}, {start.YHeight})");
Console.WriteLine($"End point: ({end.XWidth}, {end.YHeight})");

var path = AStarPathfinding.FindPath( start, end, walkablePoints);
//var path = AStarBidirectional.FindPathBidirectional(start, end, walkablePoints);


stopwatch.Stop();
TimeSpan ts = stopwatch.Elapsed;
string elapsedTime = String.Format("{0:00}:{1:00}:{2:00}.{3:00}",
    ts.Hours, ts.Minutes, ts.Seconds,
    ts.Milliseconds / 10);
Console.WriteLine("RunTime " + elapsedTime);
// Draw the path on the floorplan image
FloorplanVisualizer.DrawFloorplanWithPath(floorplan, path, start, end, imagePath);