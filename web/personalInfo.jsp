<%@page import="entities.Message"%>
<%@page import="entities.User"%>
<%@page errorPage="error_exception.jsp"%>
<%
User user1 = (User) session.getAttribute("activeUser");
%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
  <meta charset="UTF-8">
<style>
    label { font-weight: 600; color: #2d3748; }
    .form-control, .form-select {
        border-radius: 12px; padding: 11px 14px; border: 1.5px solid #e2e8f5;
        transition: all 0.2s ease;
    }
    .form-control:focus, .form-select:focus {
        border-color: #667eea; box-shadow: 0 0 0 0.2rem rgba(102,126,234,0.2);
    }
    .btn-primary-custom {
        background: linear-gradient(135deg, #667eea, #764ba2);
        border: none; border-radius: 12px; padding: 10px 30px;
        font-weight: 600; color: white; transition: all 0.3s ease;
    }
    .btn-primary-custom:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 25px rgba(102,126,234,0.3);
    }
    .btn-change-pass {
        background: rgba(102,126,234,0.12); color: #667eea;
        border: 2px dashed #667eea; border-radius: 16px;
        padding: 10px 20px; font-weight: 600; height: 48px;
        transition: all 0.3s ease;
    }
    .btn-change-pass:hover {
        background: rgba(102,126,234,0.2); transform: translateY(-2px);
    }
    .section-title {
        color: #667eea; font-weight: 700; font-size: 1.4rem;
        margin-bottom: 1.5rem; padding-bottom: 10px;
        border-bottom: 2px solid #e2e8f5;
    }
    .password-toggle { cursor: pointer; color: #667eea; }

    /* POPUP */
    .popup-overlay {
        display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;
    }
    .popup-content {
        background: white; border-radius: 20px; width: 90%; max-width: 500px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.2); transform: scale(0.8);
        opacity: 0; transition: all 0.3s ease;
    }
    .popup-overlay.show {
        display: flex;
    }
    .popup-overlay.show .popup-content {
        transform: scale(1); opacity: 1;
    }
    .popup-header {
        padding: 20px 24px 10px; text-align: center;
        border-bottom: 1px solid #eee;
    }
    .popup-close {
        position: absolute; top: 12px; right: 16px;
        background: none; border: none; font-size: 1.5rem; color: #999;
        cursor: pointer;
    }
    .popup-body { padding: 24px; }
</style>

<div class="container px-4 py-4">

    <!-- Thông tin cá nhân -->
    <h3 class="section-title">Thông tin cá nhân</h3>

    <form id="update-user" action="UpdateUserServlet" method="post" class="mb-5">
        <input type="hidden" name="operation" value="updateUser">

        <div class="row g-4">
            <div class="col-md-6">
                <label class="form-label">Họ và tên</label>
                <input type="text" name="name" class="form-control"
                       value="<%=user1.getUserName()%>" required>
            </div>
            <div class="col-md-6">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control"
                       value="<%=user1.getUserEmail()%>" required>
            </div>

            <div class="col-md-6">
                <label class="form-label">Số điện thoại</label>
                <input type="text" name="mobile_no" class="form-control"
                       value="<%=user1.getUserPhone() != null ? user1.getUserPhone() : ""%>">
            </div>

            <div class="col-md-6">
                <label class="form-label d-block">Giới tính</label>
                <div class="mt-2">
                    <input class="form-check-input" type="radio" name="gender" value="Male"
                           <%= "Male".equals(user1.getUserGender()) ? "checked" : "" %>>
                    <label class="form-check-label me-4">Nam</label>

                    <input class="form-check-input" type="radio" name="gender" value="Female"
                           <%= "Female".equals(user1.getUserGender()) ? "checked" : "" %>>
                    <label class="form-check-label">Nữ</label>
                </div>
            </div>

            <div class="col-12">
                <label class="form-label">Địa chỉ</label>
                <input type="text" name="address" class="form-control"
                       placeholder="Số nhà, đường, phường/xã..."
                       value="<%=user1.getUserAddress() != null ? user1.getUserAddress() : ""%>">
            </div>

            <!-- Dòng ngang nhau: Thành phố + Nút Đổi mật khẩu -->
            <div class="col-md-6">
                <label class="form-label">Thành phố / Tỉnh</label>
                <input type="text" name="city" class="form-control"
                       value="<%=user1.getUserCity() != null ? user1.getUserCity() : ""%>">
            </div>

            <div class="col-md-6">
                <label class="form-label d-block">&nbsp;</label> 
                <button type="button" id="openPopup" class="btn btn-change-pass w-100">
                    <i class="fas fa-key me-2"></i> Đổi mật khẩu
                </button>
            </div>
        </div>

        <div class="text-center mt-4">
            <button type="submit" class="btn btn-primary-custom me-3">
                Cập nhật thông tin
            </button>
            <button type="reset" class="btn btn-outline-secondary px-4" style="border-radius: 12px;">
                Nhập lại
            </button>
        </div>
    </form>
</div>

<!-- POPUP ĐỔI MẬT KHẨU -->
<div class="popup-overlay" id="passwordPopup">
    <div class="popup-content">
        <div class="popup-header position-relative">
            <h4 class="mb-0" style="color: #667eea; font-weight: 700;">
                Đổi mật khẩu
            </h4>
            <button type="button" class="popup-close" id="closePopup">&times;</button>
        </div>

        <div class="popup-body">
            <form action="ChangePasswordServlet" method="post" id="changePassForm">
                <div class="mb-3">
                    <label class="form-label">Mật khẩu hiện tại</label>
                    <div class="input-group">
                        <input type="password" name="current_password" class="form-control" required>
                        <span class="input-group-text password-toggle">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Mật khẩu mới</label>
                    <div class="input-group">
                        <input type="password" name="new_password" class="form-control" required minlength="6">
                        <span class="input-group-text password-toggle">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Xác nhận mật khẩu mới</label>
                    <div class="input-group">
                        <input type="password" name="confirm_password" class="form-control" required>
                        <span class="input-group-text password-toggle">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>
                    <small class="text-muted">Mật khẩu phải có ít nhất 6 ký tự</small>
                </div>

                <div class="text-center mt-4">
                    <button type="submit" class="btn btn-primary-custom me-3">
                        Xác nhận đổi
                    </button>
                    <button type="button" id="cancelPopup" class="btn btn-outline-secondary px-4" style="border-radius: 12px;">
                        Hủy bỏ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const popup = document.getElementById('passwordPopup');
    const openBtn = document.getElementById('openPopup');
    const closeBtn = document.getElementById('closePopup');
    const cancelBtn = document.getElementById('cancelPopup');

    openBtn.onclick = () => popup.classList.add('show');
    closeBtn.onclick = cancelBtn.onclick = () => popup.classList.remove('show');

    // Đóng khi bấm ngoài popup
    popup.addEventListener('click', (e) => {
        if (e.target === popup) popup.classList.remove('show');
    });

    // Hiện/ẩn mật khẩu
    document.querySelectorAll('.password-toggle').forEach(toggle => {
        toggle.addEventListener('click', function () {
            const input = this.parentElement.querySelector('input');
            if (input.type === 'password') {
                input.type = 'text';
                this.innerHTML = '<i class="fas fa-eye-slash"></i>';
            } else {
                input.type = 'password';
                this.innerHTML = '<i class="fas fa-eye"></i>';
            }
        });
    });

    // Kiểm tra xác nhận mật khẩu
    document.getElementById('changePassForm').addEventListener('submit', function(e) {
        const newPass = this.new_password.value;
        const confirmPass = this.confirm_password.value;
        if (newPass !== confirmPass) {
            e.preventDefault();
            alert("Mật khẩu xác nhận không khớp!");
            this.confirm_password.focus();
        }
    });
</script>