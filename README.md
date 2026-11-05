# 관상어용 스마트 어항 시스템 Frontend
## :file_folder: 프로젝트구조
```text
├── api/                                          # 서버 API 통신 관련 코드
│   ├── api_client.dart                           # API 요청 및 응답 처리
│   ├── dairy_api.dart                            # 캘린더 API 통신
│   ├── motor_api.dart                            # 환수/급여 모터 API 통신
│   └── sensor_api.dart                           # 센서 데이터 API 통신
│
├── models/                                       # 데이터 모델 정의
│   ├── alert.dart                                # 알림 데이터 모델
│   ├── comment.dart                              # 커뮤니티 댓글 데이터 모델
│   ├── fishinfo.dart                             # 물고기 정보 데이터 모델
│   ├── post.dart                                 # 커뮤니티 게시글 데이터 모델
│   ├── post_detail.dart                          # 게시글 상세 정보 데이터 모델
│   └── sensor.dart                               # 센서 데이터 모델
│
├── screens/                                      # 앱 화면 및 페이지 UI
│   │
│   ├── community/                                # 커뮤니티 관련 화면
│   │   ├── community_detail_screen.dart          # 커뮤니티 게시글 상세 화면
│   │   ├── post_card.dart                        # 게시글 카드 UI 컴포넌트
│   │   └── post_writing_screen.dart              # 게시글 작성 화면
│   │
│   ├── iot/                                      # IoT 및 어항 관리 관련 화면
│   │   ├── alert_screen.dart                     # 알림 목록 화면
│   │   ├── daily_temp_detail_screen.dart         # 캘린더 수온 상세 정보 화면
│   │   ├── feeding_loading_screen.dart           # 먹이 급여 진행 화면
│   │   ├── fish_info_management_screen.dart      # 나의 물고기 정보 관리 화면
│   │   ├── live_video_screen.dart                # 실시간 어항 영상 화면
│   │   ├── water_change_loading_screen.dart      # 환수 진행 화면
│   │   └── water_temp_detail_screen.dart         # 수온 상세 정보 화면
│   │
│   ├── setting/                                  # 설정 및 프로필 관련 화면
│   │   ├── myfish_screen.dart                    # 나의 물고기 정보 관리 화면
│   │   └── profile_edit_screen.dart              # 프로필 수정 화면
│   │
│   ├── calendar_screen.dart                      # 어항 관리 기록 캘린더 화면
│   ├── chatbot_screen.dart                       # AI 챗봇 화면
│   ├── community_list_screen.dart                # 커뮤니티 게시글 목록 화면
│   ├── home_screen.dart                          # 메인 홈 화면
│   ├── make_profile_screen.dart                  # 프로필 생성 화면
│   ├── mypage_screen.dart                        # 마이페이지 화면
│   └── start_screen.dart                         # 앱 시작 화면
│
├── services/                                     # 비즈니스 로직 및 외부 서비스 연동
│   ├── alert_service.dart                        # 알림 데이터 조회
│   ├── community_service.dart                    # 커뮤니티 게시글 및 댓글 관련 기능
│   ├── daily_service.dart                        # 캘린더 어항 관리 데이터 조회
│   ├── fishinfo_service.dart                     # 나의 물고기 정보 조회 및 관리
│   ├── socket_service.dart                       # 실시간 소켓 통신 관리
│   ├── tank_service.dart                         # 어항 정보 및 제어 관련 기능
│   └── token_storage.dart                        # 사용자 인증 토큰 저장 및 관리
│
├── widgets/                                      # 재사용 가능한 UI 컴포넌트
│   ├── common_bottom_nav_bar.dart                # 공통 하단 네비게이션 바
│   ├── error_banner.dart                         # 오류 및 경고 메시지 표시 UI
│   ├── rotating_loading_icon.dart                # 회전형 로딩 아이콘
│   ├── tank_register.dart                        # 어항 등록 UI 컴포넌트
│   └── yes_or_no.dart                            # 예/아니요 선택 UI 컴포넌트
│
└── main.dart                                     # 앱 실행 및 초기 설정
```

## :rocket: 실행 방법

### :one: 프로젝트 클론
```bash
git clone https://github.com/ksw2003/ai_fishapp.git
cd ai_fishapp/
```
### :two: .env 파일 생성
프로젝트 루트 디렉토리에 .env 파일을 생성합니다.
```bash
cp env-template .env
```
### :three: .env 파일 생성
.env 파일에 다음 키 값들을 입력하세요:
```bash
KAKAO_NATIVE_APP_KEY= <KAKAO_NATIVE_APP_KEY>
GOOGLE_KEY= <GOOGLE_KEY>
API_BASE_URL= <BACKEND_SERVER_URL>
VIDEO_BASE_URL= <MEDIAMTX_SERVER_URL>
```

### :four: 앱 실행
환경 변수 설정이 완료되면 Flutter 앱을 실행할 수 있습니다.
```bash
flutter pub get
flutter run
```
