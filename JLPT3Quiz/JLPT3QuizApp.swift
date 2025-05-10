// JLPT3QuizApp.swift
import SwiftUI

@main
struct JLPT3QuizApp: App {
    @StateObject private var persistentStore = PersistentIncorrectWordStore()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(persistentStore) // 모든 하위 뷰에서 접근 가능하도록 주입
        }
    }
}
