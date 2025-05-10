// JumpToQuestionView.swift
import SwiftUI

struct JumpToQuestionView: View {
    @Environment(\.presentationMode) var presentationMode
    let quizItems: [QuizItem]
    @Binding var currentQuestionIndexFromContent: Int

    @State private var selectedTempIndex: Int?

    var body: some View {
        NavigationView {
            VStack {
                if quizItems.isEmpty {
                    Text("표시할 문제 목록이 없습니다.")
                        .padding()
                } else {
                    List { // selection 바인딩 직접 사용
                        ForEach(quizItems.indices, id: \.self) { index in
                            HStack {
                                Text("문제 \(index + 1):")
                                    .font(.headline)
                                Text(quizItems[index].kanji)
                                    .fontWeight(.medium)
                                Spacer()
                                if selectedTempIndex == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else if currentQuestionIndexFromContent == index && selectedTempIndex == nil {
                                     Image(systemName: "smallcircle.filled.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedTempIndex = index
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                HStack(spacing: 15) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(10)

                    Button("확인") {
                        if let selectedIndex = selectedTempIndex {
                            currentQuestionIndexFromContent = selectedIndex
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedTempIndex != nil ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(selectedTempIndex == nil)
                }
                .padding()
            }
            .navigationTitle("문제로 이동")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.selectedTempIndex = self.currentQuestionIndexFromContent
            }
        }
    }
}

struct JumpToQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItems = [
            QuizItem(kanji: "日本語", hiragana: "にほんご", meaning: "일본어", choices: ["일본어", "영어", "중국어", "한국어"]),
            QuizItem(kanji: "単語", hiragana: "たんご", meaning: "단어", choices: ["단어", "문장", "문법", "발음"])
        ]
        JumpToQuestionView(quizItems: sampleItems, currentQuestionIndexFromContent: .constant(0))
    }
}
