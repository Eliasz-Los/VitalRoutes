using System;
using System.Collections.Generic;
using BackendApi.Models.Dto;
using DAL.EF;
using Domain;

namespace BL;

public class FloorplanManager
{
    private readonly FloorplanRepository _floorplanRepository;

    public FloorplanManager(FloorplanRepository floorplanRepository)
    {
        _floorplanRepository = floorplanRepository;
    }
    
    public IEnumerable<Floorplan> GetFloorplans()
    {
        return _floorplanRepository.ReadFloorplans();
    }

    public Floorplan GetFloorplan(Guid id)
    {
        return _floorplanRepository.ReadFloorplan(id);
    }

    public IEnumerable<FloorplanDto> GetFloorplansByHospitalName(string hospitalName, string folderPath)
    {
        var floorPlans =  _floorplanRepository.ReadFloorplanByHospitalName(hospitalName).ToList();
        
        var result = new List<FloorplanDto>();
        
        foreach (var floorPlan in floorPlans)
        {
            var filePath = Path.Combine(folderPath,floorPlan.Image);

            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException($"File not found for floorplan: {floorPlan.Image}", filePath);
            }
            
            var svgData = Convert.ToBase64String(File.ReadAllBytes(filePath));
            
            result.Add(new FloorplanDto
            {
                Id = floorPlan.Id,
                Name = floorPlan.Name,
                FloorNumber = floorPlan.FloorNumber,
                Scale = floorPlan.Scale,
                Nodes = floorPlan.Nodes,
                Hospital = floorPlan.Hospital,
                SvgData = svgData
            });
        }
        return result;
    }
}