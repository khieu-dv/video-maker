#!/bin/bash

# Thiết lập kích thước và tốc độ khung hình
WIDTH=1920
HEIGHT=1080
FPS=30

# Thời lượng hiển thị mỗi ảnh và hiệu ứng chuyển đổi
IMAGE_DURATION=5
TRANSITION_DURATION=1

# Tạo video với hiệu ứng đa dạng và nâng cao chất lượng
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
    -i music.m4a \
    -filter_complex "\
    [0:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.0015,1.5)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 1':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v0]; \
    [1:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.001,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 2':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v1]; \
    [2:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.002,1.4)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 3':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v2]; \
    [3:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='if(lte(on,25),1,max(1,1.2-0.002*on))':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 4':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v3]; \
    [4:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 5':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v4]; \
    [5:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 6':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v5]; \
    [6:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 7':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v6]; \
    [7:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 8':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v7]; \
    [8:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.002,1.4)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 9':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v8]; \
    [9:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 10':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v9]; \
    [10:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.0015,1.3)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 11':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v10]; \
    [11:v]scale=$WIDTH:$HEIGHT:force_original_aspect_ratio=decrease,pad=$WIDTH:$HEIGHT:(ow-iw)/2:(oh-ih)/2,eq=brightness=0.05:saturation=1.2,zoompan=z='min(zoom+0.001,1.2)':d=125:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)',drawtext=text='Photo 12':fontcolor=white:fontsize=48:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=h-th-20[v11]; \
    
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
    
    [videofinal]drawtext=text='My Beautiful Slideshow':fontcolor=white:fontsize=36:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=20:enable='between(t,0,10)',format=yuv420p[video] \
    " \
    -map "[video]" -map 12:a -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 320k -r $FPS -shortest \
    -profile:v high -level 4.2 -movflags +faststart \
    output_enhanced.mp4