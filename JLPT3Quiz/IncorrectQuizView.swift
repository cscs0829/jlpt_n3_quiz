//
//  IncorrectQuizView.swift
//  JLPT3Quiz
//
//  Created by 박창선 on 3/22/25.
//

import SwiftUI

struct IncorrectQuizView: View {
    @Environment(\.presentationMode) var presentationMode
    let incorrectQuizItems: [QuizItem]

    var body: some View {
        VStack {
            Text("틀린 단어장")
                .font(.title)
                .padding()

            if incorrectQuizItems.isEmpty {
                Text("틀린 문제가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(incorrectQuizItems, id: \.kanji) { item in
                    VStack(alignment: .leading) {
                        Text(item.kanji)
                            .font(.headline)
                        Text(item.hiragana)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(item.meaning)
                    }
                }
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("돌아가기")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
