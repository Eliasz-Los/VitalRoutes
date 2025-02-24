using Domain;
using Point = Domain.Point;

namespace PathfindingConsole;

public class AStarPathfinding
{
    public static List<Point> FindPath( Point start, Point end, HashSet<Point> walkablePoints)
    {
        if (!walkablePoints.Contains(start) || !walkablePoints.Contains(end))
        {
            Console.WriteLine("Start or end point is not walkable.");
            return new List<Point>();
        }

        
        var openSet = new PriorityQueue<Node, double>();
        
        var nodeDictionary = walkablePoints.ToDictionary(p => p, p => new Node(p));
        var closedSet = new HashSet<Node>();

        var startNode = nodeDictionary[start];
        startNode.GCost = 0;
        startNode.HCost = GetDistance(start, end);
        openSet.Enqueue(startNode, startNode.FCost);
        
        int iterationCount = 0;
        const int maxIterations = 7000000;//1 mil maar kan tot 6.988.086 gaan omdat da allemaal walkable points zijn

        Console.WriteLine("Start pathfinding...");
        while (openSet.Count > 0)
        {
            iterationCount++;
            if (iterationCount > maxIterations)
            {
                Console.WriteLine("Exceeded maximum iterations, breaking out of loop.");
                break;
            }

            var currentNode = openSet.Dequeue();
            
            if (currentNode.Point.Equals(end))
            {
                Console.WriteLine("Path found.");
                return RetracePath(nodeDictionary[start], currentNode);
            }
            
            closedSet.Add(currentNode);

            foreach (var neighbor in GetNeighbors(currentNode.Point, nodeDictionary))
            {
                if (closedSet.Contains(neighbor)) continue; // Skip already processed nodes
                
                var tentativeGCost = currentNode.GCost + GetDistance(currentNode.Point, neighbor.Point);

                if (tentativeGCost < neighbor.GCost)
                {
                    neighbor.GCost = tentativeGCost;
                    neighbor.HCost = GetDistance(neighbor.Point, end); 
                    neighbor.Parent = currentNode;
                    openSet.Enqueue(neighbor, neighbor.FCost);
                }
            }
            //TODO depending on the amount of nodes, it slows the program from the begin ahllway to room -111, a save of a 1 second
            /*if (closedSet.Count % 500 == 0)
            {
                Console.WriteLine($"Processed {closedSet.Count} nodes. open list size: {openSet.Count}");
            }*/
        }

        Console.WriteLine("No path found.");
        return new List<Point>();
    }

    private static IEnumerable<Node> GetNeighbors(Point point, Dictionary<Point, Node> nodeDictionary)
    {
        var directions = new List<(double, double)>
        {
            (-1, 0), (1, 0), (0, -1), (0, 1),
            (-1, -1), (1, -1), (-1, 1), (1, 1)
        };

        foreach (var (dx, dy) in directions)
        {
            var neighborPoint = new Point(point.XWidth + dx, point.YHeight + dy);
            // Console.WriteLine($"Checking neighbor at ({neighborPoint.XWidth}, {neighborPoint.YHeight})");
           if(nodeDictionary.TryGetValue(neighborPoint, out var neighbor))
            {
                yield return neighbor;
            }
        }
    }

    private static double GetDistance(Point a, Point b)
    {
        return Math.Sqrt(Math.Pow(a.XWidth - b.XWidth, 2) + Math.Pow(a.YHeight - b.YHeight, 2));
    }

    private static List<Point> RetracePath(Node startNode, Node endNode)
    {
        var path = new List<Point>();
        var currentNode = endNode;

        while (currentNode != null && currentNode != startNode)
        {
            path.Add(currentNode.Point);
            currentNode = currentNode.Parent;
        }

        path.Reverse();
        return path;
    }
}