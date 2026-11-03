# QUIZAPP — FRONTEND MD2 + MD3 KHỚP BÁO CÁO

**Bản nền:** `quizapp-main.zip` (Flutter hiện có của nhóm). **Mã MD2–MD3:** từ bộ đã sửa `Quiz_Mobile_M02_M03_SUA_BACK.zip`.

Đối chiếu theo **Hình 5, 6, 7, 8, trang 19–22** của `02-Lưu Đức Anh - Game thi trắc nghiệm nhanh.pdf`. Giao diện trong PDF là wireframe; ưu tiên lớp, phương thức và thứ tự gọi.

## Chạy trên máy có Flutter

```powershell
cd quizapp-main
flutter pub get
flutter analyze
flutter test
flutter run
```

Mặc định ứng dụng dùng backend `https://quiz-mobile-backend.onrender.com` từ frontend cũ (không xác nhận server đang hoạt động). Để chạy với Django/PostgreSQL trên PC và giả lập Android:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Backend PC cần `python manage.py runserver 0.0.0.0:8000`, PostgreSQL và `ALLOWED_HOSTS` phù hợp. **10.0.2.2 chỉ dành cho Android Emulator**; điện thoại thật đổi thành IP LAN PC (hai thiết bị chung mạng). Đã bật `INTERNET` và cleartext HTTP trong AndroidManifest phục vụ demo local; nên bỏ cleartext trước khi phát hành.

## MD2 — Hình 5–6 (ONLINE)

1. Home → `LeaderboardPage.load()` → `LeaderboardApi.getRanking(limit,offset)` → Django `LeaderboardView.get()` → query PostgreSQL → `showRanking()`.
2. Chọn người chơi → `PlayerStatisticsPage.load(id)` → `getStats(id)` → Django `UserStatsView.get()` → `showStats()`.
3. Xem lịch sử → `MatchHistoryPage.load(id,limit,offset)` → `getMatches(...)` → Django `UserMatchesView.get()` → `showHistory()`; quay lại thống kê rồi BXH.

API: `/leaderboard/leaderboard/?limit=50&offset=0`, `/leaderboard/users/{id}/stats/`, `/leaderboard/users/{id}/matches/?limit=20&offset=0`. Backend xếp hạng tổng điểm giảm, TB điểm đối thủ giảm, TB thời gian thắng tăng; chỉ tính trận `finished` ở phần thống kê/lịch sử. Lỗi mạng, bảng rỗng và phân trang đều có xử lý UI.

## MD3 — Hình 7–8 (OFFLINE)

1. Home → `BotSetupPage` → chọn easy/medium/hard → `BotGameController.startMatch()` → `QuestionDAO.pickQuestions(10)` trên SQLite → `generateBot()` → `MatchDAO.createMatch()` → `BotQuizPage`.
2. Làm bài → `selectAnswer(order,optionId)` giữ đáp án trong bộ nhớ, cho phép đổi câu; nộp bài/hết 60 giây → `finishMatch(reason)` → `evaluateOutcome()` → `MatchDAO.saveResult()` → `BotResultPage`.
3. Back khi trận chưa xong → hộp xác nhận → lưu `abandoned`, không chấm điểm; về chọn độ khó. Nếu SQLite lưu kết quả thất bại, giữ nguyên dữ liệu đã chấm, hiện nút **Thử lưu kết quả**, không hiển thị thành công giả.

Câu hỏi có sẵn: `assets/questions_seed.json`, 36 câu **demo** (không phải ngân hàng thật của nhóm). Dùng `sqflite` tạo 6 bảng local `questions`, `question_options`, `matches`, `match_questions`, `match_participants`, `match_answers`. Không gửi trận BOT lên Django và **không đổi điểm BXH online**.

BOT trả lời đúng mỗi câu với xác suất easy **55%**, medium **75%**, hard **92%**. Luật trong source: một bên thắng nếu đúng **10/10** mà bên kia không đúng 10/10; nếu cả hai 10/10 thì nhanh hơn thắng; nếu cả hai đều không hoàn hảo thì hòa, kể cả 8/10 so với 6/10. Điểm thắng 1, hòa 0.5, thua 0.

## Điểm tích hợp đã sửa

- `HomePage.dart` giữ nút luyện tập của nhóm, thêm nút MD2 và MD3.
- `lib/app_config.dart`: URL dùng chung cho đăng nhập và MD2; `user_controller.dart` chỉ thay URL cứng thành config, **không đổi logic đăng nhập MD1**.
- `BotResultPage` nút **Trang chủ** quay đúng Home, không quay nhầm Login nằm dưới trong stack.
- Trận BOT chỉ chuyển kết quả khi SQLite lưu thành công; có đường retry và chấm đúng một lần.
- Thêm dependencies `http`, `sqflite`, `path`; khai báo asset local; thêm quyền INTERNET Android.
- Copy 3 nhóm test MD2–MD3 và thay test counter mặc định bằng test đường vào Home.

## Trước khi demo

- Đăng nhập → MD2 → chọn player → thống kê → lịch sử → back.
- MD3 **tắt mạng** sau khi đăng nhập: chọn độ khó → nộp bài → kết quả; thử 60 giây; thử Back và về Home.
- Chạy `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run` thật trên máy. **Môi trường dựng ZIP không có Flutter/Dart SDK và PostgreSQL đang chạy**, nên chưa xác nhận build APK hoặc kết quả live API.
- Nếu giao diện đã đăng nhập nhưng MD2 báo lỗi: kiểm tra backend cùng URL, kết nối mạng, PostgreSQL và dữ liệu của `users`/`matches`.

**Phạm vi:** chỉ triển khai/tích hợp MD2–MD3. Các file practice không sửa. M01 không viết lại; chỉ trỏ URL login đến cùng server để tránh truy cập lệch database khi demo local.

## Cập nhật khớp báo cáo (bản "code front end")

- **MD2 (Hình 5, GD02):** thuộc tính đổi theo sơ đồ `userId`, `inLimit`, `inOffset`, `outRanking`, `outStatistics`, `outHistory`; giữ `load()`, `load(id)`, `load(id, limit, offset)`. Bảng xếp hạng có dòng "Số dòng / Trang", chọn dòng rồi bấm **Chọn người chơi**, các nút Tải lại, Trang trước/sau, Trang chủ (về Home, không về Login). Thống kê hiện "Người chơi: …", Số trận/Thắng/Hòa/Thua/TG thắng trung bình, nút Xem lịch sử + Trở lại bảng xếp hạng. Lịch sử hiển thị kiểu "#101 Player02 Thắng 1.0 / Đúng 10/10 · 20 giây / Kết thúc".
- **MD3 (Hình 1, ERD):** SQLite cục bộ lên version 2 (tự nâng cấp từ v1) có đủ cột `player1_id`, `player2_id`, `opponent_type`, `current_question_index`, `updated_at`, `match_questions.started_at`, `match_participants.user_id/submitted_at`, `match_answers.answered_at`. HomePage truyền `user_id` của người đăng nhập vào `BotSetupPage` → lưu ở `player1_id` và P1 `user_id`; BOT để NULL.
- Màn kết quả: "Người chơi thắng / thua / Hòa", điểm "+1", "+0.5", "+0".
- Không sửa logic đăng nhập MD1 và chức năng luyện tập.
