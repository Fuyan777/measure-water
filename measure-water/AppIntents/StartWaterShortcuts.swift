//
//  StartWaterShortcuts.swift
//  measure-water
//
//  Created by 山田楓也 on 2023/02/10.
//

import Foundation
import SwiftUI
import AppIntents

struct StartWater: AppIntent {
    static let title: LocalizedStringResource = "水の使用量を計測する"
    static var openAppWhenRun: Bool = true

    @ObservedObject private var buttonManager = ButtonManager.shared
    
    @MainActor
    func perform() async throws -> some IntentResult {
        buttonManager.startButton()
        return .result()
    }
}

struct StopWater: AppIntent {
    static let title: LocalizedStringResource = "水の使用量を計測を終了する"
    static var openAppWhenRun: Bool = true
    
    @ObservedObject private var buttonManager = ButtonManager.shared
    
    @MainActor
    func perform() async throws -> some IntentResult {
        buttonManager.stopButton()
        return .result()
    }
}

struct Shortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWater(),
            phrases: [
                "お水を測って",
                "\(.applicationName)をスタート",
                "\(.applicationName)の水の計測する"
            ]
        );
        AppShortcut(
            intent: StopWater(),
            phrases: [
                "\(.applicationName)をストップ",
                "\(.applicationName)で計測をやめて",
                "\(.applicationName)の水の計測を終了する"
            ]
        )
    }
    static var shortcutTileColor = UIColor.orange
}
