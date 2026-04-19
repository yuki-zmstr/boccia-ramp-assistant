//
//  CalculationService.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import Foundation

struct CalculationService {
    
    static func calculate(target: Double, points: [DataPoint]) -> Double {
        let sorted = points.sorted { $0.distance < $1.distance }
        guard !sorted.isEmpty else { return 0 }
        guard sorted.count > 1 else { return sorted[0].rampPosition }
        
        // Clamp low
        if target <= sorted.first!.distance {
            return round(sorted.first!.rampPosition * 10) / 10
        }
        
        // Clamp high
        if target >= sorted.last!.distance {
            return round(sorted.last!.rampPosition * 10) / 10
        }
        
        // Interpolate inside range
        for i in 0..<(sorted.count - 1) {
            let a = sorted[i]
            let b = sorted[i + 1]
            
            if target >= a.distance && target <= b.distance {
                let ratio = (target - a.distance) / (b.distance - a.distance)
                let result = a.rampPosition + ratio * (b.rampPosition - a.rampPosition)
                return round(result * 10) / 10
            }
        }
        
        return 0
    }
}
