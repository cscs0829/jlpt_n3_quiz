//
//  QuizItem.swift
//  JLPT3Quiz
//
//  Created by 박창선 on 3/22/25.
//

import Foundation

struct QuizItem: Codable {
    let kanji: String
    let hiragana: String
    let meaning: String
    let choices: [String]
}
