import SwiftUI

struct HomeView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            Spacer()  // Add spacer above content to push down from top
            
            VStack(spacing: 30) {
                Text("Higher or Lower?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("New Game") {
                    gameManager.startNewGame()
                }
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                
                NavigationLink(destination: HowToPlayView()) {
                    Text("How to Play")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                if gameManager.highScore > 0 {
                    Text("High Score: \(gameManager.highScore)")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
            }
            
            Spacer()  // Add spacer below content to push up from bottom
        }
    }
} 
