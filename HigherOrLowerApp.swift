//
//  HigherOrLowerApp.swift
//  HigherOrLower
//
//  Created by PJ Loury on 1/5/25.
//

import Foundation
import SwiftUI

@main
struct HigherOrLowerApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch gameManager.gameState {
                case .home:
                    HomeView(gameManager: gameManager)
                case .playing:
                    GameView(gameManager: gameManager)
                        .navigationBarBackButtonHidden()
                        .ignoresSafeArea(.keyboard)
                }
            }
            .navigationViewStyle(.stack)
        }
    }
}
