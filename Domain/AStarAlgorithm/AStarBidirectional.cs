namespace Domain.AStarAlgorithm;

public class AStarBidirectional
{

public static List<Point> FindPathBidirectional(Point start, Point end, HashSet<Point> walkablePoints)
{
    if (!walkablePoints.Contains(start) || !walkablePoints.Contains(end))
        return new List<Point>();

    var openSetStart = new PriorityQueue<Node, double>();
    var openSetEnd = new PriorityQueue<Node, double>();
    var nodeDictionary = new Dictionary<Point, Node>();
    var closedSetStart = new HashSet<Point>();
    var closedSetEnd = new HashSet<Point>();

    var startNode = GetOrCreateNode(start, nodeDictionary);
    var endNode = GetOrCreateNode(end, nodeDictionary);
    startNode.GCost = 0;
    startNode.HCost = GetDistance(start, end);
    endNode.GCost = 0;
    endNode.HCost = GetDistance(end, start);
    openSetStart.Enqueue(startNode, startNode.FCost);
    openSetEnd.Enqueue(endNode, endNode.FCost);

    while (openSetStart.Count > 0 && openSetEnd.Count > 0)
    {
        var currentNodeStart = openSetStart.Dequeue();
        var currentNodeEnd = openSetEnd.Dequeue();

        if (closedSetEnd.Contains(currentNodeStart.Point) || closedSetStart.Contains(currentNodeEnd.Point))
            return RetracePathBidirectional(startNode, endNode, currentNodeStart, currentNodeEnd);

        closedSetStart.Add(currentNodeStart.Point);
        closedSetEnd.Add(currentNodeEnd.Point);

        ProcessNeighbors(currentNodeStart, nodeDictionary, closedSetStart, openSetStart, walkablePoints, end);
        ProcessNeighbors(currentNodeEnd, nodeDictionary, closedSetEnd, openSetEnd, walkablePoints, start);
    }
    return new List<Point>();
}

private static void ProcessNeighbors(
    Node currentNode,
    Dictionary<Point, Node> nodeDictionary,
    HashSet<Point> closedSet,
    PriorityQueue<Node, double> openSet,
    HashSet<Point> walkablePoints,
    Point target)
{
    foreach (var (dx, dy) in new[] {(-1, 0), (1, 0), (0, -1), (0, 1)})
    {
        var neighborPoint = new Point(currentNode.Point.XWidth + dx, currentNode.Point.YHeight + dy);
        if (!walkablePoints.Contains(neighborPoint) || closedSet.Contains(neighborPoint)) continue;

        var neighbor = GetOrCreateNode(neighborPoint, nodeDictionary);
        var tentativeGCost = currentNode.GCost + 1;
        if (tentativeGCost < neighbor.GCost)
        {
            neighbor.GCost = tentativeGCost;
            neighbor.HCost = GetDistance(neighbor.Point, target);
            neighbor.Parent = currentNode;
            openSet.Enqueue(neighbor, neighbor.FCost);
        }
    }
}

private static Node GetOrCreateNode(Point point, Dictionary<Point, Node> nodeDictionary)
{
    if (!nodeDictionary.TryGetValue(point, out var node))
    {
        node = new Node(point);
        nodeDictionary.Add(point, node);
    }
    return node;
}

private static double GetDistance(Point a, Point b)
{
    return Math.Abs(a.XWidth - b.XWidth) + Math.Abs(a.YHeight - b.YHeight);
}

private static List<Point> RetracePathBidirectional(
    Node startNode,
    Node endNode,
    Node meetingNodeStart,
    Node meetingNodeEnd)
{
    var pathFromStart = new List<Point>();
    var current = meetingNodeStart;
    while (current != null && current != startNode)
    {
        pathFromStart.Add(current.Point);
        current = current.Parent;
    }
    if (current == startNode) pathFromStart.Add(startNode.Point);
    pathFromStart.Reverse();

    var pathFromEnd = new List<Point>();
    current = meetingNodeEnd;
    while (current != null && current != endNode)
    {
        pathFromEnd.Add(current.Point);
        current = current.Parent;
    }
    if (current == endNode) pathFromEnd.Add(endNode.Point);

    pathFromStart.AddRange(pathFromEnd);
    return pathFromStart;
}
}
