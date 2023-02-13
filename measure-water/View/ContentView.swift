//
//  ContentView.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/01/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State var buttonText = "計測スタート"
    @State var isButtonStart = false
    @State var isVisibleImageCoin = false
    @State var isStartingCoinAnimation = false
    
    @State var coinTransitionX: CGFloat = 0.0
    @State var coin2TransitionX: CGFloat = 0.0
    @State var coin3TransitionX: CGFloat = 0.0
    @State var coin4TransitionX: CGFloat = 0.0
    
    @State var coinTransitionY: CGFloat = 0.0
    @State var coinRotateDegree: Double = 0.0
    @State var measuringTextOpacity = 0.0
    
    @State var tmpMeasureTime = 0

    @StateObject var appState = AppState()
    @ObservedObject private var buttonManager = ButtonManager.shared
    
    private let coinPositionX = -70.0
    private let coinPositionY = 50.0
    
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
                        Text("12.0")
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
                        if buttonManager.isButtonStart == true && appState.detectionStates[0].1.isDetected {
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
                                    .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                                    value: isStartingCoinAnimation
                                )
                                .offset(
                                    x: coinPositionX,
                                    y: coinPositionY + coinTransitionY
                                )
                                .onAppear {
                                    // animation
                                    isStartingCoinAnimation = true
                                    
                                    coinTransitionX += 150.0
                                    coin2TransitionX -= 150.0
                                    coin3TransitionX -= 200.0
                                    coin4TransitionX += 200.0
                                    
                                    coinTransitionY += 500.0

                                    coinRotateDegree += 360
                                }
                                .onDisappear {
                                    // animation
                                    isStartingCoinAnimation = false

                                    coinTransitionX = 0.0
                                    coin2TransitionX = 0.0
                                    coin3TransitionX = 0.0
                                    coin4TransitionX = 0.0

                                    coinTransitionY = 0.0

                                    coinRotateDegree = 0

                                    tmpMeasureTime = appState.detectionStates[0].1.time
                                }
                            CoinImageView(
                                coinTransitionX: $coinTransitionX,
                                coinTransitionY: $coinTransitionY,
                                isStartingCoinAnimation: $isStartingCoinAnimation,
                                coinRotateDegree: $coinRotateDegree,
                                duration: 1.5
                            )
                            CoinImageView(
                                coinTransitionX: $coin2TransitionX,
                                coinTransitionY: $coinTransitionY,
                                isStartingCoinAnimation: $isStartingCoinAnimation,
                                coinRotateDegree: $coinRotateDegree,
                                duration: 1.2,
                                delay: 0.3
                            )
                            CoinImageView(
                                coinTransitionX: $coin3TransitionX,
                                coinTransitionY: $coinTransitionY,
                                isStartingCoinAnimation: $isStartingCoinAnimation,
                                coinRotateDegree: $coinRotateDegree,
                                duration: 1.3,
                                delay: 0.2
                            )
                            CoinImageView(
                                coinTransitionX: $coin4TransitionX,
                                coinTransitionY: $coinTransitionY,
                                isStartingCoinAnimation: $isStartingCoinAnimation,
                                coinRotateDegree: $coinRotateDegree,
                                duration: 1.4
                            )
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
                if buttonManager.isButtonStart {
                    buttonManager.stopButton()
                    buttonText = "スタート"
                    appState.stopDetection()
                    isVisibleImageCoin = false
                    isStartingCoinAnimation = false
                    measuringTextOpacity = 0.0
                } else {
                    buttonManager.startButton()
                    buttonText = "ストップ"
                    appState.restartDetection()
                    measuringTextOpacity = 1.0
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
            
            if let url = URL(string: "https://forms.gle/x6uEdqZTHSkWQT8k7") {
                Link("アンケート回答はこちらをタップ", destination: url)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .foregroundColor(Color.black)
        .background(Color.white)
        .onAppear {
            buttonManager.stopButton()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                if buttonManager.isButtonStart {
                    buttonManager.startButton()
                    buttonText = "ストップ"
                    appState.restartDetection()
                    measuringTextOpacity = 1.0
                } else {
                    buttonManager.stopButton()
                    buttonText = "スタート"
                    appState.stopDetection()
                    isVisibleImageCoin = false
                    isStartingCoinAnimation = false
                    measuringTextOpacity = 0.0
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
    }
}
