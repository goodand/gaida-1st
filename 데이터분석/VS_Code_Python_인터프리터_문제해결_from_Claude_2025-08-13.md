# VS Code Python 인터프리터 문제 해결 정리

**작성자**: Claude  
**날짜**: 2025-08-13

## Problem 1: numpy import 실패
**문제**: Python 업데이트 후 numpy를 찾을 수 없음
- 현재 활성 Python: 3.13.6 (Homebrew)
- numpy 설치된 Python: 3.9.6 (시스템)
- 에러: `ModuleNotFoundError: No module named 'numpy'`

**원인**: 파이썬 버전 업데이트로 인한 패키지 경로 불일치

### Solution 1: 가상환경 생성 (`--system-site-packages`)
```bash
rm -rf .venv
python3 -m venv .venv --system-site-packages
```
VS Code에서 `.venv/bin/python` 선택

---

## Problem 2: da_utils 모듈 import 실패 (핵심 문제)
**문제**: `ModuleNotFoundError: No module named 'da_utils'`

**구체적 상황**:
1. **VS Code 파일 탐색기**: `da_utils` 폴더와 파일들이 **보임**
2. **실제 파일 시스템**: `da_utils` 폴더가 **비어있음** 또는 **존재하지 않음**
3. **중복 폴더 발견**: 
   - `./da_utils/` (비어있음, Python이 찾는 위치)
   - `./.vscode/da_utils/` (실제 파일들이 있는 위치)

**원인**: 
- 가상환경 설정 과정에서 잘못된 위치에 폴더 생성
- VS Code가 캐시된 정보로 파일이 있는 것처럼 표시
- Python은 현재 작업 디렉토리의 `./da_utils/`를 찾지만 실제 파일은 `./.vscode/da_utils/`에 존재

**디버깅 과정**:
```bash
find . -name "da_utils" -type d
# 결과: ./da_utils, ./.vscode/da_utils

ls -la ./da_utils/     # 비어있음
ls -la ./.vscode/da_utils/  # 파일들 존재
```

### Solution 2: 올바른 위치로 파일 복사
```bash
cp -r .vscode/da_utils/* ./da_utils/
```

---

## Problem 3: 패키지 의존성 부족
**문제**: scikit-learn 등 의존성 패키지 부족으로 인한 import 에러
**원인**: 
- pattern.py 파일 자체는 정상
- 내부에서 사용하는 라이브러리들이 가상환경에 미설치
- `sklearn` 패키지명이 deprecated → `scikit-learn` 사용 필요

### Solution 3: 필요한 패키지 설치
```bash
pip install scikit-learn pandas numpy matplotlib seaborn
```

**주의**: `pip install sklearn` ❌ → `pip install scikit-learn` ✅

---

## 최종 해결 상태
✅ numpy import 성공  
✅ da_utils 모듈 import 성공  
✅ 가상환경에서 패키지 정상 작동  
✅ 중복 폴더 구조 정리 완료  

## 핵심 학습 포인트
1. **가상환경 `--system-site-packages` 옵션**: 기존 시스템 패키지 접근 허용
2. **파일 위치 vs GUI 표시 불일치**: VS Code 캐시와 실제 파일 시스템 상태 차이 주의
3. **중복 폴더 구조 디버깅**: `find` 명령어로 동일 이름 폴더 위치 확인 필수
4. **패키지명 변경 추적**: deprecated 패키지명 확인 및 올바른 이름 사용
5. **커널 재시작**: 패키지 설치 후 Jupyter 커널 재시작 필수

## 트러블슈팅 체크리스트
- [ ] Python 인터프리터 버전 확인
- [ ] 패키지 설치 위치와 실행 환경 일치 확인
- [ ] 중복 폴더/파일 존재 여부 확인
- [ ] VS Code 파일 탐색기 vs 실제 파일 시스템 비교
- [ ] 의존성 패키지 설치 상태 확인
- [ ] 커널 재시작 수행