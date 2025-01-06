import SwiftUI

enum GameState {
    case home
    case playing
}

class GameManager: ObservableObject {
    @Published var gameState: GameState = .home
    @Published var lives = 3
    @Published var score = 0
    @Published var highScore = 0
    @Published var currentQuestion: Question?
    
    let questions = [
        Question(text: "How many floors are in the Empire State Building?", correctAnswer: 102, units: "floors"),
        Question(text: "What is the height of Mount Everest?", correctAnswer: 29029, units: "feet"),
        Question(text: "How many bones are in the human body?", correctAnswer: 206, units: "bones")
    ]
    
    func startNewGame() {
        lives = 3
        score = 0
        nextQuestion()
        gameState = .playing
    }
    
    func nextQuestion() {
        currentQuestion = questions.randomElement()
    }
    
    func submitGuess(_ guess: Int) -> GuessResult {
        guard let question = currentQuestion else { 
            return GuessResult(guess: 0, correctAnswer: 0, pointsEarned: 0, accuracyPercentage: 0, lostLife: false, guessedTooLow: false)
        }
        
        let correctAnswer = question.correctAnswer
        let percentageDiff = abs(Double(guess - correctAnswer)) / Double(correctAnswer)
        let guessedTooLow = guess < correctAnswer
        let lostLife = percentageDiff > 0.2 || guessedTooLow
        let points = calculateScore(guess: guess, correctAnswer: correctAnswer)
        let accuracyPercentage = (1.0 - percentageDiff) * 100
        
        if lostLife {
            lives -= 1
            if lives <= 0 {
                // Update high score if current score is higher
                if score > highScore {
                    highScore = score
                }
            }
        }
        
        score += points
        
        return GuessResult(
            guess: guess,
            correctAnswer: correctAnswer,
            pointsEarned: points,
            accuracyPercentage: accuracyPercentage,
            lostLife: lostLife,
            guessedTooLow: guessedTooLow
        )
    }
    
    private func calculateScore(guess: Int, correctAnswer: Int) -> Int {
        // Return 0 points if guess is below correct answer
        if guess < correctAnswer {
            return 0
        }
        
        let difference = abs(Double(guess - correctAnswer))
        let percentageOff = difference / Double(correctAnswer)
        
        if percentageOff >= 0.2 {
            return 0
        }
        
        let score = 100.0 * exp(-25.0 * percentageOff)
        return Int(round(score))
    }
    
    func goToHome() {
        gameState = .home
    }
}

struct GuessResult {
    let guess: Int
    let correctAnswer: Int
    let pointsEarned: Int
    let accuracyPercentage: Double
    let lostLife: Bool
    let guessedTooLow: Bool
} 