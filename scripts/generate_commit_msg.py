#!/usr/bin/env python3
import os
import sys
import subprocess
import re
from typing import Dict, List
import json

def get_diff_content(files: List) -> Dict:
    """스테이징된 파일들의 diff 내용을 가져옵니다."""
    diff_content = {}
    for file in files:
        try:
            # 파일의 diff 내용 가져오기
            diff = subprocess.check_output(
                ["git", "diff", "--cached", "--", file], 
                text=True,  # universal_newlines 대신 text만 사용
                encoding='utf-8',  # 명시적 인코딩 지정
                errors='replace',  # 인코딩 오류 처리
                stderr=subprocess.STDOUT
            )
            if diff:
                diff_content[file] = diff
        except subprocess.CalledProcessError:
            pass
    return diff_content

def generate_commit_message(diff_content: Dict):
    """변경 사항을 분석하여 커밋 타입과 메시지를 결정합니다."""
    
    # 결과를 저장할 리스트 초기화
    commit_data = {
        "length": 0,
        "items": []
    }

    # 파일 확장자와 경로 기반 분석
    for file, diff in diff_content.items():
        # 커밋 메시지 생성
        message = ""
        message += file + " change"

        # 메시지 구성
        commit_data["items"].append({
            "file": [file],
            "message": "feat: " + message
        })

        # length 증가
        commit_data["length"] += 1

    return commit_data

def request_openai(message):

    return


def main():
    """메인 함수"""
    # 스테이징된 파일 목록 가져오기
    staged_files = sys.argv[1].split() if len(sys.argv) >= 1 else []

    # 파일 변경 내용 가져오기
    diff_content = get_diff_content(staged_files)
    # 커밋 메시지 생성
    commit_message = generate_commit_message(diff_content)
    
    print(json.dumps(commit_message))
if __name__ == "__main__":
    main()