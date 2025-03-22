//
//  QuizData.swift
//  JLPT3Quiz
//
//  Created by 박창선 on 3/22/25.
//

import Foundation

func loadQuizData() -> [QuizItem] {
    guard let fileLocation = Bundle.main.url(forResource: "jlpt3_quiz", withExtension: "json") else {
        fatalError("Could not find jlpt3_quiz.json in main bundle.")
    }

    do {
        let data = try Data(contentsOf: fileLocation)
        let decoder = JSONDecoder()
        let quizItems = try decoder.decode([QuizItem].self, from: data)
        return quizItems
    } catch {
        fatalError("Failed to decode jlpt3_quiz.json: \(error)")
    }
}
