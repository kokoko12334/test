#!/bin/bash

# ANSI 색상 코드
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 함수: 처리 과정 출력
print_step() {
  echo -e "${BLUE}==>${NC} ${CYAN}$1${NC}"
}

# 함수: 항목 출력
print_item() {
  echo -e "   ${GREEN}•${NC} $1"
}

# 함수: 경고 출력
print_warning() {
  echo -e "${YELLOW}경고:${NC} $1"
}

# 함수: 오류 출력
print_error() {
  echo -e "${RED}오류:${NC} $1"
}

# JSON 데이터 파싱
GENERATED_JSON="$1"

if [ -z "$GENERATED_JSON" ]; then
  print_error "JSON 데이터가 제공되지 않았습니다."
  exit 1
fi

# JSON 유효성 검사
if ! echo "$GENERATED_JSON" | jq . >/dev/null 2>&1; then
  print_error "유효하지 않은 JSON 형식입니다."
  exit 1
fi

# 항목 수 확인
COMMIT_COUNT=$(echo "$GENERATED_JSON" | jq -r '.length')

if [ "$COMMIT_COUNT" -lt 1 ]; then
  print_error "커밋할 항목이 없습니다."
  exit 1
fi

# 처리할 항목 표시
for ((i=0; i<COMMIT_COUNT; i++)); do
  FILES=$(echo "$GENERATED_JSON" | jq -r ".items[$i].file | join(\", \")")
  print_item "커밋 $((i+1)). ${FILES}\n"
done
print_step "총 ${COMMIT_COUNT}개의 커밋이 처리될 예정입니다"
read -p "⏎ 엔터를 누르면 커밋을 시작합니다..."


# 스테이지된 모든 변경사항 초기화
print_step "스테이지된 변경사항 초기화 중..."
git reset > /dev/null

# 각 커밋 처리
for ((i=0; i<COMMIT_COUNT; i++)); do
  # 파일 목록과 커밋 메시지 추출
  FILES_JSON=$(echo "$GENERATED_JSON" | jq -r ".items[$i].file")
  FILES_COUNT=$(echo "$FILES_JSON" | jq -r "length")
  MESSAGE=$(echo "$GENERATED_JSON" | jq -r ".items[$i].message")
  
  print_step "커밋 $((i+1))/$COMMIT_COUNT 처리 중..."
  
  # 각 파일 추가
  for ((j=0; j<FILES_COUNT; j++)); do
    FILE=$(echo "$FILES_JSON" | jq -r ".[$j]")
    print_item "파일 추가 중: $FILE"
    git add "$FILE"
    
    # 파일 추가 확인
    if ! git status --porcelain | grep -q "$FILE"; then
      print_warning "파일 '$FILE'을 스테이지에 추가하지 못했습니다."
    fi
  done
  
  # 변경사항 확인
  echo
  print_item "변경사항 요약:"
  git status --short
  echo
  
  # 커밋 수행
  print_item "커밋 메시지: $MESSAGE"
  git commit -m "$MESSAGE"
  
  # 커밋 성공 여부 확인
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} 커밋 완료: $MESSAGE"
  else
    print_error "커밋 실패: $MESSAGE"
  fi
  
  echo
done

print_step "모든 커밋이 완료되었습니다."
echo -e "${GREEN}총 ${COMMIT_COUNT}개의 커밋이 처리되었습니다.${NC}"