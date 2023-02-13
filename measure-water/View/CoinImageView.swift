//
//  CoinImageView.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/10.
//

import Foundation
import SwiftUI

struct CoinImageView: View {
    @Binding var coinTransitionX: CGFloat
    @Binding var coinTransitionY: CGFloat

    @Binding var isStartingCoinAnimation: Bool
    @Binding var coinRotateDegree: Double
    
    var duration: Double = 1.0
    var delay: Double = 0.0
    
    private let coinPositionX = -70.0
    private let coinPositionY = 50.0
    
    var body: some View {
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
                .easeIn(duration: duration).repeatForever(autoreverses: false).delay(delay),
                value: isStartingCoinAnimation
            )
            .offset(
                x: coinPositionX + coinTransitionX,
                y: coinPositionY + coinTransitionY
            )
    }
}
