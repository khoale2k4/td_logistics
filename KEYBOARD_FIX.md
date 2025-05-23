# Keyboard Display Fix

## Vấn đề
App không hiển thị bàn phím khi người dùng tap vào TextField.

## Nguyên nhân
1. **Hardware Acceleration bị tắt** trong AndroidManifest.xml
2. **Thiếu cấu hình keyboard** trong TextField properties
3. **Conflict giữa focus handling** và system keyboard

## Giải pháp đã thực hiện

### 1. Sửa AndroidManifest.xml
```xml
<!-- Trước -->
android:hardwareAccelerated="false"
android:configChanges="orientation|screenSize|smallestScreenSize|screenLayout|density|uiMode"

<!-- Sau -->
android:hardwareAccelerated="true"
android:configChanges="orientation|screenSize|smallestScreenSize|screenLayout|density|uiMode|keyboard|keyboardHidden"
```

### 2. Cấu hình TextField properties
Thêm các properties sau cho tất cả TextField:
```dart
TextField(
  keyboardType: TextInputType.text, // hoặc email, phone, number
  textInputAction: TextInputAction.next, // hoặc done
  autofocus: false, // hoặc true cho field đầu tiên
  enableSuggestions: true,
  autocorrect: true,
  // ... other properties
)
```

### 3. Tạo CustomTextField widget
Widget này tự động:
- Force keyboard hiển thị khi focus
- Cấu hình keyboard type phù hợp
- Handle focus events đúng cách

### 4. Sử dụng KeyboardHelper utility
```dart
import 'package:tdlogistic_v2/core/helpers/map_helpers.dart';

// Force show keyboard
KeyboardHelper.showKeyboard();

// Focus và show keyboard
KeyboardHelper.focusAndShowKeyboard(context, focusNode);
```

## Files đã sửa
- `android/app/src/main/AndroidManifest.xml`
- `lib/auth/UI/screens/customer_login_page.dart`
- `lib/auth/UI/screens/shipper_login_page.dart`
- `lib/auth/UI/screens/OTP_verification.dart`
- `lib/shipper/UI/widgets/search_bar.dart`
- `lib/core/helpers/map_helpers.dart` (thêm KeyboardHelper)
- `lib/core/widgets/custom_text_field.dart` (widget mới)

## Kiểm tra
1. Build và run app: `flutter run -d <device_id>`
2. Tap vào bất kỳ TextField nào
3. Bàn phím sẽ hiển thị ngay lập tức
4. Keyboard type sẽ phù hợp với loại input (email, phone, text, number)

## Best Practices
1. **Luôn chỉ định keyboardType** phù hợp
2. **Sử dụng textInputAction** để navigation giữa fields
3. **Set autofocus=true** cho field đầu tiên trong form
4. **Sử dụng CustomTextField** cho consistent behavior
5. **Test trên real device** không chỉ emulator 