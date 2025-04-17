#!/bin/bash

# Configuration
WIDTH=1920
HEIGHT=1080
FPS=30
IMAGE_DURATION=5
TRANSITION_DURATION=1.5
SHOW_DESCRIPTIONS=true
TEXT_ANIMATION=true
SHOW_TIMECODE=false
WATERMARK="watermark.png"  # Path to watermark image (optional)
FONT_FILE="Arial.ttf"      # Path to font file (optional)

# Create temp directory
mkdir -p temp

# Get images from images folder
IMAGES=()
for img in images/*.{jpg,jpeg,png}; do
    [[ -f "$img" ]] && IMAGES+=("$img")
done

if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "No images found in the images folder!"
    exit 1
fi

# Descriptions array
DESCRIPTIONS=(
    "Beautiful landscape at Ha Long Bay"
    "Sunset on Nha Trang beach"
    "Majestic mountains in Sa Pa"
    "Summer lotus flowers in Hanoi"
    "Hoi An ancient town at night"
    "Tropical forest in Central Highlands"
    "Magnificent waterfall in Da Lat"
    "Terraced fields in Mu Cang Chai"
    "Autumn on tea hills in Moc Chau"
    "Traditional Vietnamese festival"
)

# Adjust descriptions if needed
if [ ${#IMAGES[@]} -gt ${#DESCRIPTIONS[@]} ]; then
    for ((i=${#DESCRIPTIONS[@]}; i<${#IMAGES[@]}; i++)); do
        DESCRIPTIONS+=("Image $((i+1))")
    done
fi

# Prepare image inputs and filters
INPUTS=""
FILTER_COMPLEX=""
VIDEO_STREAMS=""
AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "music.m4a")

# Calculate needed loops
TOTAL_IMAGES_DURATION=$(echo "${#IMAGES[@]} * $IMAGE_DURATION" | bc)
LOOP_COUNT=$(echo "ceil($AUDIO_DURATION / $TOTAL_IMAGES_DURATION)" | bc)

# Generate color palette for each image (for better transitions)
echo "Generating color palettes..."
for ((i=0; i<${#IMAGES[@]}; i++)); do
    ffmpeg -y -i "${IMAGES[$i]}" -vf "scale=32:32:flags=fast_bilinear" -frames:v 1 "temp/palette_${i}.png" 2>/dev/null
done

# Create inputs and filters for each image
for ((i=0; i<${#IMAGES[@]}; i++)); do
    INPUTS+=" -loop 1 -t $IMAGE_DURATION -i \"${IMAGES[$i]}\""
    INPUTS+=" -loop 1 -t $IMAGE_DURATION -i \"temp/palette_${i}.png\""
    
    # Base image processing
    FILTER_COMPLEX+="[${i}:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,"
    FILTER_COMPLEX+="pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2:color=black,"

    # Dynamic zoom effects with different patterns
    case $((i % 8)) in
        0)  # Slow zoom in
            FILTER_COMPLEX+="zoompan=z='min(zoom+0.0015,1.5)':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',"
            ;;
        1)  # Slow zoom out
            FILTER_COMPLEX+="zoompan=z='if(lte(on,25),1.3,max(1.3-0.002*on,1.0))':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',"
            ;;
        2)  # Pan left to right
            FILTER_COMPLEX+="zoompan=z=1.1:d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)+on*10':y='ih/2-(ih/zoom/2)',"
            ;;
        3)  # Pan top to bottom
            FILTER_COMPLEX+="zoompan=z=1.1:d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)+on*5',"
            ;;
        4)  # Random movement
            FILTER_COMPLEX+="zoompan=z=1.1:d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)+on*3*sin(on*0.05)':y='ih/2-(ih/zoom/2)+on*2*cos(on*0.03)',"
            ;;
        5)  # Zoom on center then back
            FILTER_COMPLEX+="zoompan=z='if(lte(on,30),1.0+0.5*on/30,if(lte(on,60),1.5-0.5*(on-30)/30,1.0))':d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',"
            ;;
        6)  # Diagonal pan
            FILTER_COMPLEX+="zoompan=z=1.1:d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)+on*5':y='ih/2-(ih/zoom/2)+on*3',"
            ;;
        7)  # Rotational effect
            FILTER_COMPLEX+="zoompan=z=1.1:d=$(($IMAGE_DURATION*$FPS)):x='iw/2-(iw/zoom/2)+on*3*sin(on*0.1)':y='ih/2-(ih/zoom/2)+on*2*cos(on*0.1)',"
            ;;
    esac

    # Add color correction and enhancements
    FILTER_COMPLEX+="eq=brightness=0.02:contrast=1.1:saturation=1.1,"

    # Add subtle vignette effect
    FILTER_COMPLEX+="vignette=angle=45:gamma=1.5,"

    # Add description text with animation if enabled
    if [ "$SHOW_DESCRIPTIONS" = true ]; then
        if [ "$TEXT_ANIMATION" = true ]; then
            # Animated text (fade in and slide up)
            FILTER_COMPLEX+="drawtext=text='${DESCRIPTIONS[$i]}':fontfile=$FONT_FILE:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x='(w-text_w)/2':y='h-th-20+(30*sin(t*3))':alpha='if(lt(t,1),0,if(lt(t,2),(t-1)/1,1))',"
        else
            # Static text
            FILTER_COMPLEX+="drawtext=text='${DESCRIPTIONS[$i]}':fontfile=$FONT_FILE:fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x='(w-text_w)/2':y='h-th-20',"
        fi
    fi

    # Add timecode if enabled
    if [ "$SHOW_TIMECODE" = true ]; then
        FILTER_COMPLEX+="drawtext=text='%{pts\:gmtime\:0\:%d/%m/%Y %T}':fontfile=$FONT_FILE:fontcolor=white:fontsize=24:x=20:y=20,"
    fi

    # Add watermark if exists
    if [ -f "$WATERMARK" ]; then
        FILTER_COMPLEX+="[${i}:v][$((i+${#IMAGES[@]})):v]overlay=W-w-20:H-h-20:enable='between(t,0,$IMAGE_DURATION)',"
    fi

    FILTER_COMPLEX+="format=yuv420p[v${i}]; "
    VIDEO_STREAMS+="[v${i}]"
done

# Add audio input
INPUTS+=" -i music.m4a"

# Create transitions between images
for ((i=0; i<$((${#IMAGES[@]}-1)); i++)); do
    if [ $i -eq 0 ]; then
        CURRENT_SLIDE="[v0][v1]"
    else
        CURRENT_SLIDE="[slide${i}][v$((i+1))]"
    fi

    # Select transition effect
    case $((i % 16)) in
        0) TRANSITION="fade";;
        1) TRANSITION="distance";;
        2) TRANSITION="wipeleft";;
        3) TRANSITION="wiperight";;
        4) TRANSITION="slideup";;
        5) TRANSITION="slidedown";;
        6) TRANSITION="smoothleft";;
        7) TRANSITION="smoothright";;
        8) TRANSITION="circleopen";;
        9) TRANSITION="circleclose";;
        10) TRANSITION="vertopen";;
        11) TRANSITION="vertclose";;
        12) TRANSITION="hlslice";;
        13) TRANSITION="hrslice";;
        14) TRANSITION="vuslice";;
        15) TRANSITION="vdslice";;
    esac

    # Add transition with color matching
    FILTER_COMPLEX+="${CURRENT_SLIDE}xfade=transition=${TRANSITION}:duration=$TRANSITION_DURATION:offset=$(($(($i+1))*$IMAGE_DURATION-$TRANSITION_DURATION))[slide$((i+1))]; "
done

# Handle looping if needed
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

            # Select transition effect
            TRANSITION_INDEX=$(( (loop*TOTAL_IMAGES + i) % 16 ))
            case $TRANSITION_INDEX in
                0) TRANSITION="fade";;
                1) TRANSITION="distance";;
                2) TRANSITION="wipeleft";;
                3) TRANSITION="wiperight";;
                4) TRANSITION="slideup";;
                5) TRANSITION="slidedown";;
                6) TRANSITION="smoothleft";;
                7) TRANSITION="smoothright";;
                8) TRANSITION="circleopen";;
                9) TRANSITION="circleclose";;
                10) TRANSITION="vertopen";;
                11) TRANSITION="vertclose";;
                12) TRANSITION="hlslice";;
                13) TRANSITION="hrslice";;
                14) TRANSITION="vuslice";;
                15) TRANSITION="vdslice";;
            esac

            FILTER_COMPLEX+="${CURRENT_SLIDE}xfade=transition=${TRANSITION}:duration=$TRANSITION_DURATION:offset=${OFFSET}[slide$((loop*TOTAL_IMAGES+i))]; "
        done
        LAST_SLIDE="slide$(( (loop+1)*TOTAL_IMAGES-1 ))"
    done
fi

# Final video processing
FINAL_SLIDE="slide$((${#IMAGES[@]}-1))"
if [ $LOOP_COUNT -gt 1 ]; then
    FINAL_SLIDE="slide$(($LOOP_COUNT*${#IMAGES[@]}-1))"
fi

# Add intro and outro effects
FILTER_COMPLEX+="[${FINAL_SLIDE}]"

# Add intro text animation
FILTER_COMPLEX+="drawtext=text='My Travel Memories':fontfile=$FONT_FILE:fontcolor=0xFFFFFF:fontsize=72:box=1:boxcolor=0x000000@0.5:boxborderw=10:x='(w-text_w)/2':y='(h-text_h)/2':alpha='if(lt(t,1),0,if(lt(t,2),(t-1)/1,if(lt(t,6),1,if(lt(t,7),(1-(t-6))/1,0)))',"

# Add outro fade effect
FILTER_COMPLEX+="fade=t=out:st=$(echo "$AUDIO_DURATION-2" | bc):d=2,"

# Final video format
FILTER_COMPLEX+="format=yuv420p[video]"

# Execute FFmpeg command
echo "Rendering video..."
eval "ffmpeg -y ${INPUTS} -filter_complex \"${FILTER_COMPLEX}\" -map \"[video]\" -map $(( ${#IMAGES[@]}*2 )):a -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 320k -r $FPS -shortest -profile:v high -level 4.2 -movflags +faststart -pix_fmt yuv420p output_professional.mp4"

# Clean up temp files
rm -rf temp

echo "Video created: output_professional.mp4"