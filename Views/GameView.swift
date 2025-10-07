import SwiftUI

struct GameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentGuess: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...1
    @State private var isDragging = false
    @State private var lastGuessResult: GuessResult?
    
    private func formatLargeNumber(_ number: Double, isYear: Bool = false) -> String {
        if isYear {
            return "\(Int(number))"
        } else if number >= 1_000_000_000 {
            // Round to nearest 0.1 billion
            let billions = (number / 1_000_000_000).rounded(to: 1)
            return String(format: "%.1f billion", billions)
        } else if number >= 1_000_000 {
            // Round to nearest 0.1 million
            let millions = (number / 1_000_000).rounded(to: 1)
            return String(format: "%.1f million", millions)
        } else {
            return NumberFormatter.localizedString(from: NSNumber(value: Int(number)), number: .decimal)
        }
    }
    
    private func getSliderStep(for value: Double) -> Double {
        if value >= 1_000_000_000 {
            return 100_000_000  // 0.1 billion steps
        } else if value >= 1_000_000 {
            return 100_000  // 0.1 million steps
        } else {
            return 1.0
        }
    }
    
    private func updateSliderRange(for question: Question) {
        // Get the range from the question
        sliderRange = question.calculateRange()
        // Set initial guess
        currentGuess = Double(question.proposedValue)
    }
    
    private func heartsDisplay(lives: Int, total: Int = 3) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Text(index < lives ? "❤️" : "💔")
                    .font(.title2)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let question = gameManager.currentQuestion {
                // Stats bar - fixed below nav bar
                HStack {
                    heartsDisplay(lives: gameManager.lives)
                    Spacer()
                    Text("Score: ")
                        .fontWeight(.bold) +
                    Text("\(gameManager.score)")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Content area
                VStack {
                    Text(question.text)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Main content area with slider
                    GeometryReader { geometry in
                        HStack(spacing: 20) {
                            // Left side spacing for iPad
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Spacer()
                                    .frame(width: geometry.size.width * 0.2)
                            }
                            
                            // Current guess display
                            VStack(spacing: 4) {
                                Text(formatLargeNumber(currentGuess, isYear: question.isYearQuestion))
                                    .font(.title)
                                    .monospacedDigit()
                                Text(question.isYearQuestion ? "" : question.units)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120)
                            
                            // Slider
                            Slider(value: $currentGuess,
                                   in: sliderRange,
                                   step: getSliderStep(for: currentGuess),
                                   onEditingChanged: { editing in 
                                       isDragging = editing
                                       if !editing {
                                           // When dragging ends, snap to nearest increment
                                           if currentGuess >= 1_000_000_000 {
                                               // Snap to nearest 0.1 billion
                                               let billions = (currentGuess / 1_000_000_000).rounded(to: 1)
                                               currentGuess = billions * 1_000_000_000
                                           } else if currentGuess >= 1_000_000 {
                                               // Snap to nearest 0.1 million
                                               let millions = (currentGuess / 1_000_000).rounded(to: 1)
                                               currentGuess = millions * 1_000_000
                                           }
                                       }
                                   }
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 
                                   geometry.size.height * 0.7 : // iPad height
                                   geometry.size.height * 0.6)  // iPhone height
                            .disabled(lastGuessResult != nil)
                            
                            // Right side spacing for iPad
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Spacer()
                                    .frame(width: geometry.size.width * 0.2)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // Results area with fixed height
                    VStack {
                        if let result = lastGuessResult {
                            HStack {
                                Text("Correct Answer:")
                                    .foregroundColor(.black)
                                if question.isYearQuestion {
                                    Text(String(result.correctAnswer))
                                        .font(.title3.bold())
                                        .foregroundColor(.black)
                                } else {
                                    Text("\(formatLargeNumber(Double(result.correctAnswer), isYear: question.isYearQuestion)) \(question.units)")
                                        .font(.title3.bold())
                                        .foregroundColor(.black)
                                }
                            }
                            
                            let accuracyText = result.guessedTooLow ? 
                                String(format: "-%.1f", 100.0 - abs(result.accuracyPercentage)) :
                                String(format: "%.1f", result.accuracyPercentage)
                            HStack(spacing: 4) {
                                Text("Accuracy:")
                                    .foregroundColor(.black)
                                Text("\(accuracyText)%")
                                    .foregroundColor(result.pointsEarned > 0 ? .green : .red)
                            }
                            
                            HStack(spacing: 4) {
                                Text("Points Earned:")
                                    .foregroundColor(.black)
                                Text("\(result.pointsEarned)")
                                    .foregroundColor(result.pointsEarned > 0 ? .green : .red)
                            }
                            
                            if result.guessedTooLow {
                                Text("Guessed too low! You lose a life 💔").foregroundColor(.red)
                            } else if result.lostLife {
                                if question.isYearQuestion {
                                    Text("Guessed too far in the future! You lose a life 💔").foregroundColor(.red)
                                } else {
                                    Text("Guessed too high! You lose a life 💔").foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .frame(height: 120, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    // Button section
                    VStack(spacing: 16) {
                        if gameManager.lives <= 0 {
                            HStack(spacing: 8) {
                                Text("Game Over!")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .fontWeight(.bold)
                                Text("•")
                                    .foregroundColor(.gray)
                                Text("Final Score: \(gameManager.score)")
                                    .font(.title2)
                            }
                            
                            if gameManager.isNewHighScore {
                                VStack(spacing: 8) {
                                    Text("🏆 New High Score! 🏆")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                        .fontWeight(.bold)
                                    Text("\(gameManager.score) points")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            HStack(spacing: 20) {
                                Button("Play Again") {
                                    gameManager.startNewGame()
                                    lastGuessResult = nil
                                }
                                .font(.title2)
                                .padding()
                                .frame(minWidth: 140)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                
                                Button("Main Menu") {
                                    gameManager.goToHome()
                                }
                                .font(.title2)
                                .padding()
                                .frame(minWidth: 140)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        } else {
                            Button(lastGuessResult != nil ? "Next Question" : "Submit Guess") {
                                if lastGuessResult != nil {
                                    lastGuessResult = nil
                                    gameManager.nextQuestion()
                                    if let newQuestion = gameManager.currentQuestion {
                                        updateSliderRange(for: newQuestion)
                                    }
                                } else {
                                    lastGuessResult = gameManager.submitGuess(Int(currentGuess))
                                    if gameManager.lives <= 0 {
                                        // Show game over message in results area
                                        if let result = lastGuessResult {
                                            // Keep existing result but add game over message
                                            lastGuessResult = result
                                        }
                                    }
                                }
                            }
                            .font(.title2)
                            .padding()
                            .background(lastGuessResult != nil ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarTitle("Higher or Lower?", displayMode: .automatic)
        .onAppear {
            if let question = gameManager.currentQuestion {
                updateSliderRange(for: question)
            }
        }
    }
}

// Add extension for rounding to decimal places
extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
} 
