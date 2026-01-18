#!/bin/bash

# 图标生成脚本（保留透明背景）
# 使用方法: ./generate_icons.sh your_icon.png

if [ -z "$1" ]; then
    echo "❌ 请提供图片路径"
    echo "用法: ./generate_icons.sh your_icon.png"
    exit 1
fi

SOURCE_IMAGE="$1"
OUTPUT_DIR="time-shifty/Assets.xcassets/AppIcon.appiconset"

echo "🎨 开始生成应用图标（保留透明背景）..."
echo "📁 源图片: $SOURCE_IMAGE"
echo "📂 输出目录: $OUTPUT_DIR"

# 检查是否安装了 ImageMagick
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "⚠️  未检测到 ImageMagick，将使用 sips（可能丢失透明度）"
    echo "💡 建议安装 ImageMagick 以保持透明背景："
    echo "   brew install imagemagick"
    USE_SIPS=true
else
    USE_SIPS=false
    # 检查使用 magick 还是 convert
    if command -v magick &> /dev/null; then
        CONVERT_CMD="magick"
    else
        CONVERT_CMD="convert"
    fi
    echo "✅ 使用 ImageMagick (保持透明背景)"
fi

# 确保目录存在
mkdir -p "$OUTPUT_DIR"

# 定义图标尺寸（使用数组而不是关联数组，兼容 zsh）
generate_icon() {
    local filename=$1
    local size=$2
    local output_path="$OUTPUT_DIR/$filename"
    
    if [ "$USE_SIPS" = true ]; then
        # 使用 sips（可能丢失透明度）
        local width=$(echo $size | cut -d'x' -f1)
        local height=$(echo $size | cut -d'x' -f2)
        sips -z $height $width "$SOURCE_IMAGE" --out "$output_path" > /dev/null 2>&1
    else
        # 使用 ImageMagick（保持透明背景）
        $CONVERT_CMD "$SOURCE_IMAGE" -resize $size -background none -gravity center -extent $size "$output_path"
    fi
    
    echo "  ✓ $filename ($size)"
}

# 生成各种尺寸的图标
generate_icon "icon_16x16.png" "16x16"
generate_icon "icon_16x16@2x.png" "32x32"
generate_icon "icon_32x32.png" "32x32"
generate_icon "icon_32x32@2x.png" "64x64"
generate_icon "icon_128x128.png" "128x128"
generate_icon "icon_128x128@2x.png" "256x256"
generate_icon "icon_256x256.png" "256x256"
generate_icon "icon_256x256@2x.png" "512x512"
generate_icon "icon_512x512.png" "512x512"
generate_icon "icon_512x512@2x.png" "1024x1024"

echo ""
echo "✅ 图标生成完成！"
echo ""
if [ "$USE_SIPS" = true ]; then
    echo "⚠️  注意: 使用 sips 可能会丢失透明背景"
    echo "💡 建议: 安装 ImageMagick 以保持透明度"
    echo "   brew install imagemagick"
else
    echo "✅ 透明背景已保留"
fi
