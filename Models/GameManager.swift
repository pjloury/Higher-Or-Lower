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
    
    private var questions: [Question] = []
    private var unusedQuestions: [Question] = []  // Track questions not yet used in this session
    
    init() {
        loadQuestionsFromCSV()
    }
    
    private func loadQuestionsFromCSV() {
        // Try multiple methods to find the file
        var fileURL: URL?
        
        // Method 1: Try finding in Data subdirectory
        if let url1 = Bundle.main.url(forResource: "holdb", withExtension: "csv", subdirectory: "Data") {
            fileURL = url1
            print("Found file using method 1 (subdirectory)")
        }
        // Method 2: Try finding directly in bundle
        else if let url2 = Bundle.main.url(forResource: "holdb", withExtension: "csv") {
            fileURL = url2
            print("Found file using method 2 (direct)")
        }
        // Method 3: Try constructing URL from path
        else if let path = Bundle.main.path(forResource: "holdb", ofType: "csv") {
            fileURL = URL(fileURLWithPath: path)
            print("Found file using method 3 (path)")
        }
        
        guard let url = fileURL else {
            print("Error: Could not find holdb.csv")
            print("Bundle path:", Bundle.main.bundlePath)
            if let resourcePath = Bundle.main.resourcePath {
                print("\nResources in bundle at \(resourcePath):")
                let enumerator = FileManager.default.enumerator(atPath: resourcePath)
                while let filePath = enumerator?.nextObject() as? String {
                    print("  \(filePath)")
                }
            }
            return
        }
        
        print("Found CSV file at URL:", url)
        
        // Try to read the file contents
        do {
            // Try reading with different encodings if UTF8 fails
            let encodings: [String.Encoding] = [.utf8, .ascii, .isoLatin1]
            var content: String?
            var usedEncoding: String.Encoding?
            
            for encoding in encodings {
                do {
                    content = try String(contentsOf: url, encoding: encoding)
                    usedEncoding = encoding
                    break
                } catch {
                    print("Failed to read with encoding \(encoding): \(error)")
                    continue
                }
            }
            
            guard let fileContent = content else {
                print("Failed to read file with any encoding")
                return
            }
            
            print("Successfully read file contents with encoding: \(usedEncoding?.description ?? "unknown")")
            print("First 200 characters of content:", String(fileContent.prefix(200)))
            
            let rows = fileContent.components(separatedBy: .newlines)
            print("Found \(rows.count) rows in CSV")
            
            if rows.count > 0 {
                print("Header row:", rows[0])
            }
            
            if rows.count > 1 {
                print("First data row:", rows[1])
            }
            
            // Skip the header row and empty rows
            for (index, row) in rows.dropFirst().enumerated() {
                guard !row.isEmpty else { continue }
                
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 3 else {
                    print("Row \(index + 1) has invalid number of columns:", columns)
                    continue
                }
                
                let fact = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let valueStr = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let unit = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Try to parse the value
                guard let value = Int(valueStr.replacingOccurrences(of: ",", with: "")) else {
                    print("Could not parse value '\(valueStr)' for fact: '\(fact)'")
                    continue
                }
                
//                // Skip years
//                guard unit.lowercased() != "year" else {
//                    print("Skipping year entry:", fact)
//                    continue
//                }
                
                let question = Question(
                    text: fact,
                    correctAnswer: value,
                    units: unit
                )
                questions.append(question)
            }
            
            print("Successfully loaded \(questions.count) questions")
            
            // Print first few questions as a sample
            for (index, question) in questions.prefix(3).enumerated() {
                print("Sample question \(index + 1):")
                print("  Text: \(question.text)")
                print("  Answer: \(question.correctAnswer)")
                print("  Units: \(question.units)")
            }
            
            // After successfully loading questions, initialize unusedQuestions
            unusedQuestions = questions
            
        } catch {
            print("Error reading file:", error)
            
            // Try to read file attributes
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                print("File attributes:", attributes)
            } catch {
                print("Could not read file attributes:", error)
            }
        }
    }
    
    func startNewGame() {
        lives = 3
        score = 0
        // Reset unused questions if we've used them all
        if unusedQuestions.isEmpty {
            unusedQuestions = questions
        }
        nextQuestion()
        gameState = .playing
    }
    
    func nextQuestion() {
        // If we've used all questions, reset the pool
        if unusedQuestions.isEmpty {
            print("All questions have been used, resetting question pool")
            unusedQuestions = questions
        }
        
        // Get a random index from unused questions
        let randomIndex = Int.random(in: 0..<unusedQuestions.count)
        currentQuestion = unusedQuestions[randomIndex]
        // Remove the selected question from unused questions
        unusedQuestions.remove(at: randomIndex)
        
        print("Questions remaining in pool: \(unusedQuestions.count) out of \(questions.count) total")
    }
    
    func submitGuess(_ guess: Int) -> GuessResult {
        guard let question = currentQuestion else { 
            return GuessResult(guess: 0, correctAnswer: 0, pointsEarned: 0, accuracyPercentage: 0, lostLife: false, guessedTooLow: false)
        }
        
        let correctAnswer = question.correctAnswer
        let guessedTooLow = guess < correctAnswer
        
        // Calculate accuracy differently for year questions
        let accuracyPercentage: Double
        if question.isYearQuestion {
            let currentYear = Calendar.current.component(.year, from: Date())
            let maxYear = min(currentYear, correctAnswer + 100)
            let totalRange = Double(maxYear - correctAnswer)
            let difference = abs(Double(guess - correctAnswer))
            accuracyPercentage = (1.0 - (difference / totalRange)) * 100
        } else {
            let percentageDiff = abs(Double(guess - correctAnswer)) / Double(correctAnswer)
            accuracyPercentage = (1.0 - percentageDiff) * 100
        }
        
        // For year questions, lose life if guessed too low or too far in the future
        // For other questions, lose life if too low or more than 20% off
        let lostLife: Bool
        if question.isYearQuestion {
            if guessedTooLow {
                lostLife = true  // Lose life for guessing before the event
            } else {
                // For year questions, lose life if guessed more than halfway through the available range
                let currentYear = Calendar.current.component(.year, from: Date())
                let maxYear = min(currentYear, correctAnswer + 100)
                let totalRange = Double(maxYear - correctAnswer)
                let difference = Double(guess - correctAnswer)
                let percentageOfRange = difference / totalRange
                lostLife = percentageOfRange >= 0.5
            }
        } else {
            let percentageDiff = abs(Double(guess - correctAnswer)) / Double(correctAnswer)
            lostLife = percentageDiff > 0.2 || guessedTooLow
        }
        
        let points = calculateScore(guess: guess, correctAnswer: correctAnswer)
        
        if lostLife {
            lives -= 1
            if lives <= 0 {
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
            return 0  // Always 0 points for guessing too low (before the event)
        }
        
        if let question = currentQuestion, question.isYearQuestion {
            let currentYear = Calendar.current.component(.year, from: Date())
            let maxYear = min(currentYear, correctAnswer + 100)
            let totalRange = Double(maxYear - correctAnswer)
            let difference = Double(guess - correctAnswer)
            let percentageOfRange = difference / totalRange
            
            // If the guess is more than halfway through the available range, return 0
            if percentageOfRange >= 0.5 {
                return 0
            }
            
            // Use exponential decay based on the percentage of the available range
            let score = 100.0 * exp(-5.0 * percentageOfRange)
            return Int(round(score))
        } else {
            let difference = abs(Double(guess - correctAnswer))
            let percentageOff = difference / Double(correctAnswer)
            
            if percentageOff >= 0.2 {
                return 0
            }
            
            let score = 100.0 * exp(-25.0 * percentageOff)
            return Int(round(score))
        }
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

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: Int
    let units: String
    
    var isYearQuestion: Bool {
        units.lowercased() == "year"
    }
    
    var proposedValue: Int {
        if isYearQuestion {
            let currentYear = Calendar.current.component(.year, from: Date())
            // For year questions, propose a random value between correct year and current year
            let minYear = correctAnswer
            let maxYear = min(currentYear, correctAnswer + 100) // Don't go more than 100 years ahead
            
            // Ensure valid range (minYear must be <= maxYear)
            if minYear <= maxYear {
                return Int.random(in: minYear...maxYear)
            } else {
                return minYear // If range is invalid, just return the correct year
            }
        } else {
            // For non-year questions, keep existing logic
            let minVariation = Double(correctAnswer) * 0.15  // Minimum 15% off
            let maxVariation = Double(correctAnswer) * 0.40  // Maximum 40% off
            let variation = Double.random(in: minVariation...maxVariation)
            
            // Randomly decide whether to add or subtract the variation
            let shouldAdd = Bool.random()
            let proposedValue = shouldAdd ? 
                Double(correctAnswer) + variation : 
                Double(correctAnswer) - variation
            
            return Int(proposedValue)
        }
    }
} 
