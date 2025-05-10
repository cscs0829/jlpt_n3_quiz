# JLPT N3 단어 퀴즈 (JLPT3Quiz)

## 📚 프로젝트 개요

**JLPT N3 단어 퀴즈**는 사용자가 JLPT N3 수준의 일본어 단어를 효과적으로 학습할 수 있도록 돕는 iOS 애플리케이션입니다. 퀴즈 형식을 통해 재미있게 단어를 익히고, 오답 노트를 활용하여 틀린 단어를 집중적으로 복습할 수 있습니다.

## ✨ 주요 기능

* **객관식 단어 퀴즈**: JSON 파일에서 로드된 JLPT N3 단어들로 객관식 퀴즈를 풀어보세요.
* **실시간 점수 확인**: 퀴즈를 푸는 동안 현재 점수를 확인할 수 있습니다.
* **진행 상황 저장 및 이어하기**: 앱을 종료해도 마지막으로 풀었던 문제부터 다시 시작할 수 있습니다.
* **오답 노트**:
    * **세션 오답 노트**: 현재 퀴즈 세션에서 틀린 문제들을 모아 보여줍니다.
    * **영구 오답 노트**: 중요하거나 자주 틀리는 단어를 선택하여 영구적으로 저장하고 관리할 수 있습니다.
* **오답 다시 풀기**: 세션 오답 노트에 있는 문제들만 모아 다시 풀어볼 수 있습니다.
* **문제 이동**: 전체 문제 목록을 보고 원하는 문제로 바로 이동할 수 있습니다.
* **SwiftUI 기반 UI**: 깔끔하고 직관적인 사용자 인터페이스를 제공합니다.

## 🖼️ 스크린샷 (앱 미리보기)

여기에 앱의 주요 화면 스크린샷을 추가하여 프로젝트를 시각적으로 보여줄 수 있습니다.
`screenshots` 폴더를 만들고 그 안에 이미지 파일을 넣어주세요.

| 메인 화면                                      | 퀴즈 화면                                     | 오답 노트                                      |
| :---------------------------------------------: | :--------------------------------------------: | :---------------------------------------------: |
| ![Simulator Screenshot - iPhone 16 Pro - 2025-05-10 at 17 56 39](https://github.com/user-attachments/assets/e1892a61-4e26-4d28-9942-b42fe04a83e5) | ![Simulator Screenshot - iPhone 16 Pro - 2025-05-10 at 17 56 57](https://github.com/user-attachments/assets/95d8c42a-a1d8-4a65-98f2-54862fef4b6e) | ![Simulator Screenshot - iPhone 16 Pro - 2025-05-10 at 17 56 48](https://github.com/user-attachments/assets/7001eb0c-10d4-40fa-8103-fe6b9ebad0d8)    |




## 🛠️ 구현 기술

* **언어**: Swift
* **UI 프레임워크**: SwiftUI
* **데이터 관리**:
    * 퀴즈 데이터: `resource/jlpt3_quiz.json` 파일 (한자, 히라가나, 뜻, 객관식 선택지 포함)
    * 사용자 진행 상황 (현재 문제 번호, 점수): `UserDefaults`
    * 영구 오답 데이터: `PersistentIncorrectWordStore` (ObservableObject 패턴, `UserDefaults`에 한자 목록 저장)
* **주요 UI 구성 요소 및 파일 설명**:
    * `JLPT3QuizApp.swift`: 앱의 메인 진입점, `PersistentIncorrectWordStore`를 환경 객체로 주입합니다.
    * `MainMenuView.swift`: 앱 시작 시 나타나는 메인 화면입니다. '퀴즈 시작하기', '영구 오답노트' 버튼을 제공하며, 이전 학습 기록이 있을 경우 이어하기 옵션을 제시합니다.
    * `ContentView.swift`: 실제 퀴즈가 진행되는 화면입니다. 문제, 선택지를 표시하고 정답을 확인합니다. 세션 오답 노트 보기, 영구 오답 추가/제거, 문제 이동 기능을 포함합니다.
    * `IncorrectQuizView.swift`: 오답 목록을 보여주는 화면입니다. 세션별 오답과 영구 오답을 구분하여 표시하며, 영구 오답 목록에서는 단어 삭제 기능을 제공합니다.
    * `JumpToQuestionView.swift`: 전체 문제 목록을 리스트 형태로 보여주고, 사용자가 특정 문제로 바로 이동할 수 있도록 합니다.
    * `QuizItem.swift`: 퀴즈 항목(한자, 히라가나, 뜻, 선택지)을 정의하는 `Codable` 데이터 모델입니다.
    * `QuizData.swift`: `jlpt3_quiz.json` 파일에서 퀴즈 데이터를 로드하는 유틸리티 함수를 포함합니다.
    * `PersistentIncorrectWordStore.swift`: 영구적으로 저장될 오답 한자 목록을 관리하는 `ObservableObject` 클래스입니다. `UserDefaults`를 사용하여 데이터를 저장하고 불러옵니다.
    * `MainButtonModifier.swift`: 앱 내 주요 버튼들의 스타일을 일관되게 적용하기 위한 SwiftUI `ViewModifier`입니다.
    * `QuizAlert.swift`: 퀴즈 결과(정답/오답)나 오답 노트 추가/제거 상태 변경 시 사용자에게 보여줄 알림을 정의하는 `Identifiable` Enum입니다.

## 📂 프로젝트 구조

프로젝트는 다음과 같은 주요 폴더 및 파일로 구성되어 있습니다:

JLPT3Quiz/<br>
├── 📁 App (애플리케이션 핵심 로직)<br>
│   ├── 📄 JLPT3QuizApp.swift              # 앱 진입점 및 환경 객체 설정<br>
│   ├── 📄 MainMenuView.swift              # 메인 메뉴 UI 및 로직<br>
│   └── 📄 ContentView.swift               # 퀴즈 진행 UI 및 핵심 로직<br>
│<br>
├── 📁 Views (화면 구성 요소)<br>
│   ├── 📄 IncorrectQuizView.swift         # 오답 노트 UI 및 로직<br>
│   └── 📄 JumpToQuestionView.swift        # 문제 이동 UI 및 로직<br>
│<br>
├── 📁 Models (데이터 모델)<br>
│   ├── 📄 QuizItem.swift                  # 퀴즈 항목 데이터 구조 정의<br>
│   └── 📄 QuizAlert.swift                 # 알림창 데이터 모델<br>
│<br>
├── 📁 Data & Store (데이터 관리)<br>
│   ├── 📄 QuizData.swift                  # JSON에서 퀴즈 데이터 로드<br>
│   └── 📄 PersistentIncorrectWordStore.swift # 영구 오답 데이터 관리 클래스<br>
│<br>
├── 📁 Utilities & Modifiers (유틸리티 및 UI 수정자)<br>
│   └── 📄 MainButtonModifier.swift        # 공통 버튼 스타일 정의<br>
│<br>
├── 📁 Resources (앱 리소스)<br>
│   ├── 📁 resource/<br>
│   │   └── 📄 jlpt3_quiz.json           # JLPT N3 단어 및 퀴즈 데이터<br>
│   ├── 📁 Assets.xcassets/                # 앱 아이콘, 색상 등 에셋<br>
│   └── 📁 Preview Content/<br>
│       └── 📁 Preview Assets.xcassets/    # SwiftUI 미리보기용 에셋<br>
│<br>
├── 📁 Tests (테스트 코드)<br>
│   ├── 📁 JLPT3QuizTests/                 # 유닛 테스트<br>
│   │   └── 📄 JLPT3QuizTests.swift<br>
│   └── 📁 JLPT3QuizUITests/               # UI 테스트<br>
│       ├── 📄 JLPT3QuizUITests.swift<br>
│       └── 📄 JLPT3QuizUITestsLaunchTests.swift<br>
└── 📄 JLPT3Quiz.xcodeproj                 # Xcode 프로젝트 파일 (또는 .xcworkspace)<br>


**주요 폴더 설명:**

* **App**: 애플리케이션의 생명주기 관리 및 최상위 뷰(메인 메뉴, 퀴즈 화면)를 포함합니다.
* **Views**: 사용자에게 보여지는 특정 화면들(오답 노트, 문제 이동 등)을 관리합니다.
* **Models**: 앱에서 사용되는 데이터의 구조(퀴즈 아이템, 알림창 정보 등)를 정의합니다.
* **Data & Store**: 퀴즈 데이터를 불러오거나, 사용자의 오답 정보를 저장하고 관리하는 로직을 담당합니다.
* **Utilities & Modifiers**: 앱 전반적으로 사용될 수 있는 보조 기능이나 UI 스타일을 정의합니다.
* **Resources**: 앱 실행에 필요한 정적 파일들(JSON 데이터, 이미지 에셋 등)을 포함합니다.
* **Tests**: 앱의 안정성을 보장하기 위한 유닛 테스트 및 UI 테스트 코드를 포함합니다.

## 🚀 실행 방법

1.  이 저장소를 로컬 환경에 클론(Clone)합니다.
2.  Xcode를 사용하여 `JLPT3Quiz.xcodeproj` (또는 `.xcworkspace`가 있다면 해당 파일)을 엽니다.
3.  원하는 iOS 시뮬레이터 또는 연결된 실제 iOS 기기를 선택합니다.
4.  Xcode 상단의 'Product' 메뉴에서 'Run'을 선택하거나 단축키 `Cmd + R`을 눌러 앱을 빌드하고 실행합니다.

## 🌱 향후 개선 사항 (선택)

* 다양한 JLPT 레벨(N1, N2, N4, N5)의 단어 퀴즈 추가
* 단어 검색 기능 구현
* 사용자 정의 단어장 기능 (직접 단어 추가/관리)
* 단어 발음 듣기 기능 (Text-to-Speech 활용)
* 앱 테마 변경 옵션 (예: 다크 모드 지원 강화)
* iCloud 동기화를 통한 여러 기기 간 오답 노트 및 진행 상황 공유
