# Hướng Dẫn Chức Năng Tìm Kiếm Danh Mục

## Tổng Quan
Đã hoàn thành chức năng tìm kiếm danh mục chi tiêu/thu nhập theo từ khóa (nhãn). Người dùng có thể tìm kiếm danh mục bằng các từ khóa tương quan.

## Các Chính Năng Mới

### 1. **Thêm Từ Khóa vào Model Category**
   - Thêm trường `keywords: List<String>` vào model `Category`
   - Cho phép mỗi danh mục có nhiều từ khóa tìm kiếm

### 2. **Cập Nhật Danh Mục Với Từ Khóa**

#### **Chi Tiêu:**
- **Ăn uống**: ăn, uống, đồ ăn, cơm, bún, phở, nhà hàng, quán ăn, cafe, cà phê, bia
- **Mua sắm**: mua, sắm, shopping, hàng, shop
- **Điện thoại**: điện thoại, phone, sim, data, gói cước
- **Giải trí**: giải trí, phim, nhạc, game, ca hát, karaoke, vé xem
- **Giáo dục**: giáo dục, học, sách, khóa học, lớp học, trường
- **Sắc đẹp**: sắc đẹp, mỹ phẩm, cắt tóc, spa, salon, mỹ viện
- **Thể thao**: thể thao, gym, tập, bơi, chạy, yoga
- **Xã hội**: xã hội, hội hè, tiệc, dự tiệc, quà tặng
- **Đi lại**: đi lại, xe buýt, taxi, grab, xăng, bến xe
- **Quần áo**: quần áo, áo, quần, giày, dép
- **Ô tô**: ô tô, xe, xăng, sửa xe, rửa xe
- **Sức khỏe**: sức khỏe, bệnh, thuốc, bác sĩ, bệnh viện, y tế
- **Nhà ở** (MỚI): nhà ở, nhà, tiền nhà, phòng, thuê

#### **Thu Nhập:**
- **Lương**: lương, salary, tiền lương, tính lương
- **Khoản đầu tư**: đầu tư, invest, cổ phiếu, chứng chỉ
- **Làm thêm**: làm thêm, overtime, phụ cấp, thêm giờ
- **Tiền thưởng**: thưởng, bonus, tết, tá lộ
- **Trợ cấp** (MỚI): trợ cấp, allowance, hỗ trợ, cấp dưỡng
- **Khác**: khác, other

### 3. **Thanh Tìm Kiếm Trong Màn Hình Thêm Giao Dịch**
   - Khi chọn tab "Chi tiêu" hoặc "Thu nhập", sẽ hiển thị thanh tìm kiếm
   - Tìm kiếm tức thời khi gõ vào
   - Hiển thị danh mục phù hợp dựa trên từ khóa nhập
   - Nếu không tìm thấy, hiển thị thông báo "Không tìm thấy danh mục"

**Cách sử dụng:**
- Mở màn hình "Thêm" giao dịch
- Chọn tab "Chi tiêu" hoặc "Thu nhập"
- Nhập từ khóa trong ô tìm kiếm (VD: "ăn", "uống", "nhà hàng")
- Chọn danh mục phù hợp từ kết quả

### 4. **Thanh Tìm Kiếm Trong Màn Hình Tìm Kiếm Giao Dịch**
   - Cập nhật dialog chọn danh mục với chức năng tìm kiếm
   - Hiển thị từ khóa dưới mỗi danh mục
   - Tìm kiếm theo tên hoặc từ khóa liên quan

**Cách sử dụng:**
- Mở màn hình "Tìm kiếm"
- Nhấp vào chip "Danh mục"
- Nhập từ khóa để tìm kiếm danh mục
- Chọn danh mục cần lọc

## Files Đã Chỉnh Sửa

1. **[data/models/category.dart](lib/data/models/category.dart)**
   - Thêm trường `keywords: List<String>` vào class `Category`

2. **[core/utils/category_helper.dart](lib/core/utils/category_helper.dart)**
   - Cập nhật danh sách danh mục với từ khóa
   - Thêm danh mục "Nhà ở" (expense)
   - Thêm danh mục "Trợ cấp" (income)
   - Thêm hàm `searchCategoriesByKeyword()` - tìm kiếm theo loại
   - Thêm hàm `searchAllCategoriesByKeyword()` - tìm kiếm tất cả

3. **[core/services/search_service.dart](lib/core/services/search_service.dart)**
   - Thêm hàm `searchCategoriesFromTransactions()` - hỗ trợ tìm kiếm danh mục

4. **[modules/transaction/add_transaction_screen.dart](lib/modules/transaction/add_transaction_screen.dart)**
   - Thêm import `search_service.dart`
   - Thêm widget `_buildCategoryGridWithSearch()` - hiển thị lưới danh mục với tìm kiếm
   - Cập nhật `TabBarView` để sử dụng widget mới

5. **[modules/transaction/search_screen.dart](lib/modules/transaction/search_screen.dart)**
   - Cập nhật `_showCategoryDialog()` với chức năng tìm kiếm
   - Hiển thị từ khóa dưới mỗi danh mục

## Ví Dụ Sử Dụng

### Scenario 1: Thêm giao dịch "Ăn cơm"
1. Nhấn nút "Thêm"
2. Chọn tab "Chi tiêu"
3. Nhập "ăn" trong ô tìm kiếm
4. Kết quả hiển thị danh mục "Ăn uống"
5. Nhấn vào danh mục để nhập số tiền

### Scenario 2: Tìm kiếm theo danh mục "Trợ cấp"
1. Nhấn nút "Tìm kiếm"
2. Nhấn chip "Danh mục"
3. Nhập "trợ cấp" hoặc "allowance"
4. Chọn danh mục "Trợ cấp"
5. Lọc giao dịch theo danh mục này

## Lợi Ích
✅ Dễ dàng tìm kiếm danh mục mà không cần cuộn toàn bộ danh sách
✅ Hỗ trợ tìm kiếm theo từ khóa liên quan (VD: "cafe", "nhà hàng" → "Ăn uống")
✅ Giao diện trực quan với thông báo khi không tìm thấy
✅ Tìm kiếm tức thời khi gõ
✅ Hiển thị từ khóa giúp người dùng hiểu rõ danh mục

## Notes
- Tất cả tìm kiếm đều không phân biệt chữ hoa/chữ thường
- Có thể tìm kiếm theo tên danh mục hoặc bất kỳ từ khóa nào
- Danh sách từ khóa có thể được mở rộng trong tương lai
