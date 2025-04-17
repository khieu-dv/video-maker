#!/bin/bash

# Cấu hình nâng cao
WIDTH=1920
HEIGHT=1080
FPS=30
IMAGE_DURATION=5
TRANSITION_DURATION=1
OUTPUT_FILE="cinematic_slideshow.mp4"
FONT="/System/Library/Fonts/Supplemental/Arial.ttf"  # Đường dẫn font trên macOS
MUSIC_VOLUME="0.8"  # Âm lượng nhạc nền (0-1)

# Tạo thư mục tạm để xử lý ảnh (nếu cần thiết)
TEMP_DIR="temp_slideshow"
mkdir -p $TEMP_DIR

# Tạo văn bản intro
echo "Creating intro title..."
ffmpeg -y -f lavfi -i color=c=black:s=${WIDTH}x${HEIGHT}:d=3 \
  -vf "drawtext=fontfile=$FONT:text='My Cinematic Slideshow':fontcolor=white:fontsize=72:box=0:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,0.5,3)':alpha='if(lt(t,0.5),0,if(lt(t,1),2*(t-0.5),if(gt(t,2.5),2*(3-t),1)))':fix_bounds=true, \
       drawtext=fontfile=$FONT:text='Created with FFmpeg':fontcolor=white:fontsize=36:box=0:x=(w-text_w)/2:y=(h+150-text_h)/2:enable='between(t,1,3)':alpha='if(lt(t,1),0,if(lt(t,1.5),2*(t-1),if(gt(t,2.5),2*(3-t),1)))':fix_bounds=true" \
  $TEMP_DIR/intro.mp4

# Tạo văn bản outro
echo "Creating outro title..."
ffmpeg -y -f lavfi -i color=c=black:s=${WIDTH}x${HEIGHT}:d=3 \
  -vf "drawtext=fontfile=$FONT:text='Thank You for Watching':fontcolor=white:fontsize=72:box=0:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,0.5,3)':alpha='if(lt(t,0.5),0,if(lt(t,1),2*(t-0.5),if(gt(t,2.5),2*(3-t),1)))':fix_bounds=true, \
       drawtext=fontfile=$FONT:text='© $(date +%Y)':fontcolor=white:fontsize=36:box=0:x=(w-text_w)/2:y=(h+150-text_h)/2:enable='between(t,1,3)':alpha='if(lt(t,1),0,if(lt(t,1.5),2*(t-1),if(gt(t,2.5),2*(3-t),1)))':fix_bounds=true" \
  $TEMP_DIR/outro.mp4

# Tạo danh sách tệp ảnh đầu vào để xử lý trước
echo "# Danh sách đầu vào" > $TEMP_DIR/input.txt
for i in {1..12}; do
  echo "file 'img$i.jpeg'" >> $TEMP_DIR/input.txt
done

# Xử lý file trung gian chứa các hiệu ứng ảnh
echo "Building main slideshow..."
ffmpeg -y \
    -loop 1 -t $IMAGE_DURATION -i img1.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img2.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img3.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img4.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img5.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img6.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img7.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img8.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img9.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img10.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img11.jpeg \
    -loop 1 -t $IMAGE_DURATION -i img12.jpeg \
    -filter_complex "\
    [0:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.0015,1.5)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 1':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v0]; \
    [1:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.001,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 2':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v1]; \
    [2:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.002,1.4)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 3':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v2]; \
    [3:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='if(lte(on,25),1,max(1,1.2-0.002*on))':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 4':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v3]; \
    [4:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 5':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v4]; \
    [5:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,eq=brightness=0.03:contrast=1.1:saturation=1.2,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 6':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v5]; \
    [6:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 7':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v6]; \
    [7:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 8':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v7]; \
    [8:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.002,1.4)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 9':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v8]; \
    [9:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 10':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v9]; \
    [10:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 11':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v10]; \
    [11:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.3:contrast=1.1,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',gblur=sigma=0.3:steps=1,unsharp=5:5:1.0:5:5:0.0,drawtext=fontfile=$FONT:text='Photo 12':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20,vignette=angle=PI/4:mode=backward[v11]; \
    [v0][v1]xfade=transition=circlecrop:duration=$TRANSITION_DURATION:offset=$(($IMAGE_DURATION-$TRANSITION_DURATION))[slide1]; \
    [slide1][v2]xfade=transition=fadeblack:duration=$TRANSITION_DURATION:offset=$((2*$IMAGE_DURATION-$TRANSITION_DURATION))[slide2]; \
    [slide2][v3]xfade=transition=diagtl:duration=$TRANSITION_DURATION:offset=$((3*$IMAGE_DURATION-$TRANSITION_DURATION))[slide3]; \
    [slide3][v4]xfade=transition=dissolve:duration=$TRANSITION_DURATION:offset=$((4*$IMAGE_DURATION-$TRANSITION_DURATION))[slide4]; \
    [slide4][v5]xfade=transition=pixelize:duration=$TRANSITION_DURATION:offset=$((5*$IMAGE_DURATION-$TRANSITION_DURATION))[slide5]; \
    [slide5][v6]xfade=transition=wiperight:duration=$TRANSITION_DURATION:offset=$((6*$IMAGE_DURATION-$TRANSITION_DURATION))[slide6]; \
    [slide6][v7]xfade=transition=slideleft:duration=$TRANSITION_DURATION:offset=$((7*$IMAGE_DURATION-$TRANSITION_DURATION))[slide7]; \
    [slide7][v8]xfade=transition=smoothleft:duration=$TRANSITION_DURATION:offset=$((8*$IMAGE_DURATION-$TRANSITION_DURATION))[slide8]; \
    [slide8][v9]xfade=transition=circleopen:duration=$TRANSITION_DURATION:offset=$((9*$IMAGE_DURATION-$TRANSITION_DURATION))[slide9]; \
    [slide9][v10]xfade=transition=horzclose:duration=$TRANSITION_DURATION:offset=$((10*$IMAGE_DURATION-$TRANSITION_DURATION))[slide10]; \
    [slide10][v11]xfade=transition=vertopen:duration=$TRANSITION_DURATION:offset=$((11*$IMAGE_DURATION-$TRANSITION_DURATION))[videofinal]; \
    [videofinal]drawtext=fontfile=$FONT:text='My Beautiful Slideshow':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=20:enable='between(t,0,10)',format=yuv420p[video] \
    " \
    -map "[video]" -c:v libx264 -preset slow -crf 18 -r $FPS -t $((12*$IMAGE_DURATION)) \
    -profile:v high -level 4.2 -movflags +faststart \
    $TEMP_DIR/main.mp4

# Tạo danh sách các file đã xử lý để nối lại với nhau
echo "# Danh sách tệp để nối" > $TEMP_DIR/files.txt
echo "file 'intro.mp4'" >> $TEMP_DIR/files.txt
echo "file 'main.mp4'" >> $TEMP_DIR/files.txt
echo "file 'outro.mp4'" >> $TEMP_DIR/files.txt

# Nối các phần lại với nhau
echo "Combining video segments..."
ffmpeg -y -f concat -safe 0 -i $TEMP_DIR/files.txt -c copy $TEMP_DIR/video_no_audio.mp4

# Lấy thời lượng video
VIDEO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $TEMP_DIR/video_no_audio.mp4)
# Sử dụng bc để tính toán số thập phân
FADE_START=$(echo "$VIDEO_DURATION - 5" | bc)

# Thêm nhạc nền và xử lý âm thanh
echo "Adding music and finalizing..."
ffmpeg -y -i $TEMP_DIR/video_no_audio.mp4 -i music.m4a -filter_complex \
"[1:a]volume=$MUSIC_VOLUME,apad=whole_dur=$VIDEO_DURATION[music]; \
 [music]afade=t=out:st=$FADE_START:d=5[aout]" \
-map 0:v -map "[aout]" -c:v copy -c:a aac -b:a 320k -shortest $OUTPUT_FILE

# Kiểm tra nếu file đầu ra tồn tại
if [ -f "$OUTPUT_FILE" ]; then
  # Lấy thời lượng đầu ra
  OUTPUT_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $OUTPUT_FILE)
  
  # Hiển thị thông tin
  echo "----------------------------------------"
  echo "Video slideshow created successfully!"
  echo "Output file: $OUTPUT_FILE"
  echo "Resolution: ${WIDTH}x${HEIGHT}, FPS: $FPS"
  echo "Duration: $OUTPUT_DURATION seconds"
  echo "----------------------------------------"
else
  echo "----------------------------------------"
  echo "Error: Output file not created. Check for errors above."
  echo "----------------------------------------"
fi

# Dọn dẹp tệp tạm nếu không cần thiết
# rm -rf $TEMP_DIR

echo "Done! Your professional slideshow is ready to watch."