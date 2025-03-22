import SwiftUI

enum QuizAlert: Identifiable {
    case quizResult(String)
    case addedToIncorrect
    case alreadyInIncorrect // 이미 틀린 단어장에 있는 경우를 위한 새로운 케이스
    
    var id: Int {
        switch self {
        case .quizResult: return 0
        case .addedToIncorrect: return 1
        case .alreadyInIncorrect: return 2
        }
    }
}

struct ContentView: View {
    @State private var quizItems: [QuizItem] = loadQuizData().shuffled()
    @State private var currentQuestionIndex: Int = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
    @State private var score = 0
    @State private var incorrectAnswers: [Int] = UserDefaults.standard.array(forKey: "incorrectAnswers") as? [Int] ?? []
    @State private var showRetry = false
    @State private var currentChoices: [String] = []
    @State private var incorrectQuizItems: [QuizItem] = []
    @State private var isShowingIncorrectQuiz = false
    @State private var quizAlert: QuizAlert?
    
    var currentQuestion: QuizItem {
        let index = min(currentQuestionIndex, quizItems.count - 1)
        return quizItems[index]
    }

    var body: some View {
        VStack {
            Text("문제 \(currentQuestionIndex + 1) / \(quizItems.count)")
                .font(.headline)
                .padding()

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

            if incorrectAnswers.contains(currentQuestionIndex) {
                Button(action: {
                    addIncorrectItem()
                }) {
                    Text("틀린 단어장에 넣기")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            Button(action: {
                isShowingIncorrectQuiz = true
            }) {
                Text("틀린 단어장에 가기")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            .alert(item: $quizAlert) { alert in
                switch alert {
                case .addedToIncorrect:
                    return Alert(title: Text("알림"), message: Text("틀린 단어장에 추가되었습니다!"), dismissButton: .default(Text("확인")))
                case .quizResult(let message):
                    return Alert(title: Text("결과"), message: Text(message), primaryButton: .default(Text("다음 문제")) {
                        nextQuestion()
                    }, secondaryButton: .cancel(Text("취소")))
                case .alreadyInIncorrect: // 새로운 케이스 추가
                    return Alert(title: Text("알림"), message: Text("이미 틀린 단어장에 있는 단어입니다!"), dismissButton: .default(Text("확인")))
                }
            }

            .sheet(isPresented: $isShowingIncorrectQuiz) {
                IncorrectQuizView(incorrectQuizItems: incorrectQuizItems)
            }

            if showRetry {
                Button(action: {
                    retryIncorrectQuestions()
                }) {
                    Text("틀린 문제 다시 풀기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            currentChoices = currentQuestion.choices.shuffled()
        }
        .onChange(of: currentQuestionIndex) { _ in
            currentChoices = currentQuestion.choices.shuffled()
            UserDefaults.standard.set(currentQuestionIndex, forKey: "currentQuestionIndex")
            UserDefaults.standard.set(incorrectAnswers, forKey: "incorrectAnswers")
        }
    }

    func checkAnswer(selectedChoice: String) {
        if selectedChoice == currentQuestion.meaning {
            score += 1
            quizAlert = .quizResult("정답입니다!")
        } else {
            incorrectAnswers.append(currentQuestionIndex)
            quizAlert = .quizResult("오답입니다.")
        }
    }

    func nextQuestion() {
        if currentQuestionIndex < quizItems.count - 1 {
            currentQuestionIndex += 1
        } else {
            showRetry = !incorrectAnswers.isEmpty
            quizAlert = .quizResult("퀴즈가 종료되었습니다. 당신의 점수는 \(score)점 입니다.")
        }
    }

    func retryIncorrectQuestions() {
        currentQuestionIndex = incorrectAnswers.removeFirst()
        if incorrectAnswers.isEmpty {
            showRetry = false
        }
    }

    func addIncorrectItem() {
        if incorrectQuizItems.contains(where: { $0.kanji == currentQuestion.kanji }) {
            quizAlert = .alreadyInIncorrect // 이미 있는 경우 알림 표시
        } else {
            incorrectQuizItems.append(currentQuestion)
            quizAlert = .addedToIncorrect
        }
    }
}
