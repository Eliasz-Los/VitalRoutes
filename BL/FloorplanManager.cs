using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BackendApi.Models.Dto;
using BL.Dto_s;
using DAL.EF;
using Domain;

namespace BL
{
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
            var floorPlans = _floorplanRepository.ReadFloorplanByHospitalName(hospitalName)?.ToList() ?? new List<Floorplan>();

            var result = new List<FloorplanDto>();

            foreach (var floorPlan in floorPlans)
            {
                var filePath = Path.Combine(folderPath, floorPlan.Image);

                if (!File.Exists(filePath))
                {
                    throw new FileNotFoundException($"File not found for floorplan: {floorPlan.Image}", filePath);
                }

                var imageData = Convert.ToBase64String(File.ReadAllBytes(filePath));

                var floorplanDto = new FloorplanDto
                {
                    Id = floorPlan.Id,
                    Name = floorPlan.Name,
                    FloorNumber = floorPlan.FloorNumber,
                    Scale = floorPlan.Scale,
                    Nodes = floorPlan.Nodes?.Select(node => new PointDto
                    {
                        Id = node.Id,
                        XWidth = node.XWidth,
                        YHeight = node.YHeight
                    }).ToList() ?? new List<PointDto>(),
                    Hospital = new HospitalDto
                    {
                        Id = floorPlan.Hospital?.Id ?? Guid.Empty,
                        Name = floorPlan.Hospital?.Name ?? string.Empty
                    },
                    ImageData = imageData
                };
                result.Add(floorplanDto);
            }
            return result;
        }
    }
}