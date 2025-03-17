using System.Collections.Concurrent;

namespace Domain.AStarAlgorithm;

public class AStarPathfinding
{
    /* 
     *  A* pathfinding algorithm blijft synchronous maar omdat het in aparte Task.Run() wordt uitgevoerd,
     *  zal het geen bottlenecks veroorzaken.
     *  Zo blijft de main thread vrij voor andere taken.
     */
 public static List<Point> FindPath( Point start, Point end, HashSet<Point> walkablePoints)
    {
        if (!walkablePoints.Contains(start) || !walkablePoints.Contains(end))
        {
            Console.WriteLine("Start or end point is not walkable.");
            return new List<Point>();
        }

        
        // Bounded Search Space
        double margin = 500;
        double minX = Math.Min(start.XWidth, end.XWidth) - margin;
        double maxX = Math.Max(start.XWidth, end.XWidth) + margin;
        double minY = Math.Min(start.YHeight, end.YHeight) - margin;
        double maxY = Math.Max(start.YHeight, end.YHeight) + margin;
        
        var openSet = new PriorityQueue<Node, double>();
        var openSetLookup = new HashSet<Point>(); // New HashSet voor snelle lookup, O(1) als de node in de queue zit
        var nodeDictionary = new Dictionary<Point, Node>();
        var closedSet = new HashSet<Point>();
        //ipv in begin alle 6-7miljoen punten in dictionary in te steken gaan we dat doen wnr het nodig is
        Node GetOrCreateNode(Point point)
        {
            if (!nodeDictionary.TryGetValue(point, out var node))
            {
                node = new Node(point);
                nodeDictionary.Add(point, node);
            }
            return node;
        }

        var startNode = GetOrCreateNode(start);
        startNode.GCost = 0;
        startNode.HCost = GetDistance(start, end);
        openSet.Enqueue(startNode, startNode.FCost);
        openSetLookup.Add(start); // om straks te checken
        
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
            openSetLookup.Remove(currentNode.Point); // Remove from lookup set when processing

            if (currentNode.Point.Equals(end))
            {
                Console.WriteLine("Path found.");
                return RetracePath(nodeDictionary[start], currentNode);
            }
            
            closedSet.Add(currentNode.Point);

            //ipv dure functie GetNeighbors te callen, pakken we onmiddelijk de kardinale richtingen in array samen met de breedte en hoogte van de huidige node
            foreach (var (dx, dy) in new[] { (-1, 0), (1, 0), (0, -1), (0, 1) })
            {
                
                var newWidth = currentNode.Point.XWidth + dx;
                var newHeight = currentNode.Point.YHeight + dy;

                // Skippen als buiten de bounded search space
                if (newWidth < minX || newWidth > maxX || newHeight < minY || newHeight > maxY)
                    continue;
                
                var neighborPoint = new Point(newWidth, newHeight);
                
                if (!walkablePoints.Contains(neighborPoint) || closedSet.Contains(neighborPoint)) continue; // Skip already processed nodes
                
                var neighbor = GetOrCreateNode(neighborPoint);
                var tentativeGCost = currentNode.GCost + 1.0;

                if (tentativeGCost < neighbor.GCost)
                {
                    neighbor.GCost = tentativeGCost;
                    neighbor.HCost = GetDistance(neighbor.Point, end); 
                    neighbor.Parent = currentNode;
                    if (!openSetLookup.Contains(neighbor.Point))
                    {
                        //WHAZT NO WAY 00.00.00.44 milisecond from 4-8 seconds
                        openSet.Enqueue(neighbor, neighbor.GCost + 5.0 * neighbor.HCost); //neighbor.FCost
                        openSetLookup.Add(neighbor.Point); 
                    }
                }
            }
        }

        Console.WriteLine("No path found.");
        return new List<Point>();
    }

    /*private static IEnumerable<Node> GetNeighbors(Point point, Dictionary<Point, Node> nodeDictionary)
    {
        var directions = new List<(double, double)>
        {
            (-1, 0), (1, 0), (0, -1), (0, 1), // alleen cardinale richtingen performance boost 4 sec
            // (-1, -1), (1, -1), (-1, 1), (1, 1) // diagonale richtingen
        };

        foreach (var (dx, dy) in directions)
        {
            var neighborPoint = new Point(point.XWidth + dx, point.YHeight + dy);
           if(nodeDictionary.TryGetValue(neighborPoint, out var neighbor))
            {
                yield return neighbor;
            }
        }
    }*/

    private static double GetDistance(Point a, Point b)
    {
        //Van BL119 naar BL129 Kelder
        //Manhattan distance 15.54 sec POLSKA GUROM
        return Math.Abs(a.XWidth - b.XWidth) + Math.Abs(a.YHeight - b.YHeight);
        
        // Euclidean distance 27.2sec
        //return Math.Sqrt(Math.Pow(a.XWidth - b.XWidth, 2) + Math.Pow(a.YHeight - b.YHeight, 2));
    }

    private static List<Point> RetracePath(Node startNode, Node endNode)
    {
        var path = new List<Point>();
        var currentNode = endNode;

        while (currentNode != null && !currentNode.Equals(startNode)) //currentNode != startNode
        {
            path.Add(currentNode.Point);
            currentNode = currentNode.Parent;
        }

        path.Reverse();
        return path;
    }
}