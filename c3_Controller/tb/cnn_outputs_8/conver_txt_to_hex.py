def convert_txt_to_hex(input_file, output_file):
    with open(input_file, "r") as f:
        lines = f.readlines()

    with open(output_file, "w") as f:
        for line in lines:
            line = line.strip()
            if line == "":
                continue  # 빈 줄 건너뛰기
            num = int(line)  # 10진수 정수로 변환
            hex_str = f"{num:02X}"  # 16진수(대문자), 최소 4자리 (16bit)
            f.write(hex_str + "\n")

# 사용 예시
convert_txt_to_hex("layer_2_output.txt", "input.txt")
convert_txt_to_hex("layer_3_output.txt", "conv_out.txt")
convert_txt_to_hex("layer_4_output.txt", "mp_out.txt")
