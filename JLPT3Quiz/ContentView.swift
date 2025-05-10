// ContentView.swift
import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var persistentStore: PersistentIncorrectWordStore // 영구 오답노트 Store

    // 퀴즈 세션 상태
    @State private var quizItems: [QuizItem] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var score: Int = 0
    @State private var showRetryButtonForSession: Bool = false // 세션 오답 재시도 버튼 표시 여부
    @State private var currentChoices: [String] = []
    @State private var quizAlert: QuizAlert?

    // 이번 세션에서 틀린 문제들 (QuizItem 객체 직접 저장, 임시)
    @State private var sessionIncorrectItems: [QuizItem] = []
    @State private var showingSessionIncorrectSheet = false // 이번 세션 오답노트 표시 여부

    // 문제 이동 모달
    @State private var showingJumpToQuestionSheet = false

    var currentQuestion: QuizItem {
        guard !quizItems.isEmpty, quizItems.indices.contains(currentQuestionIndex) else {
            return quizItems.first ?? QuizItem(kanji: "로딩중...", hiragana: "", meaning: "", choices: [])
        }
        return quizItems[currentQuestionIndex]
    }

    var body: some View {
        VStack {
            if !quizItems.isEmpty {
                HStack {
                    Text("문제 \(currentQuestionIndex + 1) / \(quizItems.count)")
                        .font(.headline)
                    Spacer()
                    Text("점수: \(score)")
                        .font(.subheadline)
                }
                .padding([.horizontal, .top])

                Spacer()

                VStack {
                    Text(currentQuestion.hiragana)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(currentQuestion.kanji)
                        .font(.largeTitle)
                }
                .padding()

                ForEach(currentChoices, id: \.self) { choice in
                    Button(action: {
                        checkAnswer(selectedChoice: choice)
                    }) {
                        Text(choice)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // "영구 오답노트에 넣기/빼기" 버튼
                Button(action: {
                    togglePersistentIncorrectStatusForCurrentQuestion()
                }) {
                    Text(persistentStore.containsKanji(currentQuestion.kanji) ? "\(currentQuestion.kanji) 영구 오답노트에서 빼기" : "\(currentQuestion.kanji) 영구 오답노트에 넣기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(persistentStore.containsKanji(currentQuestion.kanji) ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

            } else {
                Text("퀴즈 데이터를 불러오고 있습니다...")
                    .padding()
                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: {
                    showingSessionIncorrectSheet = true
                }) {
                    Text("이번 회차 오답") // 버튼 텍스트 변경
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }

                if showRetryButtonForSession && !sessionIncorrectItems.isEmpty {
                    Button(action: {
                        retrySessionIncorrectQuestions()
                    }) {
                        Text("이번 회차 오답 다시풀기") // 버튼 텍스트 변경
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    saveQuizProgress() // 홈으로 가기 전 현재 퀴즈 진행 상황 저장
                    UserDefaults.standard.set(false, forKey: "quizWasCompleted")
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("홈으로")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingJumpToQuestionSheet = true
                } label: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .imageScale(.large)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingJumpToQuestionSheet) {
            JumpToQuestionView(quizItems: self.quizItems, currentQuestionIndexFromContent: $currentQuestionIndex)
        }
        // "이번 세션 오답 보기"를 위한 sheet
        .sheet(isPresented: $showingSessionIncorrectSheet) {
            IncorrectQuizView(
                incorrectQuizItems: self.sessionIncorrectItems, // 세션 오답 목록 전달
                isPersistentList: false, // 영구 목록 아님 (삭제 기능 없음)
                onDelete: nil
            )
        }
        .onAppear {
            loadQuizSessionData()
        }
        .onChange(of: currentQuestionIndex) { newIndex in
            saveQuizProgress()
            if quizItems.indices.contains(newIndex) {
                 currentChoices = quizItems[newIndex].choices.shuffled()
            } else if !quizItems.isEmpty {
                currentChoices = quizItems[0].choices.shuffled()
            }
        }
        .onChange(of: score) { _ in
            saveQuizProgress()
        }
        // incorrectKanjis에 대한 .onChange는 PersistentIncorrectWordStore가 담당하므로 ContentView에서 제거
        .alert(item: $quizAlert) { alertType in
            switch alertType {
            case .quizResult(let message):
                let isLastQuestion = !quizItems.isEmpty && currentQuestionIndex >= quizItems.count - 1
                return Alert(
                    title: Text("결과"),
                    message: Text(message),
                    primaryButton: .default(Text(isLastQuestion ? "결과 보기" : "다음 문제")) {
                        nextQuestion() // 다음 문제로 이동 또는 퀴즈 종료 처리
                    },
                    secondaryButton: .cancel()
                )
            case .itemStatusChanged(let message):
                return Alert(title: Text("알림"), message: Text(message), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    // 퀴즈 세션 데이터 로드 (이어하기 또는 새로 시작)
    func loadQuizSessionData() {
        let loadedItems = loadQuizData().shuffled() // 항상 새 퀴즈 아이템 목록을 섞음
        self.quizItems = loadedItems
        self.sessionIncorrectItems.removeAll() // 새 세션 시작 시 세션 오답 목록 초기화

        let quizWasCompleted = UserDefaults.standard.bool(forKey: "quizWasCompleted")
        let savedIndex = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
        let savedScore = UserDefaults.standard.integer(forKey: "currentScore")

        if quizWasCompleted { // 이전 퀴즈 세션이 '완료'된 경우, 새 세션은 처음부터 시작
            self.currentQuestionIndex = 0
            self.score = 0
            UserDefaults.standard.set(false, forKey: "quizWasCompleted") // 새 세션은 '미완료'
        } else { // 이전 퀴즈 세션을 이어가는 경우 (또는 앱 첫 실행)
            self.currentQuestionIndex = (savedIndex < loadedItems.count && savedIndex >= 0 && !loadedItems.isEmpty) ? savedIndex : 0
            self.score = savedScore
        }
        
        // currentQuestionIndex 유효성 검사
        if !loadedItems.isEmpty {
            self.currentQuestionIndex = min(max(0, self.currentQuestionIndex), loadedItems.count - 1)
        } else {
            self.currentQuestionIndex = 0; self.score = 0
        }

        self.showRetryButtonForSession = !self.sessionIncorrectItems.isEmpty // 세션 오답에 따라 결정

        if !loadedItems.isEmpty && loadedItems.indices.contains(self.currentQuestionIndex) {
            self.currentChoices = quizItems[self.currentQuestionIndex].choices.shuffled()
        } else if !loadedItems.isEmpty {
            self.currentChoices = loadedItems[0].choices.shuffled()
        } else {
            self.currentChoices = []
        }
        saveQuizProgress() // 초기 상태 저장
        print("[ContentView] 퀴즈 세션 데이터 로드 완료. Index: \(self.currentQuestionIndex), Score: \(self.score)")
    }

    // 현재 퀴즈 진행 상황(문제 번호, 점수) 저장
    func saveQuizProgress() {
        UserDefaults.standard.set(currentQuestionIndex, forKey: "currentQuestionIndex")
        UserDefaults.standard.set(score, forKey: "currentScore")
        print("[ContentView] 퀴즈 진행 상황 저장 - Index: \(currentQuestionIndex), Score: \(score)")
    }

    func checkAnswer(selectedChoice: String) {
        guard !quizItems.isEmpty, quizItems.indices.contains(currentQuestionIndex) else { return }
        let currentQ = currentQuestion // 재사용을 위해 변수 할당
        let isCorrect = selectedChoice == currentQ.meaning

        if isCorrect {
            score += 1
            quizAlert = .quizResult("정답입니다!")
        } else {
            var message = "오답입니다."
            // "이번 세션 오답노트"에 추가
            if !sessionIncorrectItems.contains(where: { $0.kanji == currentQ.kanji }) {
                sessionIncorrectItems.append(currentQ)
            }
            self.showRetryButtonForSession = true // 세션 오답이 생겼으므로 재시도 버튼 표시
            quizAlert = .quizResult(message)
        }
    }

    // "영구 오답노트"에 현재 문제를 추가하거나 제거하는 함수
    func togglePersistentIncorrectStatusForCurrentQuestion() {
        guard !quizItems.isEmpty, quizItems.indices.contains(currentQuestionIndex) else { return }
        let kanji = currentQuestion.kanji
        if persistentStore.containsKanji(kanji) {
            persistentStore.removeKanji(kanji)
            quizAlert = .itemStatusChanged("\(kanji)가 영구 오답노트에서 제거되었습니다.")
        } else {
            persistentStore.addKanji(kanji)
            quizAlert = .itemStatusChanged("\(kanji)가 영구 오답노트에 추가되었습니다.")
        }
    }

    func nextQuestion() {
        guard !quizItems.isEmpty else {
            quizAlert = .quizResult("퀴즈가 없습니다.")
            return
        }
        if currentQuestionIndex < quizItems.count - 1 {
            currentQuestionIndex += 1 // .onChange에서 saveQuizProgress 호출
        } else {
            // 현재 퀴즈 세트의 모든 문제를 푼 경우
            UserDefaults.standard.set(true, forKey: "quizWasCompleted") // 이 퀴즈 "세션" 완료
            saveQuizProgress() // 최종 점수 및 상태 저장
            showRetryButtonForSession = !sessionIncorrectItems.isEmpty // 세션 오답 여전히 재시도 가능
            quizAlert = .quizResult("퀴즈가 종료되었습니다. 당신의 점수는 \(score)점 입니다.")
        }
    }

    // "이번 세션 오답" 문제들로 퀴즈를 다시 푸는 함수
    func retrySessionIncorrectQuestions() {
        if !sessionIncorrectItems.isEmpty {
            UserDefaults.standard.set(false, forKey: "quizWasCompleted") // 재시도 퀴즈는 '미완료'
            
            self.quizItems = sessionIncorrectItems.shuffled() // 현재 퀴즈 목록을 세션 오답 문제들로 교체
            self.sessionIncorrectItems.removeAll() // 재시도 하므로 현재 세션 오답 목록은 비움
            self.currentQuestionIndex = 0
            self.score = 0 // 점수 초기화
            self.showRetryButtonForSession = false // 재시도 중에는 이 버튼 숨김 (모든 세션 오답을 풀 때까지)
            if !self.quizItems.isEmpty {
                self.currentChoices = self.quizItems[0].choices.shuffled()
            }
            saveQuizProgress() // 새 재시도 퀴즈 상태 저장
            print("[ContentView] 이번 세션 오답 문제로 퀴즈 재시작.")
        } else {
            quizAlert = .itemStatusChanged("이번 세션에서 다시 풀 틀린 문제가 없습니다.")
        }
    }
    // getIncorrectItemsFromStorage 함수는 이제 ContentView에서 직접 사용하지 않음.
    // (영구 오답노트는 MainMenuView -> IncorrectQuizView(persistentStore) 에서,
    //  세션 오답노트는 ContentView -> IncorrectQuizView(sessionIncorrectItems) 에서 처리)
}
