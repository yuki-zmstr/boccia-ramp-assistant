//
//  ContentView.swift
//  BocciaRampAssistant
//
//  Created by Yukihide Takahashi on 2026/04/19.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var manager = DataManager()
    
    @State private var distanceText = ""
    @State private var result: Double?
    @State private var selectedBallType = "D1"

    let ballTypes = [
        "D1","D2",
        "SS1","SS2","SS3","SS4","SS5","SS6","SS7","SS8",
        "S1","S2",
        "SM1","SM2","SM3","SM4","SM5",
        "M1","M2","M3"
    ]
    
    let keypadColumns = Array(repeating: GridItem(.flexible()), count: 3)
    let ballTypeColumns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        VStack(spacing: 28) {
            
            Text("Boccia Ramp Assistant")
                .font(.largeTitle.bold())
            
            // Ball Type Selection
            LazyVGrid(columns: ballTypeColumns, spacing: 12) {
                ForEach(ballTypes, id: \.self) { type in
                    Button {
                        selectBall(type)
                    } label: {
                        Text(type)
                            .font(.title2.bold())
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(selectedBallType == type ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedBallType == type ? .white : .black)
                            .cornerRadius(12)
                    }
                }
            }
            
            Text("Distance (m)")
                .font(.title2)
            
            // Distance Display
            Text(distanceText.isEmpty ? "0" : distanceText)
                .font(.system(size: 52, weight: .bold))
                .frame(width: 320, height: 80)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(18)
            
            // Keypad
            LazyVGrid(columns: keypadColumns, spacing: 12) {
                ForEach(["1","2","3","4","5","6","7","8","9",".","0","⌫"], id: \.self) { key in
                    Button {
                        tapKey(key)
                    } label: {
                        Text(key)
                            .font(.system(size: 42, weight: .bold))
                            .frame(height: 95)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(14)
                    }
                }
            }
            
            // Calculate Button
            Button("CALCULATE") {
                calculate()
            }
            .font(.title.bold())
            .frame(width: 420, height: 90)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(18)
            
            // Result
            if let result {
                VStack(spacing: 12) {
                    Text("Ramp Position")
                        .font(.title2)
                    
                    Text("\(String(format: "%.1f", result)) cm")
                        .font(.system(size: 70, weight: .heavy))
                }
            }
            
            Spacer()
        }
        .padding(30)
        .task {
            await manager.load(ballType: selectedBallType)
        }
    }
    
    // MARK: - Actions
    
    func selectBall(_ type: String) {
        selectedBallType = type
        result = nil
        
        Task {
            await manager.load(ballType: type)
        }
    }
    
    func tapKey(_ key: String) {
        if key == "⌫" {
            if !distanceText.isEmpty {
                distanceText.removeLast()
            }
            return
        }
        
        if key == "." && distanceText.contains(".") {
            return
        }
        
        distanceText.append(key)
    }
    
    func calculate() {
        guard let distance = Double(distanceText) else { return }
        result = manager.calculate(distance: distance)
    }
}
