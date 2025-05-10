// QuizAlert.swift
import Foundation

enum QuizAlert: Identifiable {
    case quizResult(String)
    case itemStatusChanged(String)

    var id: String {
        switch self {
        case .quizResult(let msg):
            return "quizResult_\(msg.hashValue)_\(UUID())"
        case .itemStatusChanged(let msg):
            return "itemStatusChanged_\(msg.hashValue)_\(UUID())"
        }
    }
}
