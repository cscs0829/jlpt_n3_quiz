// MainButtonModifier.swift
import SwiftUI

struct MainButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue) // 기본 버튼 색상
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 3)
    }
}
