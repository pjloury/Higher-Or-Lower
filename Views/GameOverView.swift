import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over!")
                .font(.largeTitle)
            
            Text("Final Score: \(gameManager.score)")
                .font(.title)
            
            Button("Play Again") {
                gameManager.startNewGame()
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Main Menu") {
                gameManager.goToHome()
            }
            .font(.title2)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
} 
