//
//  LabelView.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/10.
//

import Foundation
import SwiftUI

struct MeasureValueLabelView: View {
    var day = ""
    @ObservedObject var appState: AppState
    @Binding var time: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(day)
            HStack {
                Text(
                    appState.isStartSoundDetection
                    ? String(format: "%.1f", MeasureValueLabelView.convertLiter(appState.detectionStates[0].1.time))
                    : String(format: "%.1f", MeasureValueLabelView.convertLiter(time))
                )
                .frame(width: 80)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
                Text("L")
            }
        }
    }
}

extension MeasureValueLabelView {
    static func convertLiter(_ time: Int) -> Double {
        return Double(time) * 0.2
    }
}
