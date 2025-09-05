using System.Diagnostics;
using System.Drawing;
using Domain;
using Point = Domain.Point;

namespace PathfindingConsole;

public class FloorplanVisualizer
{
    public static void DrawFloorplanWithPath(Floorplan floorplan, List<Point> path, Point start, Point end, string imagePath)
    {
        Console.WriteLine("FloorplanVisualizer: " + imagePath);
        if (!File.Exists(imagePath))
        {
            Console.WriteLine("Image file not found.");
            return;
        }

        using (Bitmap bitmap = new Bitmap(imagePath))
        {
            using (Graphics g = Graphics.FromImage(bitmap))
            {
                Pen pathPen = new Pen(Color.Blue, 6); //2 width
                Brush pointBrush = new SolidBrush(Color.Purple);
                 /*Brush walkableBrush = new SolidBrush(Color.Green);

                // 1. Draw the walkable points
                foreach (var point in floorplan.Points)
                {
                    g.FillRectangle(walkableBrush, (float)point.XWidth, (float)point.YHeight, 1, 1);
                }*/
                
                // 2. Draw the start and end points
                g.FillEllipse(pointBrush, (float)start.XWidth - 3, (float)start.YHeight - 3, 18, 18);
                g.FillEllipse(pointBrush, (float)end.XWidth - 3, (float)end.YHeight - 3, 18, 18);
                
                // 3. Draw the path
                for (int i = 0; i < path.Count - 1; i++)
                {
                    var startPoint = path[i];
                    var endPoint = path[i + 1];
                    g.DrawLine(pathPen, (float)startPoint.XWidth, (float)startPoint.YHeight, (float)endPoint.XWidth, (float)endPoint.YHeight);
                }
            }
            
            string outputImagePath = Path.Combine(Path.GetDirectoryName(imagePath) ?? string.Empty, "output_path.png");
            Debug.Assert(outputImagePath != null, nameof(outputImagePath) + " != null");
            bitmap.Save(outputImagePath);
            Console.WriteLine($"Path drawn and saved to {outputImagePath}");
        }
    }
}