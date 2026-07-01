# BrainEnglish — 개발 진행 현황

> 뇌과학 기반 영어 리마인더 앱 (한국 초등생 대상)  
> 마지막 업데이트: 2026-07-01

---

## 앱 컨셉 요약

학교·학원·원서에서 이미 배운 내용을 **캡처해서 뇌과학적으로 반복**하는 앱.
직접 영어를 가르치지 않는다 — "복습 유틸리티".

| 핵심 포인트 | 내용 |
|---|---|
| 타깃 | 한국 초등학생 (부모가 설치/관리) |
| 차별점 | 본인 학습 교재 캡처 + 7종 퀴즈 + 뇌과학 인코딩 기법 |
| 배포 | 개인/가족 사이드로딩 (Apple Developer $99/년) |
| AI 의존도 | 최소화 — OCR/TTS는 온디바이스, AI는 주어·명사 치환 배치만 |

---

## 완료된 작업

### Phase 0 — 기획 (완료)

- [x] 앱 컨셉 확정: AI 대화 튜터 제거 → 리마인더 유틸리티로 재정의
- [x] **PRD.md v0.2** 작성 및 커밋
  - 캡처 3경로 (카메라/앨범/타이핑)
  - 7종 퀴즈 타입 설계
  - 뇌과학 인코딩 기법 (사전 테스트, 확장 인출, 이중 코딩, 인터리빙)
  - 주어·명사 치환 드릴: AI 배치 생성 + Dolch/Fry 단어 목록 폴백
  - TTS: iOS AVSpeechSynthesizer 뉴럴 보이스 (온디바이스, 무료)
  - 경쟁 분석 (CapWords vs BrainEnglish)
  - 수학 기능 → 로드맵으로 이동

### Phase 1 — Xcode 프로젝트 뼈대 (완료)

- [x] **Xcode 프로젝트 생성** (`BrainEnglish.xcodeproj`)
  - iOS 16+, SwiftUI, 외부 의존성 없음
- [x] **캡처 3경로 UI**
  - `CameraView` — UIImagePickerController 브릿지
  - `AlbumPickerView` — PHPickerViewController 브릿지
  - `TypingInputView` — 텍스트 직접 입력
  - `CaptureSelectionView` — 3경로 허브 + 최근 캡처 미리보기
- [x] **Vision OCR 처리기** (`VisionOCRProcessor`)
  - Apple Vision 프레임워크 (온디바이스, 무료)
  - `.accurate` 모드, `en-US`, `usesLanguageCorrection = true`
- [x] **데이터 모델 & 저장소**
  - `CapturedContent`: Codable 모델 + 문장 추출
  - `ContentStore`: JSON 파일 영속성, `@MainActor` ObservableObject
- [x] **콘텐츠 라이브러리** (`ContentLibraryView`)
  - 검색, 목록, 상세보기 (원본 이미지 + 문장 분리)
- [x] `Info.plist` 권한 설명 (카메라, 사진 라이브러리)

**커밋:** `a1b3042` → `claude/english-learning-app-kids-wxy8cc` → `main` merge

---

## 남은 작업

### Phase 2 — OCR 품질 & 캡처 UX

- [ ] OCR 결과 편집 화면 (인식 오류 수정 가능하게)
- [ ] 카메라 뷰에 가이드 오버레이 추가 (텍스트 영역 프레이밍)
- [ ] 이미지 전처리: 회전 보정, 대비 향상 (CIFilter)
- [ ] 다중 이미지 연속 캡처 (교과서 여러 페이지)

### Phase 3 — 7종 퀴즈 엔진

퀴즈 타입별 구현 (PRD 섹션 5 참조):

| 타입 | 설명 | 난이도 |
|---|---|---|
| Word Reorder | 단어 카드 순서 맞추기 | 쉬움 |
| Cloze | 빈칸 채우기 | 중간 |
| Spelling Scramble | 철자 재배열 | 중간 |
| Multiple Choice | 4지선다 | 쉬움 |
| Free Recall | 문장 통째로 쓰기 | 어려움 |
| Listening Dictation | 듣고 받아쓰기 | 중간 |
| Subject/Noun Sub | 주어·명사 치환 | 어려움 |

- [ ] 퀴즈 엔진 기반 구조 (`QuizSession`, `QuizQuestion` 모델)
- [ ] Word Reorder 퀴즈 UI 구현 (드래그 앤 드롭)
- [ ] Cloze 퀴즈 UI 구현
- [ ] Spelling Scramble UI 구현

### Phase 4 — 간격 반복 (Spaced Repetition)

- [ ] SM-2 알고리즘 구현 (`SpacedRepetitionEngine`)
- [ ] 복습 일정 계산 및 알림 스케줄링
- [ ] 학습 이력 저장 (정답률, 복습 날짜)
- [ ] "오늘의 복습" 홈 화면 위젯

### Phase 5 — TTS & 뉴럴 보이스

- [ ] AVSpeechSynthesizer 통합 (Enhanced/Premium 뉴럴 보이스)
- [ ] Listening Dictation 퀴즈에 TTS 연동
- [ ] 재생 속도 조절 UI (0.7x / 1.0x / 1.2x)
- [ ] (선택) ElevenLabs API 업그레이드 경로

### Phase 6 — AI 주어·명사 치환

- [ ] Claude API 통합 (배치 생성, 캡처 시점에 1회)
- [ ] 치환 단어 소스:
  1. 아이의 이미 캡처된 단어 목록
  2. Dolch Word List (220 단어) 내장
  3. Fry Instant Words (1000 단어) 내장
  4. 미국 학교 커리큘럼 기반 단어 (학년별)
- [ ] Subject/Noun Sub 퀴즈 UI 구현

### Phase 7 — 뇌과학 인코딩 기법 (캡처 시점)

- [ ] **사전 테스트 효과**: 캡처 직후 "이 내용 알아?" 사전 퀴즈
- [ ] **이중 코딩**: 캡처 텍스트에 이미지/이모지 연상 태그 추가
- [ ] **인터리빙**: 퀴즈 세션에 다른 날 학습 내용 섞기
- [ ] **정교화 질문**: "왜 그럴까?" 프롬프트 표시

### Phase 8 — 배포 & 폴리싱

- [ ] 앱 아이콘 디자인
- [ ] 온보딩 플로우 (처음 실행 시 사용법 안내)
- [ ] TestFlight 내부 배포 설정
- [ ] 사이드로딩 가이드 (부모용)

---

## 기술 스택

| 항목 | 선택 | 이유 |
|---|---|---|
| UI | SwiftUI | 선언적, 미래 지향적 |
| OCR | Apple Vision | 온디바이스, 무료, 프라이버시 |
| TTS | AVSpeechSynthesizer | 온디바이스, 무료, iOS 뉴럴 |
| 저장소 | JSON 파일 | 단순, CoreData 불필요 |
| 간격 반복 | SM-2 알고리즘 | 검증된 오픈 알고리즘 |
| AI | Claude API (배치) | 최소 호출, 비용 통제 가능 |
| 배포 | 사이드로딩 | App Store 심사 우회, 가족용 |

---

## 로컬 개발 시작 방법

```bash
# 클론
git clone -b claude/english-learning-app-kids-wxy8cc \
  https://github.com/jeromeyoon/brain_english.git \
  /Users/youngjin/projects/Brain_English

cd /Users/youngjin/projects/Brain_English

# Xcode에서 열기
open BrainEnglish.xcodeproj
```

> **주의**: 카메라 기능은 실기기에서만 동작 (시뮬레이터 불가)  
> Xcode → Product → Destination → 실제 iPhone 연결 후 빌드
