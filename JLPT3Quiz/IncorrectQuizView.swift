// IncorrectQuizView.swift
import SwiftUI

struct IncorrectQuizView: View {
    @Environment(\.presentationMode) var presentationMode
    var incorrectQuizItems: [QuizItem]
    var isPersistentList: Bool // 이 리스트가 영구 저장 리스트인지 여부
    var onDelete: ((QuizItem) -> Void)? // 영구 저장 리스트에서 아이템 삭제 시 호출될 클로저

    var body: some View {
        NavigationView {
            VStack {
                if incorrectQuizItems.isEmpty {
                    Text(isPersistentList ? "영구 오답노트에 저장된 문제가 없습니다." : "이번 세션에서 틀린 문제가 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(incorrectQuizItems, id: \.kanji) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.kanji)
                                        .font(.title2)
                                    Text(item.hiragana)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Text("뜻: \(item.meaning)")
                                        .font(.callout)
                                }
                                Spacer()
                                if isPersistentList { // 영구 오답노트일 때만 삭제 버튼 표시
                                    Button {
                                        onDelete?(item) // 삭제 클로저 호출
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // 리스트 행 내 버튼 스타일
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .listStyle(.insetGrouped) // 리스트 스타일 변경
                }

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("돌아가기")
                        .modifier(MainButtonModifier()) // MainButtonModifier 사용
                }
                .padding()
            }
            .navigationTitle(isPersistentList ? "영구 오답노트" : "이번 세션 오답")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
