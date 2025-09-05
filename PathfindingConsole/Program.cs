
using System.Diagnostics;
using System.Threading.Channels;
using Domain;
using Domain.AStarAlgorithm;
using PathfindingConsole;

string imagePath = @"..\..\..\..\BackendApi\Floorplans\test_floorplan.png";
/*
 *  Gelijksvloer, 2573.0, 1621.0: 4010.0,345.0
 *  Rechtboven naar fietsenstalling:  4010.0,345.0 :1473.0, 808.0
 *  Kelder:
 * (1507.0,1148.0),room -100 (2096.0,1466.0), room -111 (3427.0,1031.0), room -110 (3116.0,370.0), room -109 (2978.0,840.0)
 *  BL128: 3983.0 1058.0
 */



Stopwatch stopwatchAnalyzer = new Stopwatch();
Stopwatch stopwatchAStar = new Stopwatch();
stopwatchAnalyzer.Start();

Point startCoord = new Point(807.0, 1289.0); //609.0 1379.0
Point endCoord = new Point(3802.0, 354.0 ); //3858.0, 262.0 ;2256.0, 534.0 

var (start, end, walkablePoints) = FloorplanAnalyzer.GetWalkablePoints(imagePath, startCoord,endCoord);
if (walkablePoints == null || walkablePoints.Count == 0)
{
    Console.WriteLine("No walkable points found.");
    return;
}
stopwatchAnalyzer.Stop();
TimeSpan tsAnalyzer = stopwatchAnalyzer.Elapsed;
string elapsedTimeAnalyzer = String.Format("{0:00}:{1:00}:{2:00}.{3:00}",
    tsAnalyzer.Hours, tsAnalyzer.Minutes, tsAnalyzer.Seconds,
    tsAnalyzer.Milliseconds / 10);
Console.WriteLine("Analyzer RunTime: " + elapsedTimeAnalyzer);



var floorplan = new Floorplan("Kelder", 1, "1:100","floor_minus1.png" ) 
{
    Points = walkablePoints
};

Console.WriteLine($"Start point: ({start.XWidth}, {start.YHeight})");
Console.WriteLine($"End point: ({end.XWidth}, {end.YHeight})");
stopwatchAStar.Start();
var path = AStarPathfinding.FindPath( start, end, walkablePoints);
//var path = AStarBidirectional.FindPathBidirectional(start, end, walkablePoints);


stopwatchAStar.Stop();
TimeSpan ts = stopwatchAStar.Elapsed;
string elapsedTime = String.Format("{0:00}:{1:00}:{2:00}.{3:00}",
    ts.Hours, ts.Minutes, ts.Seconds,
    ts.Milliseconds / 10);
Console.WriteLine("A Star only RunTime: " + elapsedTime);

// Draw the path on the floorplan image
FloorplanVisualizer.DrawFloorplanWithPath(floorplan, path, start, end, imagePath);