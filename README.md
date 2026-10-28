# 관상어용 스마트 어항 시스템 Frontend
## :file_folder: 프로젝트구조
lib
├── main.dart          # 앱 실행 및 초기 설정
├── api                # 서버 API 통신 관련 코드
├── models             # 데이터 모델 정의
├── screens            # 각 화면 및 페이지 UI
├── services           # 비즈니스 로직 및 외부 서비스 연동
└── widgets            # 재사용 가능한 UI 컴포넌트

## :rocket: 실행 방법

### 1. 프로젝트 클론
```bash
git clone https://github.com/ksw2003/ai_fishapp.git
cd ai_fishapp/
```
### 2. .env 파일 생성
프로젝트 루트 디렉토리에 .env 파일을 생성합니다.
```bash
cp env-template .env
```
### 3. .env 파일 생성
.env 파일에 다음 키 값들을 입력하세요:
카카오 로그인
- KAKAO_NATIVE_APP_KEY: 카카오 개발자 콘솔에서 발급받은 네이티브 앱 키
구글 로그인
- GOOGLE_KEY: 구글 개발자 콘솔에서 발급받은 네이티브 앱 키
AWS 서버 주소
- API_BASE_URL: AWS EC2에 배포된 백엔드 서버의 API 기본 주소
mediamtx 서버 주소
- VIDEO_BASE_URL: AWS EC2에 배포된 mewdiamtx 서버의 API 기본 주소

### 4. 앱 실행
환경 변수 설정이 완료되면 Flutter 앱을 실행할 수 있습니다.
```bash
flutter pub get
flutter run
```

환수 및 먹이 급여 제어 기능을 사용하려면 라즈베리 파이와 관련 하드웨어가 연결되어 있어야 합니다.
