#!/bin/bash

# Thư mục chứa ảnh gốc
SOURCE_FOLDER="images_original/hotgirl"
# Thư mục đích
DEST_FOLDER="images3"

# Kiểm tra xem thư mục đích có tồn tại chưa, nếu chưa thì tạo mới
if [ ! -d "$DEST_FOLDER" ]; then
  mkdir "$DEST_FOLDER"
fi

# Duyệt qua tất cả các file trong thư mục nguồn
for file in "$SOURCE_FOLDER"/*; do
  # Kiểm tra nếu file là ảnh với các định dạng .jpg, .jpeg, .png, .bmp
  if [[ $file =~ \.(jpg|jpeg|png|bmp)$ ]]; then
    # Lấy kích thước ảnh bằng lệnh sips (có sẵn trên macOS)
    dimensions=$(sips -g pixelWidth -g pixelHeight "$file" | grep -E 'pixelWidth|pixelHeight' | awk '{print $2}')
    width=$(echo "$dimensions" | head -n 1)
    height=$(echo "$dimensions" | tail -n 1)
    
    # Nếu kích thước ảnh lớn hơn 300x300, sao chép vào thư mục đích
    if [ "$width" -gt 300 ] && [ "$height" -gt 300 ]; then
      cp "$file" "$DEST_FOLDER"
      echo "Đã sao chép: $file"
    fi
  fi
done
