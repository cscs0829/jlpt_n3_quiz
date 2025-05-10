// PersistentIncorrectWordStore.swift
import SwiftUI
import Combine

class PersistentIncorrectWordStore: ObservableObject {
    @Published var incorrectKanjis: [String] {
        didSet {
            saveIncorrectKanjis()
        }
    }

    private let userDefaultsKey = "persistentIncorrectKanjis" // 영구 오답노트용 키

    init() {
        self.incorrectKanjis = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        print("[PersistentStore] 로드된 영구 오답 Kanji: \(self.incorrectKanjis)")
    }

    func addKanji(_ kanji: String) {
        if !incorrectKanjis.contains(kanji) {
            incorrectKanjis.append(kanji)
            // print("[PersistentStore] Kanji 추가: \(kanji). 현재 목록: \(self.incorrectKanjis)")
        }
    }

    func removeKanji(_ kanji: String) {
        incorrectKanjis.removeAll { $0 == kanji }
        // print("[PersistentStore] Kanji 제거: \(kanji). 현재 목록: \(self.incorrectKanjis)")
    }

    func containsKanji(_ kanji: String) -> Bool {
        incorrectKanjis.contains(kanji)
    }

    private func saveIncorrectKanjis() {
        UserDefaults.standard.set(incorrectKanjis, forKey: userDefaultsKey)
        print("[PersistentStore] 영구 오답 Kanji 저장됨: \(self.incorrectKanjis)")
    }

    // 저장된 Kanji 목록으로부터 QuizItem 객체 배열을 가져오는 헬퍼 함수
    func getIncorrectQuizItems() -> [QuizItem] {
        let allQuizItems = loadQuizData() // QuizData.swift의 함수
        return allQuizItems.filter { incorrectKanjis.contains($0.kanji) }
    }
}
