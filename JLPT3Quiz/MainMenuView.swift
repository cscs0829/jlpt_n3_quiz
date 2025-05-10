// MainMenuView.swift
import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var persistentStore: PersistentIncorrectWordStore // 주입된 Store 사용

    @State private var showResumeAlert = false
    @State private var savedQuestionIndexForAlert: Int = 0
    @State private var navigateToQuizView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("JLPT N3 단어 퀴즈")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top, 50)

                Image(systemName: "text.book.closed.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 20)

                VStack(spacing: 20) {
                    Button(action: {
                        let savedIndex = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
                        let quizWasCompleted = UserDefaults.standard.bool(forKey: "quizWasCompleted")
                        let quizData = loadQuizData()
                        let totalQuizItems = quizData.isEmpty ? 0 : quizData.count

                        if savedIndex > 0 && (totalQuizItems == 0 || savedIndex < totalQuizItems) && !quizWasCompleted {
                            self.savedQuestionIndexForAlert = savedIndex
                            self.showResumeAlert = true
                        } else {
                            prepareForNewQuizSession() // 함수 이름 변경 및 로직 수정
                            self.navigateToQuizView = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("퀴즈 시작하기")
                        }
                        .modifier(MainButtonModifier())
                    }
                    .background(
                        NavigationLink(destination: ContentView().environmentObject(persistentStore), isActive: $navigateToQuizView) { // ContentView에도 persistentStore 전달
                            EmptyView()
                        }
                    )

                    // "영구 오답노트 가기" 버튼
                    NavigationLink {
                        IncorrectQuizView(
                            incorrectQuizItems: persistentStore.getIncorrectQuizItems(), // Store에서 직접 가져옴
                            isPersistentList: true,
                            onDelete: { itemToDelete in
                                persistentStore.removeKanji(itemToDelete.kanji)
                                // @Published 프로퍼티 변경으로 View가 자동으로 업데이트 됩니다.
                            }
                        )
                        .environmentObject(persistentStore) // IncorrectQuizView도 필요시 접근 가능
                    } label: {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("영구 오답노트")
                        }
                        .modifier(MainButtonModifier())
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
                Text("버전 1.0.2")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .alert("이전 학습 기록", isPresented: $showResumeAlert) {
                Button("이어하기 (문제 \(savedQuestionIndexForAlert + 1)부터)") {
                    UserDefaults.standard.set(false, forKey: "quizWasCompleted")
                    self.navigateToQuizView = true
                }
                Button("새로 시작") {
                    prepareForNewQuizSession()
                    self.navigateToQuizView = true
                }
                Button("취소", role: .cancel) {}
            }
        }
        .navigationViewStyle(.stack)
    }

    // 새 "퀴즈 세션" 시작을 위해 UserDefaults의 퀴즈 진행 관련 값만 초기화
    func prepareForNewQuizSession() {
        UserDefaults.standard.set(0, forKey: "currentQuestionIndex")
        UserDefaults.standard.set(0, forKey: "currentScore")
        // UserDefaults.standard.removeObject(forKey: "incorrectKanjis") // 영구 오답노트는 여기서 지우지 않음!
        UserDefaults.standard.set(false, forKey: "quizWasCompleted")
        print("[MainMenuView] 새로운 퀴즈 세션을 위해 진행 상태 초기화.")
    }
    // loadIncorrectItemsFromUserDefaults() 함수는 이제 PersistentIncorrectWordStore에 있으므로 여기서 제거
}

// Preview는 이전과 동일
