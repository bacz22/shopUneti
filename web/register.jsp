<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng ký tài khoản</title>
    <%@include file="Components/common_css_js.jsp"%>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', sans-serif;
        }
        .register-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 20px 0;
        }
        .register-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            overflow: hidden;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
        }
        .card-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 30px 20px;
            text-align: center;
        }
        .card-header img {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            border: 5px solid rgba(255,255,255,0.3);
            margin-bottom: 15px;
            object-fit: cover;
        }
        .card-header h3 {
            margin: 0;
            font-weight: 700;
            font-size: 28px;
            letter-spacing: 1px;
        }
        .form-control, .form-select {
            border-radius: 12px;
            padding: 12px 15px 12px 45px;
            border: 2px solid #e0e0e0;
            transition: all 0.3s ease;
            height: 50px;
        }
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            transform: translateY(-2px);
        }
        .input-group-text {
            position: absolute;
            left: 8px;
            top: 57px;
            transform: translateY(-50%);
            z-index: 10;
            background: transparent;
            border: none;
            color: #667eea;
            pointer-events: none;
        }
        .form-group {
            position: relative;
            margin-bottom: 1.2rem;
        }
        .btn-register {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 14px 40px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.4s ease;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }
        .btn-register:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(102, 126, 234, 0.5);
        }
        .btn-reset {
            border-radius: 50px;
            padding: 14px 35px;
            font-weight: 600;
        }
        .gender-radio {
            display: flex;
            gap: 25px;
            align-items: center;
            flex-wrap: wrap;
        }
        .gender-radio label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            font-weight: 500;
        }
        .form-check-input:checked {
            background-color: #667eea;
            border-color: #667eea;
        }
        .terms-checkbox label {
            font-size: 14px;
            color: #555;
        }
        .login-link {
            color: #667eea;
            font-weight: 600;
            text-decoration: none;
        }
        .login-link:hover {
            text-decoration: underline;
        }

        /* Icon mắt show/hide password */
        .password-toggle {
            background: transparent;
            border: none;
            color: #888;
            z-index: 10;
            padding: 0 12px;
            margin-top: 18px;
        }
        .password-toggle i {
            font-size: 1.15rem;
            transition: all 0.2s ease;
        }
        .password-toggle:hover i {
            color: #667eea;
        }
        .password-toggle:active i {
            transform: scale(0.9);
        }

        @media (max-width: 768px) {
            .register-card { margin: 10px; }
            .card-header h3 { font-size: 24px; }
            .gender-radio { gap: 15px; }
        }
    </style>
</head>
<body>

<%@include file="Components/navbar.jsp"%>

<div class="register-container">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="register-card">
                    <div class="card-header">
                        <img src="Images/signUp.png" alt="Sign Up">
                        <h3>Đăng Ký Tài Khoản</h3>
                    </div>

                    <div class="card-body p-4">
                        <%@include file="Components/alert_message.jsp"%>

                        <form id="register-form" action="RegisterServlet" method="post">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-user"></i> Họ và tên</label>
                                        <i class="fas fa-user input-group-text"></i>
                                        <input type="text" name="user_name" class = "form-control" placeholder="Nhập họ và tên" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-envelope"></i> Email</label>
                                        <i class="fas fa-envelope input-group-text"></i>
                                        <input type="email" name="user_email" class="form-control" placeholder="you@example.com" required>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-phone"></i> Số điện thoại</label>
                                        <i class="fas fa-phone input-group-text"></i>
                                        <input type="text" name="user_mobile_no" class="form-control" placeholder="0901234567">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-venus-mars"></i> Giới tính</label>
                                        <div class="gender-radio mt-2">
                                            <label><input type="radio" name="gender" value="Male" class="form-check-input" required> <span>Nam</span></label>
                                            <label><input type="radio" name="gender" value="Female" class="form-check-input"> <span>Nữ</span></label>
                                            <label><input type="radio" name="gender" value="Other" class="form-check-input"> <span>Khác</span></label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-12">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-map-marker-alt"></i> Địa chỉ</label>
                                        <i class="fas fa-map-marker-alt input-group-text"></i>
                                        <input type="text" name="user_address" class="form-control" placeholder="Số nhà, đường/phố..." required>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-12">
                                    <div class="form-group">
                                        <label class="form-label"><i class="fas fa-city"></i> Thành phố / Quận</label>
                                        <i class="fas fa-city input-group-text"></i>
                                        <input type="text" name="city" class="form-control" placeholder="TP. Hồ Chí Minh, Hà Nội..." required>
                                    </div>
                                </div>
                            </div>

                            <!-- Mật khẩu -->
                            <div class="form-group">
                                <label class="form-label"><i class="fas fa-lock"></i> Mật khẩu</label>
                                <i class="fas fa-lock input-group-text"></i>
                                <input id="reg_password" type="password" name="user_password" class="form-control" 
                                       placeholder="Tối thiểu 6 ký tự" required minlength="6" autocomplete="new-password">
                                <button type="button" class="password-toggle position-absolute end-0 top-50 translate-middle-y" 
                                        data-target="reg_password">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>

                            <!-- Nhập lại mật khẩu -->
                            <div class="form-group">
                                <label class="form-label"><i class="fas fa-lock-open"></i> Nhập lại mật khẩu</label>
                                <i class="fas fa-lock-open input-group-text"></i>
                                <input id="reg_password_confirm" type="password" name="user_password_confirm" class="form-control" 
                                       placeholder="Nhập lại mật khẩu" required autocomplete="new-password">
                                <button type="button" class="password-toggle position-absolute end-0 top-50 translate-middle-y" 
                                        data-target="reg_password_confirm">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <small id="password-error" class="text-danger d-none">Mật khẩu chưa khớp.</small>
                            </div>

                            <div class="form-check terms-checkbox mb-4">
                                <input class="form-check-input" type="checkbox" id="terms" required>
                                <label class="form-check-label" for="terms">
                                    Tôi đồng ý với <a href="#" style="color:#667eea; text-decoration:underline;">Điều khoản dịch vụ</a> và 
                                    <a href="#" style="color:#667eea; text-decoration:underline;">Chính sách bảo mật</a>
                                </label>
                            </div>

                            <div class="text-center">
                                <button type="submit" class="btn btn-register me-3">
                                    <i class="fas fa-user-plus"></i> Đăng Ký Ngay
                                </button>
                                <button type="reset" class="btn btn-outline-secondary btn-reset">
                                    <i class="fas fa-undo"></i> Nhập lại
                                </button>
                            </div>

                            <div class="text-center mt-4">
                                <p class="mb-0">Đã có tài khoản? 
                                    <a href="login.jsp" class="login-link">Đăng nhập ngay</a>
                                </p>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@include file="Components/footer.jsp"%>

<script>
    // Show/Hide Password + Reset icon khi ô trống
    document.querySelectorAll('.password-toggle').forEach(btn => {
        const targetId = btn.getAttribute('data-target');
        const input = document.getElementById(targetId);
        const icon = btn.querySelector('i');

        // Hàm reset icon về "mắt nhắm" (fa-eye) khi input rỗng
        const resetIconIfEmpty = () => {
            if (input.value === '') {
                input.type = 'password';           // chắc chắn là password
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        };

        // Sự kiện click để toggle
        btn.addEventListener('click', function () {
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        });

        // Theo dõi việc nhập/xóa để reset icon khi ô trống
        input.addEventListener('input', resetIconIfEmpty);
        
        // Đảm bảo icon đúng ngay từ đầu (trường hợp người dùng reload trang)
        resetIconIfEmpty();
    });

    // === Phần kiểm tra mật khẩu trùng khớp (giữ nguyên, chỉ cải thiện một chút) ===
    const form = document.getElementById('register-form');
    const password = document.getElementById('reg_password');
    const confirmPwd = document.getElementById('reg_password_confirm');
    const errorMsg = document.getElementById('password-error');

    const checkPasswordMatch = () => {
        if (confirmPwd.value && password.value !== confirmPwd.value) {
            errorMsg.classList.remove('d-none');
        } else {
            errorMsg.classList.add('d-none');
        }
    };

    password.addEventListener('input', checkPasswordMatch);
    confirmPwd.addEventListener('input', checkPasswordMatch);

    form.addEventListener('submit', e => {
        if (password.value !== confirmPwd.value) {
            e.preventDefault();
            errorMsg.classList.remove('d-none');
            confirmPwd.focus();
        }
    });
</script>

</body>
</html>