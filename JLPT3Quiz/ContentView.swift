//
//  ContentView.swift
//  JLPT3Quiz
//
//  Created by 박창선 on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var quizItems: [QuizItem] = loadQuizData().shuffled()
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var incorrectAnswers: [Int] = []
    @State private var showRetry = false
    @State private var currentChoices: [String] = []
    @State private var incorrectQuizItems: [QuizItem] = [] // 틀린 문제 저장 배열

    var currentQuestion: QuizItem {
        return quizItems[currentQuestionIndex]
    }

    var body: some View {
        VStack {
            Text("문제 \(currentQuestionIndex + 1) / \(quizItems.count)")
                .font(.headline)
                .padding()

            VStack {
                Text(currentQuestion.hiragana)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(currentQuestion.kanji)
                    .font(.largeTitle)
            }
            .padding()

            // 틀린 단어장에 넣기 버튼 추가
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
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("결과"), message: Text(alertMessage), primaryButton: .default(Text("다음 문제")) {
                nextQuestion()
            }, secondaryButton: .cancel(Text("취소")))
        }
    }

    func checkAnswer(selectedChoice: String) {
        if selectedChoice == currentQuestion.meaning {
            score += 1
            alertMessage = "정답입니다!"
        } else {
            incorrectAnswers.append(currentQuestionIndex)
            alertMessage = "오답입니다."
        }
        showAlert = true
    }

    func nextQuestion() {
        if currentQuestionIndex < quizItems.count - 1 {
            currentQuestionIndex += 1
        } else {
            showRetry = !incorrectAnswers.isEmpty
            alertMessage = "퀴즈가 종료되었습니다. 당신의 점수는 \(score)점 입니다."
            showAlert = true
        }
    }

    func retryIncorrectQuestions() {
        currentQuestionIndex = incorrectAnswers.removeFirst()
        if incorrectAnswers.isEmpty {
            showRetry = false
        }
    }

    func addIncorrectItem() {
        incorrectQuizItems.append(currentQuestion)
        // 여기에 틀린 단어장 저장 로직 추가 (예: UserDefaults, 파일 저장 등)
        print("틀린 단어장에 추가: \(currentQuestion.kanji)") // 확인용 출력
    }
}
