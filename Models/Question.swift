import Foundation

//struct Question: Identifiable {
//    let id = UUID()
//    let text: String
//    let correctAnswer: Int
//    let units: String
//    
//    // Generate a proposed value that's 15-40% off from the correct answer
//    var proposedValue: Int {
//        let minVariation = Double(correctAnswer) * 0.15  // Minimum 15% off
//        let maxVariation = Double(correctAnswer) * 0.40  // Maximum 40% off
//        let variation = Double.random(in: minVariation...maxVariation)
//        
//        // Randomly decide whether to add or subtract the variation
//        let shouldAdd = Bool.random()
//        let proposedValue = shouldAdd ? 
//            Double(correctAnswer) + variation : 
//            Double(correctAnswer) - variation
//        
//        return Int(proposedValue)
//    }
//} 
