import SwiftUI

struct GameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentGuess: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...1
    @State private var isDragging = false
    @State private var lastGuessResult: GuessResult?
    
    private func updateSliderRange(for question: Question) {
        let proposedValue = Double(question.proposedValue)
        let minValue = proposedValue * 0.5
        let maxValue = proposedValue * 1.5
        sliderRange = minValue...maxValue
        currentGuess = proposedValue
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
                    
                    
                    Spacer()
                    
                    // Slider section
                    HStack {
                        VStack(spacing: 4) {
                            Text("\(Int(currentGuess))")
                                .font(.title)
                                .monospacedDigit()
                            Text(question.units)
                                .font(.title3)
                        }
                        .frame(width: 120)
                        
                        Slider(value: $currentGuess,
                               in: sliderRange,
                               step: 1.0,
                               onEditingChanged: { editing in isDragging = editing }
                        )
                        .rotationEffect(.degrees(-90))
//                        .frame(height: UIScreen.main.bounds.height * 0.6)
                        .disabled(lastGuessResult != nil)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Results area with fixed height
                    VStack {
                        if let result = lastGuessResult {                            
                            Text("Correct Answer: \(result.correctAnswer)")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            
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
                                Text("Guessed too high! You lose a life 💔").foregroundColor(.red)
                            }
                        }
                    }
                    .frame(height: 120, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    Spacer()
                    
                    // Button section
                    VStack(spacing: 16) {  // Added VStack for two buttons when game is over
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
                            
                            if gameManager.score > gameManager.highScore {
                                Text("Congrats! New High Score!")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
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
