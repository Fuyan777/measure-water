//
//  ContentView.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/01/24.
//

import SwiftUI

struct ContentView: View {
    @State var buttonText = "計測スタート"
    @State var isButtonStart = false
    @State var isVisibleImageCoin = false
    @State var isStartingCoinAnimation = false
    @State var coinPositionX: CGFloat = 0.0
    @State var coinPositionY: CGFloat = 0.0
    @State var coinRotateDegree: Double = 0.0
    @State var measuringTextOpacity = 0.0
    
    @State var tmpMeasureTime = 0

    @StateObject var appState = AppState()
    
    var body: some View {
        VStack {
            Spacer().frame(height: 30)
            
            Text("水の使用量")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: .center, spacing: 40) {
                VStack(alignment: .center, spacing: 8) {
                    Text("昨日")
                    HStack {
                        Text("0.0")
                            .frame(width: 80)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        Text("L")
                    }
                }
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: 60)
                
                MeasureValueLabelView(
                    day: "今日",
                    appState: appState,
                    time: $tmpMeasureTime
                )
            }
            .font(.title2)

            Text("〜計測中〜")
                .opacity(measuringTextOpacity)
                .animation(appState.isStartSoundDetection ? .easeOut(duration: 0.7).repeatForever(autoreverses: true) : nil,
                           value: appState.isStartSoundDetection)
            
            Spacer().frame(height: 70)
            
            ZStack {
                HStack {
                    Spacer()
                    ZStack {
                        if appState.detectionStates[0].1.isDetected && isButtonStart == true {
                            Image("img-coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .animation( // rotation animation
                                    .easeInOut,
                                    value: isStartingCoinAnimation
                                )
                                .rotationEffect(
                                    Angle.degrees(coinRotateDegree),
                                    anchor: .center
                                )
                                .animation( // positionY animation
                                    .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                                    value: isStartingCoinAnimation
                                )
                                .offset(
                                    x: -70.0,
                                    y: 50.0 + coinPositionY
                                )
                                .onAppear {
                                    // animation
                                    isStartingCoinAnimation = true
                                    coinPositionX += 10.0
                                    coinPositionY += 500.0
                                    coinRotateDegree += 360
                                }
                                .onDisappear {
                                    // animation
                                    isStartingCoinAnimation = false
                                    coinPositionY = 0.0
                                    coinRotateDegree = 0
                                    tmpMeasureTime = appState.detectionStates[0].1.time
                                }
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Image("img-tap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
            
            Spacer()
            
            Button(action: {
                isButtonStart.toggle()
                
                if isButtonStart {
                    buttonText = "ストップ"
                    appState.restartDetection()
                    measuringTextOpacity = 1.0
                } else {
                    buttonText = "スタート"
                    appState.stopDetection()
                    isVisibleImageCoin = false
                    isStartingCoinAnimation = false
                    measuringTextOpacity = 0.0
                }
            }){
                Text(buttonText)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 240, height: 56)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .padding(.bottom, 56)
            }
        }
        .padding()
        .foregroundColor(Color.black)
        .background(Color.white)
    }
}

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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
}
