.PHONY: help build release install reinstall clean debug archive kill

# 默认显示帮助
help:
	@echo "Time-Shifty 构建命令:"
	@echo ""
	@echo "  make build      - 构建 Debug 版本（开发用）"
	@echo "  make release    - 构建 Release 版本（正式发布）"
	@echo "  make install    - 安装当前构建的版本到 /Applications"
	@echo "  make reinstall  - 重新构建并安装（推荐）"
	@echo "  make kill       - 停止正在运行的应用"
	@echo "  make debug      - 构建并直接运行 Debug 版本"
	@echo "  make clean      - 清理所有构建产物"
	@echo "  make archive    - 创建归档（Archive）"
	@echo ""

# Debug 版本（开发用）
build:
	@echo "🔨 构建 Debug 版本..."
	xcodebuild -scheme time-shifty -configuration Debug build

# Release 版本（正式发布）
release:
	@echo "🏗️  构建 Release 版本..."
	@echo "🧹 清理旧的 Release 构建..."
	@rm -rf release_build
	@mkdir -p release_build
	@echo "🔨 开始构建..."
	xcodebuild -scheme time-shifty -configuration Release \
		-derivedDataPath ./Build \
		CONFIGURATION_BUILD_DIR=./release_build \
		clean build || (echo "⚠️  构建有警告，但应用已生成" && true)
	@if [ -d "release_build/time-shifty.app" ]; then \
		echo "✅ Release 版本构建完成: release_build/time-shifty.app"; \
	else \
		echo "❌ 构建失败"; \
		exit 1; \
	fi

# 停止正在运行的应用
kill:
	@echo "🛑 停止正在运行的应用..."
	@pkill -f "Time-Shifty" || true
	@pkill -f "time-shifty" || true
	@echo "✅ 应用已停止"

# 安装到系统
install: kill
	@echo "📦 安装到 /Applications..."
	@if [ -d "release_build/time-shifty.app" ]; then \
		sudo rm -rf /Applications/Time-Shifty.app; \
		sudo cp -r release_build/time-shifty.app /Applications/Time-Shifty.app; \
		echo "✅ 已安装 Release 版本到 /Applications/Time-Shifty.app"; \
	elif [ -d "Build/Products/Debug/time-shifty.app" ]; then \
		sudo rm -rf /Applications/Time-Shifty.app; \
		sudo cp -r Build/Products/Debug/time-shifty.app /Applications/Time-Shifty.app; \
		echo "✅ 已安装 Debug 版本到 /Applications/Time-Shifty.app"; \
	else \
		echo "❌ 未找到构建的应用，请先运行 make build 或 make release"; \
		exit 1; \
	fi

# 重新构建并安装（推荐使用）
reinstall: clean release install
	@echo "✅ 重新构建并安装完成"
	@echo "💡 现在可以启动应用了：open /Applications/Time-Shifty.app"

# 构建并运行
debug:
	@echo "🚀 构建并运行..."
	xcodebuild -scheme time-shifty -configuration Debug build
	@open Build/Products/Debug/time-shifty.app

# 清理
clean:
	@echo "🧹 清理构建产物..."
	rm -rf Build
	rm -rf release_build
	rm -rf ~/Library/Developer/Xcode/DerivedData/time-shifty-*
	@echo "✅ 清理完成"

# 创建归档（用于分发）
archive:
	@echo "📦 创建归档..."
	@mkdir -p release_build
	xcodebuild archive \
		-scheme time-shifty \
		-configuration Release \
		-archivePath release_build/time-shifty.xcarchive
	@echo "✅ 归档完成: release_build/time-shifty.xcarchive"
