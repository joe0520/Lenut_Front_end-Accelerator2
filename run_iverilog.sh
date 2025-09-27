#!/bin/bash

# iVerilog 컴파일 및 시뮬레이션 스크립트
# CNN C1 Layer 테스트벤치 실행

echo "=== iVerilog CNN C1 Layer 테스트 시작 ==="

# 1. 디렉토리 확인
if [ ! -f "c1/image_pixels_0.txt" ]; then
    echo "ERROR: c1/image_pixels_0.txt 파일이 없습니다!"
    exit 1
fi

if [ ! -f "c1/layer_1_output.txt" ]; then
    echo "ERROR: c1/layer_1_output.txt 파일이 없습니다!"
    exit 1
fi

if [ ! -f "c1/c1_weights.hex" ]; then
    echo "ERROR: c1/c1_weights.hex 파일이 없습니다!"
    exit 1
fi

# 2. c1_weight_memory.v 파일에서 경로 수정 (백업 후)
echo "가중치 파일 경로를 상대 경로로 수정중..."
if [ -f "c1/c1_weight_memory.v" ]; then
    # 백업 생성
    cp c1/c1_weight_memory.v c1/c1_weight_memory.v.backup

    # 절대 경로를 상대 경로로 변경
    sed -i.tmp 's|"C:/VI_LFEA/LEFA/weights/c1_weights.hex"|"c1/c1_weights.hex"|g' c1/c1_weight_memory.v
    rm c1/c1_weight_memory.v.tmp
    echo "경로 수정 완료"
else
    echo "ERROR: c1/c1_weight_memory.v 파일이 없습니다!"
    exit 1
fi

# 3. 컴파일
echo "iVerilog로 컴파일 중..."
iverilog -g2012 \
    -o c1_layer_sim \
    -I c1 \
    -I test1/test1.srcs/sources_1/new \
    c1_layer_iverilog_tb.v \
    c1/convolution_PU_improved.v \
    c1/in_line_controller.sv \
    c1/c1_weight_memory.v \
    test1/test1.srcs/sources_1/new/c1_layer_top.v

# 컴파일 결과 확인
if [ $? -ne 0 ]; then
    echo "ERROR: 컴파일 실패!"
    echo "백업 파일을 복원합니다..."
    mv c1/c1_weight_memory.v.backup c1/c1_weight_memory.v
    exit 1
fi

echo "컴파일 성공!"

# 4. 시뮬레이션 실행
echo "시뮬레이션 실행 중..."
echo "이 과정은 몇 분 정도 소요될 수 있습니다..."

# VCD 파일 생성을 위한 환경변수 설정
export IVERILOG_DUMPER=vcd

# 시뮬레이션 실행
vvp c1_layer_sim

# 5. 결과 확인
echo ""
echo "=== 시뮬레이션 완료 ==="

if [ -f "dump.vcd" ]; then
    echo "VCD 파일이 생성되었습니다: dump.vcd"
    echo "GTKWave로 파형 확인: gtkwave dump.vcd"
fi

# 6. 정리
echo "임시 파일 정리 중..."
rm -f c1_layer_sim

# 백업 파일 복원
if [ -f "c1/c1_weight_memory.v.backup" ]; then
    mv c1/c1_weight_memory.v.backup c1/c1_weight_memory.v
    echo "원본 파일 복원 완료"
fi

echo "=== 테스트 완료 ==="