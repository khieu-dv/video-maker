#!/bin/bash

# Thiết lập kích thước và tốc độ khung hình
WIDTH=1920
HEIGHT=1080
FPS=30
ulimit -n 4096


# Thời lượng hiển thị mỗi ảnh và hiệu ứng chuyển đổi
IMAGE_DURATION=5
TRANSITION_DURATION=1

# Tham số boolean để điều khiển việc hiển thị mô tả
SHOW_DESCRIPTIONS=true

# Tạo danh sách ảnh từ thư mục images
IMAGES=()
for img in images3/*.{jpg,jpeg,png}; do
    [[ -f "$img" ]] && IMAGES+=("$img")
done

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "Không tìm thấy ảnh trong thư mục images!"
    exit 1
fi

# Tạo mảng chứa mô tả cho từng ảnh
DESCRIPTIONS=(
  "Em là nắng khiến tim anh khẽ chao"
  "Ánh mắt ấy như ngàn vì sao lấp lánh"
  "Gió khẽ lay tà váy em dịu dàng"
  "Nụ cười em làm ngày anh rực rỡ"
  "Mắt em sâu như cả một vũ trụ"
  "Dáng em nghiêng, lòng anh nghiêng theo"
  "Tóc em bay, hồn anh cũng nhẹ trôi"
  "Em như thơ giữa đời thường cằn cỗi"
  "Chỉ một ánh nhìn, cả thế giới dịu êm"
  "Giọng em vang như bản tình ca lặng lẽ"
  "Đôi môi ấy như mùa xuân vừa hé"
  "Em dịu dàng như mây lướt ngang trời"
  "Chạm vào ánh mắt là chạm cả trời thương"
  "Em mang nỗi nhớ giấu trong từng bước nhẹ"
  "Giữa bao ánh sáng, em vẫn là bình minh"
  "Em lặng im, anh nghe lòng xao động"
  "Từng nhịp chân em là thơ lạc phố"
  "Áo em bay như sóng nhỏ giữa chiều"
  "Em là mộng, là mây, là men say"
  "Một lần gặp, trọn đời chẳng thể quên"
  "Em như khúc hát chưa từng ai viết"
  "Mỗi lần em cười, nỗi buồn tan biến"
  "Gần em một chút, đời bỗng dịu dàng"
  "Tình em như gió, không thấy mà say"
  "Đôi tay ấy như mùa thu dịu nhẹ"
  "Chạm khẽ trái tim, em khiến trời rung"
  "Em là bản tình ca anh chưa từng hát"
  "Làn da em – ánh trăng của đêm hè"
  "Vẻ đẹp ấy khiến thời gian dừng lại"
  "Mỗi dáng em đi là một vần thơ"
  "Trong mắt em là cả một mùa xuân"
  "Ngực em là gối mộng giữa thiên đàng"
  "Tình em như rượu, uống vào là nhớ"
  "Ánh nhìn em – tia nắng sớm tinh khôi"
  "Anh lạc lối trong hương em vô định"
  "Giữa biển người, em là hoàng hôn lặng"
  "Chút mơ màng trong dáng em tinh khôi"
  "Em như hương hoa – thoảng thôi cũng nhớ"
  "Vòng eo nhỏ – một nét đẹp nên thơ"
  "Ánh mắt em – chiếc chìa khóa trái tim"
  "Ngồi bên em, cả thế giới hóa mộng"
  "Thầm gọi tên em giữa gió xuân về"
  "Làn da ấy – trang giấy trắng tình đầu"
  "Cả thế gian gói gọn trong em đấy"
  "Môi em đỏ như hồng khẽ chớm sương"
  "Chỉ cần em đứng đó, tim anh loạn nhịp"
  "Em bước nhẹ như cánh hoa chạm nắng"
  "Giữa chiều thu, em là vầng trăng mộng"
  "Em cười thôi, trời đất cũng ngẩn ngơ"
  "Tình anh gửi theo làn tóc em bay"
  "Em là thơ, là nhạc, là giấc mơ"
)



# Điều chỉnh mảng mô tả nếu số lượng ảnh nhiều hơn số lượng mô tả
if [ ${#IMAGES[@]} -gt ${#DESCRIPTIONS[@]} ]; then
    for ((i=${#DESCRIPTIONS[@]}; i<${#IMAGES[@]}; i++)); do
        DESCRIPTIONS+=("Hình ảnh $((i+1))")
    done
fi

# Tạo filter complex cho video
FILTER_COMPLEX=""
INPUTS=""
VIDEO_STREAMS=""
AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "music.m4a")

# Tính toán số lần lặp lại cần thiết
TOTAL_IMAGES_DURATION=$(echo "${#IMAGES[@]} * $IMAGE_DURATION" | bc)
LOOP_COUNT=$(echo "ceil($AUDIO_DURATION / $TOTAL_IMAGES_DURATION)" | bc)

# Tạo input và filter cho mỗi ảnh
for ((i=0; i<${#IMAGES[@]}; i++)); do
    INPUTS+=" -loop 1 -t $IMAGE_DURATION -i \"${IMAGES[$i]}\""
    
    # Tạo hiệu ứng zoompan và text cho mỗi ảnh
    FILTER_COMPLEX+="[${i}:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,"
    
    # Tạo hiệu ứng zoompan khác nhau cho mỗi ảnh
    case $((i % 6)) in
        0) FILTER_COMPLEX+="zoompan=z='min(zoom+0.0015,1.5)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        1) FILTER_COMPLEX+="zoompan=z='min(zoom+0.001,1.3)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        2) FILTER_COMPLEX+="zoompan=z='min(zoom+0.002,1.4)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        3) FILTER_COMPLEX+="zoompan=z='if(lte(on,25),1,max(1,1.2-0.002*on))':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        4) FILTER_COMPLEX+="zoompan=z='min(zoom+0.001,1.2)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        5) FILTER_COMPLEX+="zoompan=z='min(zoom+0.0015,1.3)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
    esac
    
    # Thêm mô tả cho ảnh nếu SHOW_DESCRIPTIONS là true
    if [ "$SHOW_DESCRIPTIONS" = true ]; then
        FILTER_COMPLEX+="drawtext=text='${DESCRIPTIONS[$i]}':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v${i}]; "
    else
        FILTER_COMPLEX+="format=yuv420p[v${i}]; "
    fi
    
    VIDEO_STREAMS+="[v${i}]"
done

# Thêm audio input
INPUTS+=" -i music.m4a"

# Tạo hiệu ứng chuyển cảnh giữa các ảnh
for ((i=0; i<$((${#IMAGES[@]}-1)); i++)); do
    if [ $i -eq 0 ]; then
        CURRENT_SLIDE="[v0][v1]"
    else
        CURRENT_SLIDE="[slide${i}][v$((i+1))]"
    fi
    
    # Chọn hiệu ứng chuyển cảnh khác nhau
    case $((i % 12)) in
        0) TRANSITION="circlecrop";;
        1) TRANSITION="fadeblack";;
        2) TRANSITION="diagtl";;
        3) TRANSITION="dissolve";;
        4) TRANSITION="pixelize";;
        5) TRANSITION="wiperight";;
        6) TRANSITION="slideleft";;
        7) TRANSITION="smoothleft";;
        8) TRANSITION="circleopen";;
        9) TRANSITION="horzclose";;
        10) TRANSITION="vertopen";;
        11) TRANSITION="distance";;
    esac
    
    FILTER_COMPLEX+="${CURRENT_SLIDE}xfade=transition=${TRANSITION}:duration=$TRANSITION_DURATION:offset=$(($(($i+1))*$IMAGE_DURATION-$TRANSITION_DURATION))[slide$((i+1))]; "
done

# Nếu cần lặp lại ảnh
if [ $LOOP_COUNT -gt 1 ]; then
    TOTAL_IMAGES=${#IMAGES[@]}
    LAST_SLIDE="slide$(($TOTAL_IMAGES-1))"
    
    for ((loop=1; loop<$LOOP_COUNT; loop++)); do
        for ((i=0; i<$TOTAL_IMAGES; i++)); do
            IMG_INDEX=$(( (loop*TOTAL_IMAGES + i) % TOTAL_IMAGES ))
            OFFSET=$(( (loop*TOTAL_IMAGES + i) * IMAGE_DURATION - TRANSITION_DURATION ))
            
            if [ $i -eq 0 ] && [ $loop -eq 1 ]; then
                CURRENT_SLIDE="[${LAST_SLIDE}][v${IMG_INDEX}]"
            elif [ $i -eq 0 ]; then
                CURRENT_SLIDE="[slide$((loop*TOTAL_IMAGES-1))][v${IMG_INDEX}]"
            else
                CURRENT_SLIDE="[slide$((loop*TOTAL_IMAGES+i-1))][v${IMG_INDEX}]"
            fi
            
            # Chọn hiệu ứng chuyển cảnh
            TRANSITION_INDEX=$(( (loop*TOTAL_IMAGES + i) % 12 ))
            case $TRANSITION_INDEX in
                0) TRANSITION="circlecrop";;
                1) TRANSITION="fadeblack";;
                2) TRANSITION="diagtl";;
                3) TRANSITION="dissolve";;
                4) TRANSITION="pixelize";;
                5) TRANSITION="wiperight";;
                6) TRANSITION="slideleft";;
                7) TRANSITION="smoothleft";;
                8) TRANSITION="circleopen";;
                9) TRANSITION="horzclose";;
                10) TRANSITION="vertopen";;
                11) TRANSITION="distance";;
            esac
            
            FILTER_COMPLEX+="${CURRENT_SLIDE}xfade=transition=${TRANSITION}:duration=$TRANSITION_DURATION:offset=${OFFSET}[slide$((loop*TOTAL_IMAGES+i))]; "
        done
        LAST_SLIDE="slide$(( (loop+1)*TOTAL_IMAGES-1 ))"
    done
fi

# Thêm tiêu đề video
FINAL_SLIDE="slide$((${#IMAGES[@]}-1))"
if [ $LOOP_COUNT -gt 1 ]; then
    FINAL_SLIDE="slide$(($LOOP_COUNT*${#IMAGES[@]}-1))"
fi

FILTER_COMPLEX+="[${FINAL_SLIDE}]drawtext=text='Em là ánh nắng':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=20:enable='between(t,0,10)',format=yuv420p[video]"

# Thực thi lệnh FFmpeg
eval "ffmpeg -y ${INPUTS} -filter_complex \"${FILTER_COMPLEX}\" -map \"[video]\" -map $(( ${#IMAGES[@]} )):a -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 320k -r $FPS -shortest -profile:v high -level 4.2 -movflags +faststart output_enhanced.mp4"