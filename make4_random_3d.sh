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

# Xáo trộn ảnh để hiển thị ngẫu nhiên
IMAGES=( $(printf "%s\n" "${IMAGES[@]}" | shuf) )

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "Không tìm thấy ảnh trong thư mục images!"
    exit 1
fi

# Tạo mảng chứa mô tả cho từng ảnh
DESCRIPTIONS=(
  "Em là nắng mai khiến tim anh bối rối"
  "Ánh mắt ấy, ngàn sao cũng phải ngước nhìn"
  "Tà váy em khẽ lay, gió cũng ngại ngùng"
  "Nụ cười em rực rỡ cả bầu trời anh"
  "Mắt em sâu như ngân hà không đáy"
  "Dáng em nghiêng – nghiêng cả trái tim này"
  "Tóc em bay, cuốn hồn anh vào mộng"
  "Em là thơ, là nhung nhớ giữa đời"
  "Chỉ một ánh nhìn, thế giới như dịu lại"
  "Giọng em – bản tình ca dịu dàng nhất"
  "Đôi môi em – xuân vừa hé khẽ thôi"
  "Em nhẹ như mây trôi qua bầu trời vắng"
  "Ánh mắt em – cả bầu trời thương nhớ"
  "Từng bước chân em mang theo nỗi nhớ"
  "Dẫu muôn ánh sáng, em vẫn là bình minh"
  "Em im lặng, lòng anh dậy sóng khẽ"
  "Bước em đi – thơ theo từng nhịp phố"
  "Áo em bay như sóng nhỏ giữa chiều thu"
  "Em là mộng – là hương, là men say"
  "Một ánh nhìn, cả đời chẳng thể quên"
  "Em là bản tình ca chưa ai viết"
  "Nụ cười em tan đi mọi nỗi buồn"
  "Ở gần em, đời bỗng mềm như gió"
  "Tình em như gió – không thấy mà say"
  "Đôi tay em dịu dàng như mùa thu"
  "Chạm tim anh – trời cũng phải rung lên"
  "Em là khúc nhạc chưa từng anh hát"
  "Da em mềm – như ánh trăng đêm hạ"
  "Vẻ đẹp ấy, khiến thời gian dừng lại"
  "Từng dáng em – một câu thơ sống động"
  "Trong mắt em – cả mùa xuân trú ngụ"
  "Ngực em – chiếc gối mộng giữa thiên đường"
  "Tình em như rượu – uống vào là nhớ mãi"
  "Ánh mắt em – tia nắng đầu tiên"
  "Anh lạc bước trong hương em bất tận"
  "Giữa biển người, em là hoàng hôn yên ả"
  "Dáng em mong manh – khiến lòng ngơ ngẩn"
  "Em như hương – thoảng qua cũng để nhớ"
  "Vòng eo ấy – một nét thơ không lời"
  "Mắt em – chiếc chìa khóa tim anh"
  "Ngồi bên em – cả thế giới ngừng thở"
  "Tên em – anh thầm gọi giữa gió xuân"
  "Làn da em – trang giấy đầu tình thơ"
  "Cả thế gian – gọn trong ánh em cười"
  "Môi em – nụ hồng chớm giữa sương mai"
  "Chỉ cần em đó, tim anh cũng đủ rối"
  "Em bước khẽ – như cánh hoa đón nắng"
  "Giữa chiều thu, em là trăng mộng mơ"
  "Chỉ một nụ cười, trời đất ngẩn ngơ"
  "Tình anh bay theo làn tóc em buông"
  "Em là nhạc – là thơ – là mộng ảo"
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
AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "music2.m4a")

# Tính toán số lần lặp lại cần thiết - sửa lỗi ceil()
TOTAL_IMAGES_DURATION=$(echo "${#IMAGES[@]} * $IMAGE_DURATION" | bc)
# Thay ceil() bằng cách thủ công
LOOP_COUNT=$(echo "($AUDIO_DURATION + $TOTAL_IMAGES_DURATION - 0.001) / $TOTAL_IMAGES_DURATION" | bc)

# Tạo input và filter cho mỗi ảnh
for ((i=0; i<${#IMAGES[@]}; i++)); do
    INPUTS+=" -loop 1 -t $IMAGE_DURATION -i \"${IMAGES[$i]}\""
    
    # Tạo hiệu ứng 3D và zoompan cho mỗi ảnh
    FILTER_COMPLEX+="[${i}:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,"
    
    # Tạo hiệu ứng 3D khác nhau cho mỗi ảnh - đã loại bỏ filter 'waves'
    case $((i % 8)) in
        0) FILTER_COMPLEX+="perspective=x0=0:y0=0:x1=W:y1=0:x2=0:y2=H:x3=W:y3=H:interpolation=linear,"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.0015,1.5)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        1) FILTER_COMPLEX+="rotate=t*0.02:c=none:ow=rotw(t*0.02):oh=roth(t*0.02),"
           FILTER_COMPLEX+="scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.001,1.3)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        2) # 3D cube rotation effect
           FILTER_COMPLEX+="perspective=x0='20+10*sin(t)':y0='20+10*cos(t)':x1='W-20+10*sin(t)':y1='20-10*cos(t)':"
           FILTER_COMPLEX+="x2='20-10*sin(t)':y2='H-20-10*cos(t)':x3='W-20-10*sin(t)':y3='H-20+10*cos(t)',"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.002,1.4)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        3) # 3D flip effect
           FILTER_COMPLEX+="perspective=x0='W*t/$IMAGE_DURATION':y0=0:x1=W:y1=0:x2='W*t/$IMAGE_DURATION':y2=H:x3=W:y3=H:sense=destination,"
           FILTER_COMPLEX+="zoompan=z='if(lte(on,25),1,max(1,1.2-0.002*on))':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        4) # Thay waves bằng ripple effect
           FILTER_COMPLEX+="lenscorrection=cx=0.5:cy=0.5:k1=0.05*sin(t/2):k2=0.05*cos(t/3),"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.001,1.2)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        5) # 3D page curl effect (simulated with perspective)
           FILTER_COMPLEX+="perspective=x0=0:y0=0:x1='W-W*sin(t*3.14159/20)':y1=0:x2=0:y2=H:x3='W-W*sin(t*3.14159/20)':y3=H:interpolation=linear,"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.0015,1.3)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        6) # 3D rotation around Y axis
           FILTER_COMPLEX+="perspective=x0='W/2-W/2*cos(t*0.05)':y0=0:x1='W/2+W/2*cos(t*0.05)':y1=0:"
           FILTER_COMPLEX+="x2='W/2-W/2*cos(t*0.05)':y2=H:x3='W/2+W/2*cos(t*0.05)':y3=H:interpolation=linear,"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.001,1.25)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
        
        7) # 3D sphere effect (simulated with lenscorrection)
           FILTER_COMPLEX+="lenscorrection=cx=0.5:cy=0.5:k1=0.1*sin(t):k2=0,"
           FILTER_COMPLEX+="zoompan=z='min(zoom+0.0005,1.15)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',";;
    esac
    
    # Thêm mô tả cho ảnh nếu SHOW_DESCRIPTIONS là true
    if [ "$SHOW_DESCRIPTIONS" = true ]; then
        FILTER_COMPLEX+="drawtext=text='${DESCRIPTIONS[$i]}':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20"
        # Loại bỏ subtitles filter vì gây lỗi
        FILTER_COMPLEX+="[v${i}]; "
    else
        FILTER_COMPLEX+="format=yuv420p[v${i}]; "
    fi
    
    VIDEO_STREAMS+="[v${i}]"
done

# Thêm audio input
INPUTS+=" -i music2.m4a"

# Sửa lỗi "-gt: unary operator expected" bằng cách kiểm tra độ dài mảng IMAGES
if [ "${#IMAGES[@]}" -gt 1 ]; then
    # Tạo hiệu ứng chuyển cảnh 3D giữa các ảnh
    for ((i=0; i<$((${#IMAGES[@]}-1)); i++)); do
        if [ $i -eq 0 ]; then
            CURRENT_SLIDE="[v0][v1]"
        else
            CURRENT_SLIDE="[slide${i}][v$((i+1))]"
        fi
        
        # Chọn hiệu ứng chuyển cảnh 3D
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
fi

# Nếu cần lặp lại ảnh
if [ "${#IMAGES[@]}" -gt 1 ] && [ "$LOOP_COUNT" -gt 1 ]; then
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
            
            # Chọn hiệu ứng chuyển cảnh 3D
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

# Thêm tiêu đề video với hiệu ứng 3D
if [ "${#IMAGES[@]}" -gt 1 ]; then
    FINAL_SLIDE="slide$((${#IMAGES[@]}-1))"
    if [ "$LOOP_COUNT" -gt 1 ]; then
        FINAL_SLIDE="slide$(($LOOP_COUNT*${#IMAGES[@]}-1))"
    fi
else
    FINAL_SLIDE="v0"
fi

# Thêm hiệu ứng 3D cho tiêu đề
FILTER_COMPLEX+="[${FINAL_SLIDE}]drawtext=text='Em là ánh nắng':fontcolor=white:fontsize=72:x='(w-text_w)/2+30*sin(t*0.5)':y='80+20*cos(t*0.5)':shadowcolor=black@0.5:shadowx=4:shadowy=4:enable='between(t,0,10)',format=yuv420p[video]"

# Thực thi lệnh FFmpeg
eval "ffmpeg -y ${INPUTS} -filter_complex \"${FILTER_COMPLEX}\" -map \"[video]\" -map $(( ${#IMAGES[@]} )):a -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 320k -r $FPS -shortest -profile:v high -level 4.2 -movflags +faststart output_3d_enhanced.mp4"