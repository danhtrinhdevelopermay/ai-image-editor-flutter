# Hướng dẫn khắc phục lỗi Git Push

## 🔴 Vấn đề hiện tại:
- Git lock files đang chặn việc push
- Cần push code lên GitHub với workflow đã được cải thiện

## ✅ Giải pháp từng bước:

### Bước 1: Mở Terminal trong Replit

Nhấn `Ctrl + Shift + S` hoặc click vào "Shell" tab

### Bước 2: Xóa git lock files

```bash
cd ai_image_editor_flutter
rm -f .git/index.lock
rm -f .git/refs/heads/main.lock
rm -f .git/HEAD.lock
```

### Bước 3: Reset git state

```bash
git reset --soft HEAD
```

### Bước 4: Add và commit thay đổi

```bash
git add .
git commit -m "Update GitHub Actions workflow - Fix gradlew issues"
```

### Bước 5: Push lên GitHub

```bash
git push origin main
```

### 🔧 Nếu vẫn lỗi authentication:

```bash
git remote set-url origin https://YOUR_TOKEN@github.com/danhtrinhdevelopermay/ai-image-editor-flutter.git
git push origin main
```

### 🔧 Nếu vẫn lỗi, thử force push:

```bash
git push --force-with-lease origin main
```

## 🎯 Workflow đã được cải thiện:

- Tự động tạo gradlew file nếu thiếu
- Auto-download gradle-wrapper.jar
- Better error handling
- Build APK sẽ thành công

## 📱 Kết quả mong đợi:

Sau khi push thành công, GitHub Actions sẽ:
- Build APK không còn lỗi "gradlew not found"  
- Tạo release với APK file
- Upload artifacts thành công