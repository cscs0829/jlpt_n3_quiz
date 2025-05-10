# 📘 JLPT3Quiz

**JLPT3Quiz**는 일본어 능력 시험(JLPT) N3 레벨의 **어휘 학습을 도와주는 iOS 퀴즈 앱**입니다. 퀴즈를 풀며 단어를 익히고, 오답을 복습하며 반복 학습할 수 있도록 설계되었습니다.

---

## 🚀 주요 기능

- **퀴즈 풀기:**  
  JLPT N3 수준의 어휘 퀴즈를 풀며 실력을 향상시킬 수 있습니다.

- **오답 노트:**  
  틀린 문제들을 복습할 수 있는 오답 노트 기능을 제공합니다.

- **진행 상황 저장:**  
  `UserDefaults`를 사용해 퀴즈 진행 상황 및 오답 데이터를 저장합니다.

---

## 🛠 기술 스택

- **Swift**
- **SwiftUI**
- **JSON (로컬 데이터 사용)**

---

## 🗂 파일 구조 및 설명

### 📱 앱 구성

| 파일명 | 설명 |
|--------|------|
| `JLPT3QuizApp.swift` | 앱의 진입점이며, SwiftUI의 `App` 구조체를 통해 앱 생명주기를 관리합니다. 앱 실행 시 `ContentView`를 표시합니다. |

### 🖼️ 뷰 (View) 구성

| 파일명 | 설명 |
|--------|------|
| `ContentView.swift` | 메인 화면. 퀴즈 문제를 표시하고 정답 여부 확인, 사용자 입력 처리, 진행 상황을 관리합니다. |
| `IncorrectQuizView.swift` | 오답 노트 화면. `ContentView`에서 전달된 `incorrectQuizItems`를 리스트로 표시하여 복습할 수 있게 합니다. |

### 📦 데이터 처리

| 파일명 | 설명 |
|--------|------|
| `QuizData.swift` | `jlpt3_quiz.json` 파일로부터 데이터를 불러와 `QuizItem` 배열로 반환하는 `loadQuizData()` 함수를 포함합니다. |
| `QuizItem.swift` | 각 퀴즈 항목의 데이터 구조를 정의합니다. `Codable`을 채택하여 JSON 파싱을 지원합니다. |
| `resource/jlpt3_quiz.json` | 실제 퀴즈 데이터가 저장된 JSON 파일로, 각 퀴즈 항목은 `kanji`, `hiragana`, `meaning`, `choices`를 포함합니다. |

### ✅ 테스트

| 파일명 | 설명 |
|--------|------|
| `JLPT3QuizTests.swift` | 로직 유닛 테스트. 기능이 제대로 동작하는지 검증합니다. |
| `JLPT3QuizUITests.swift` | UI 테스트. 사용자 인터페이스의 동작을 시뮬레이션하고 확인합니다. |
| `JLPT3QuizUITestsLaunchTests.swift` | 앱 실행 성능 테스트. 앱의 시작 시간을 측정합니다. |

---

## 📸 스크린샷

> (여기에 앱의 UI 스크린샷을 추가해주세요)

---


## 👤 저자

**박창선**

---

## 📬 문의

이메일 또는 GitHub Issues를 통해 문의해 주세요.
