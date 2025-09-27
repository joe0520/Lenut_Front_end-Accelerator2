#!/bin/bash

# 간단한 iVerilog 테스트 - 라인 컨트롤러만 테스트

echo "=== 간단한 라인 컨트롤러 테스트 ==="

# 라인 컨트롤러만 컴파일
echo "라인 컨트롤러 컴파일 중..."
iverilog -g2012 \
    -o line_controller_sim \
    in_line_controller_tb.v \
    c1/in_line_controller.sv

if [ $? -ne 0 ]; then
    echo "ERROR: 컴파일 실패!"
    exit 1
fi

echo "컴파일 성공! 시뮬레이션 실행 중..."

# 시뮬레이션 실행
vvp line_controller_sim

# 정리
rm -f line_controller_sim

echo "=== 라인 컨트롤러 테스트 완료 ==="