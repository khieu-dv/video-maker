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
  "Those eyes make my heart lose direction"
  "A soft smile lights up my whole day"
  "Even the wind envies her gentle steps"
  "One glance and my heartbeat skips away"
  "That voice calms my restless soul fast"
  "Just a look stirs my heart deeply"
  "Flowing dress I freeze in silence"
  "A shadow passes I stay in awe"
  "She stays quiet yet touches my heart"
  "A moment enough to fall completely in"
  "That gentleness humbles autumn skies slowly"
  "The world fits inside her bright eyes"
  "Slender figure walks the winter street"
  "Delicate like morning mist on leaves"
  "Sweet pain hides in her soft smile"
  "Sad eyes whisper silent love stories"
  "Eyes alone tell me everything inside"
  "Small hands hold my entire sky gently"
  "One touch and I lose control"
  "City pauses as she walks by"
  "One meeting creates a lifetime memory"
  "Footsteps echo deep inside my chest"
  "Scent in her hair pulls me near"
  "My heart feels coded just for her"
  "She turns and I fall again"
  "White dress floats and wind freezes"
  "Her smile breaks my guarded soul"
  "A quiet look says it all"
  "Love begins with just one gaze"
  "I keep remembering without clear reason"
  "She is a poem still unwritten"
  "One glance calms the storm inside"
  "Summer softens with her nearby now"
  "That tilt of head stuns me"
  "Touching wind still missing her voice"
  "Her smile brightens all cloudy days"
  "Her smile cures sadness like magic"
  "Unspoken words stir my lonely soul"
  "A coincidence stayed in me forever"
  "Each meeting feels like soft dreams"
  "Eyes that make my heart tremble"
  "Curved lashes stop the blowing wind"
  "Real feelings need no fancy words"
  "She walked in my heart stayed"
  "Her sadness moved autumn leaves slowly"
  "A second lasts forever in thought"
  "A brush of hands brings dreams"
  "Not together still always feeling near"
  "Among millions I only see her"
  "One quiet beat and heart skips"
  "She turns and I keep waiting"
  "A silent love under soft sunset"
  "Missing someone without saying their name"
  "The wind carries her gentle memory"
  "Her laughter paints bright morning skies"
  "One encounter love lasts till end"
  "First love is quiet and deep"
  "Eyes alone build sweet illusions now"
  "She stays quiet and I still feel"
  "Those eyes hold my silent sky"
  "That gaze begins my lovely morning"
  "She came and the world changed"
  "A little shyness becomes soft memory"
  "Peace returns seeing her nearby now"
  "A look speaks without one word"
  "My heart recalls her silhouette daily"
  "She is every unspoken love verse"
  "Her eyes speak more than words"
  "One look lights my whole day"
  "Came and went like spring wind"
  "I watch her standing from afar"
  "Softness becomes a lasting echo inside"
  "Peace is watching from far away"
  "Eyes say what lips cannot say"
  "Her glance wraps my beating heart"
  "Love in silence needs no reason"
  "A dream I never want ending"
  "By chance she stayed in mind"
  "She is quiet and I restless"
  "Already in love without clear thought"
  "No promises made still I wait"
  "She floats like untouched morning breeze"
  "Suddenly missing without any reason"
  "Her laughter stays in memory forever"
  "Light fades before her glowing gaze"
  "Just her glance sparks new seasons"
  "Met once still thinking of her"
  "Eyes met and hearts remembered forever"
  "Her scent stays in the breeze"
  "One touch and I belonged already"
  "Her voice echoes in my mind"
  "My heart chose her long ago"
  "Her eyes are my secret sky"
  "One glimpse endless affection grows strong"
  "Love does not always need logic"
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
INPUTS+=" -i music2.m4a"

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