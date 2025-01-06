import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Play")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Text("1. You start with 3 lives ❤️")
                
                Text("2. For each question, you'll see an initial guess")
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("3. Use the slider to adjust your guess")
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("4. IMPORTANT: Never guess below the correct answer!")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("5. If you guess below the correct answer:")
                        .fixedSize(horizontal: false, vertical: true)
                    Text("• You lose a life ❤️ → 💔")
                        .foregroundColor(.red)
                        .padding(.leading)
                    Text("• You get 0 points")
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("6. If you guess above the correct answer:")
                        .fixedSize(horizontal: false, vertical: true)
                    Text("• Within 20%: Score up to 100 points")
                        .foregroundColor(.green)
                        .padding(.leading)
                    Text("• Over 20%: Lose a life and get 0 points")
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                
                Text("7. Game ends when you run out of lives")
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("8. Try to get the highest score possible!")
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationBarTitle("How to Play", displayMode: .inline)
    }
} 
