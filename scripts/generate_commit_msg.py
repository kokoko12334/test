#!/usr/bin/env python3
import os
import sys
import subprocess
import re

def get_diff_content(files):
    """스테이징된 파일들의 diff 내용을 가져옵니다."""
    diff_content = {}
    for file in files:
        try:
            # 파일의 diff 내용 가져오기
            diff = subprocess.check_output(
                ["git", "diff", "--cached", "--", file], 
                universal_newlines=True
            )
            if diff:
                diff_content[file] = diff
        except subprocess.CalledProcessError:
            pass
    return diff_content

def generate_commit_message(diff_content):
    """변경 사항을 분석하여 커밋 타입과 메시지를 결정합니다."""
    # 파일 확장자와 경로 기반 분석
    message = ""
    for file, diff in diff_content.items():
        message += file
        message += "\t"
        message += diff
    return "feat: " + message

def request_openai(message):

    return


def main():
    """메인 함수"""
    # 스테이징된 파일 목록 가져오기
    staged_files = sys.argv[1].split() if len(sys.argv) >= 1 else []
    if not staged_files:
        print("chore: 변경 사항 커밋")
        return
    
    # 파일 변경 내용 가져오기
    diff_content = get_diff_content(staged_files)
    # 커밋 메시지 생성
    commit_message = generate_commit_message(diff_content)
    
    print(commit_message)
if __name__ == "__main__":
    main()