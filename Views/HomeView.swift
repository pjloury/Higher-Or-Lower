import SwiftUI

struct HomeView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
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
        }
    }
} 
