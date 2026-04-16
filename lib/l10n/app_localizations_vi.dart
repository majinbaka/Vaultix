// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get pmTitle => 'Quản lý mật khẩu';

  @override
  String get pmAddAccount => 'Thêm tài khoản';

  @override
  String get pmSiteName => 'Trang / Ứng dụng';

  @override
  String get pmUsername => 'Tên đăng nhập';

  @override
  String get pmPassword => 'Mật khẩu';

  @override
  String get pmSave => 'Lưu';

  @override
  String get pmCancel => 'Hủy';

  @override
  String get pmDelete => 'Xóa';

  @override
  String get pmEmptyHint => 'Chưa có tài khoản nào. Nhấn + để thêm.';

  @override
  String get pmMasterTitle => 'Kho mật khẩu';

  @override
  String get pmMasterNewHeader => 'Tạo mật khẩu chính';

  @override
  String get pmMasterUnlockHeader => 'Mở khoá kho lưu trữ';

  @override
  String get pmMasterHint => 'Mật khẩu chính';

  @override
  String get pmMasterConfirmHint => 'Xác nhận mật khẩu';

  @override
  String get pmMasterCreate => 'Tạo kho lưu trữ';

  @override
  String get pmMasterUnlock => 'Mở khoá';

  @override
  String get pmMasterMismatch => 'Mật khẩu không khớp';

  @override
  String get pmMasterWrong => 'Sai mật khẩu chính';

  @override
  String get pmMasterTooShort => 'Phải có ít nhất 8 ký tự';

  @override
  String pmLockedOut(int seconds) {
    return 'Nhập sai quá nhiều lần. Thử lại sau ${seconds}s.';
  }

  @override
  String get pmEncryptionInfo => 'Mật khẩu của bạn được mã hóa bằng AES-256-GCM.\nKhóa được tạo từ Argon2id — chỉ bạn mới có thể mở khóa.';

  @override
  String get copiedToClipboard => 'Đã sao chép!';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';
}
