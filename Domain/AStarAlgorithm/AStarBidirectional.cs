using System.Collections.Concurrent;

namespace Domain.AStarAlgorithm;

public class AStarBidirectional
{

public static List<Point> FindPathBidirectional(Point start, Point end, HashSet<Point> walkablePoints)
{
    if (!walkablePoints.Contains(start) || !walkablePoints.Contains(end))
    {
        Console.WriteLine("Start or end point is not walkable.");
        return new List<Point>();
    }

        var openSetStart = new PriorityQueue<Node, double>();
        var openSetEnd = new PriorityQueue<Node, double>();
        var nodeDictionary = walkablePoints.ToDictionary(p => p, p => new Node(p));
        var closedSetStart = new HashSet<Node>();
        var closedSetEnd = new HashSet<Node>();

        var startNode = nodeDictionary[start];
        var endNode = nodeDictionary[end];
        startNode.GCost = 0;
        startNode.HCost = GetDistance(start, end);
        endNode.GCost = 0;
        endNode.HCost = GetDistance(end, start);
        openSetStart.Enqueue(startNode, startNode.FCost);
        openSetEnd.Enqueue(endNode, endNode.FCost);

        int iterationCount = 0;
        const int maxIterations = 7000000;

        Console.WriteLine("Start bidirectional pathfinding...");
        while (openSetStart.Count > 0 && openSetEnd.Count > 0)
        {
            iterationCount++;
            if (iterationCount > maxIterations)
            {
                Console.WriteLine("Exceeded maximum iterations, breaking out of loop.");
                break;
            }

            var currentNodeStart = openSetStart.Dequeue();
            var currentNodeEnd = openSetEnd.Dequeue();

            if (closedSetEnd.Contains(currentNodeStart) || closedSetStart.Contains(currentNodeEnd))
            {
                Console.WriteLine("Path found.");
                return RetracePathBidirectional(nodeDictionary[start], nodeDictionary[end], currentNodeStart, currentNodeEnd);
            }

            closedSetStart.Add(currentNodeStart);
            closedSetEnd.Add(currentNodeEnd);

            Parallel.Invoke(
                () => ProcessNeighbors(currentNodeStart, nodeDictionary, closedSetStart, openSetStart, end),
                () => ProcessNeighbors(currentNodeEnd, nodeDictionary, closedSetEnd, openSetEnd, start)
            );
        }

        Console.WriteLine("No path found.");
        return new List<Point>();
    }

    private static void ProcessNeighbors(Node currentNode, Dictionary<Point, Node> nodeDictionary, HashSet<Node> closedSet, PriorityQueue<Node, double> openSet, Point target)
    {
        foreach (var neighbor in GetNeighbors(currentNode.Point, nodeDictionary))
        {
            if (closedSet.Contains(neighbor)) continue;

            var tentativeGCost = currentNode.GCost + GetDistance(currentNode.Point, neighbor.Point);

            if (tentativeGCost < neighbor.GCost)
            {
                neighbor.GCost = tentativeGCost;
                neighbor.HCost = GetDistance(neighbor.Point, target);
                neighbor.Parent = currentNode;
                openSet.Enqueue(neighbor, neighbor.FCost);
            }
        }
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
            if (nodeDictionary.TryGetValue(neighborPoint, out var neighbor))
            {
                yield return neighbor;
            }
        }
    }

    private static double GetDistance(Point a, Point b)
    {
        return Math.Abs(a.XWidth - b.XWidth) + Math.Abs(a.YHeight - b.YHeight); // Manhattan distance
    }

    private static List<Point> RetracePathBidirectional(Node startNode, Node endNode, Node meetingNodeStart, Node meetingNodeEnd)
    {
        var path = new List<Point>();
        var currentNode = meetingNodeStart;

        while (currentNode != null && !currentNode.Equals(startNode))
        {
            path.Add(currentNode.Point);
            currentNode = currentNode.Parent;
        }

        path.Reverse();
        currentNode = meetingNodeEnd.Parent;

        while (currentNode != null && !currentNode.Equals(endNode))
        {
            path.Add(currentNode.Point);
            currentNode = currentNode.Parent;
        }

        return path;
    }
}
