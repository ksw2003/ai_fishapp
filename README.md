# 관상어용 스마트 어항 시스템
IOT+Node.js+AI 기반 어항 관리 시스템

## 프로젝트 소개
~~한 것입니다.

## 멤버 구성
|개발자|기능 담당|
|---|---|
|김서원|IoT기능 개발,프론트엔드 UI개발|
|이다경|IoT기능 개발, 물고기 행동 분석 AI개발 및 AI서버 담당|
|유승엽|백엔드 서버 개발,프론트엔드 UI개발 보조|

## 개발 환경
|구분|기술 스택|
|---|---|
|프론트 엔드(모바일)|Dart,flutter|
|백엔드(서버)|javascript,node.js,express.js|
|DataBase/ORM|MySQL 8.0, sequelize|
|인증|JWT,kakao Oauth 2.0,google Oauth 2.0|
|실시간 통신|Websocket(ws)|
|실시간 스트리밍|MediaMTX,RTSP,WebRTC|
|AI서버|Python,FastAPI|
|IOT|RaspberryPi,Python|
|인프라|AWS EC2,Docker,Docker Compose|
|버전 관리|git,github|

## 주요 기능
### 1. 로그인 <a href="login 깃허브 wifi 링크">상세보기</a>
-카카오 로그인
-구글 로그인

### 2. 회원가입 <a href="login 깃허브 wifi 링크">상세보기</a>
- 어항 시리얼 ID 검증
- 최고/최저 수온 설정
- 수질 설정

### 3. 어항 관리 <a href="login 깃허브 wifi 링크">상세보기</a>
- 라즈베리 파이 기반 수온/수질 측정
- socket 기반 원격 환수/급여
- 서버 기반 카메라 연동
- 서버 기반 AI 분석
- 수온/수질 이상시 알림

### 4. 캘린더 <a href="login 깃허브 wifi 링크">상세보기</a>
-날짜별 그날 수온/수질 확인
-날짜별 그날 환수/급여 여부 확인
-그날 최저/최고/평균 수온 확인

### 5. 커뮤니티 <a href="login 깃허브 wifi 링크">상세보기</a>
-글 작성/수정/삭제
-글에 태그, 사진 추가
-댓글 작성/수정/삭제
-댓글 추천 기능
-태그/검색어로 작성글 검색

### 6.AI챗봇 <a href="login 깃허브 wifi 링크">상세보기</a>
-gemini api 연동

### 7.마이페이지 <a href="login 깃허브 wifi 링크">상세보기</a>
-닉네임/프로필 사진 변경
-내 어항 물고기 등록
-로그아웃
