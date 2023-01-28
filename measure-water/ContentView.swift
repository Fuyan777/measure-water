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
    
    var body: some View {
        VStack {
            Spacer().frame(height: 30)
            
            Text("水の使用量")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(alignment: .center, spacing: 40) {
                MeasureValueLabelView(
                    day: "昨日",
                    measureValue: "10"
                )
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: 60)
                
                MeasureValueLabelView(
                    day: "今日",
                    measureValue: "30"
                )
            }
            .font(.title2)
            
            Spacer().frame(height: 70)
            
            ZStack {
                HStack {
                    Spacer()
                    ZStack {
                        if isVisibleImageCoin {
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
                                    coinPositionY = 0.0
                                    coinRotateDegree = 0
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
                    isVisibleImageCoin = true
                } else {
                    buttonText = "スタート"
                    isVisibleImageCoin = false
                    isStartingCoinAnimation = false
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
    @State var measureValue = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(day)
            HStack {
                Text(measureValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                Text("ml")
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
