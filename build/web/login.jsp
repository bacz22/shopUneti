<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Đăng Nhập</title>
        <%@include file="Components/common_css_js.jsp"%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .login-container {
                min-height: 100vh;
                display: flex;
                align-items: center;
                padding: 20px 0;
            }
            .login-card {
                max-width: 420px;
                width: 100%;
                margin: 0 auto;
                background: rgba(255, 255, 255, 0.97);
                border-radius: 20px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.2);
                overflow: hidden;
                backdrop-filter: blur(12px);
                border: 1px solid rgba(255,255,255,0.3);
            }
            .card-header {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                text-align: center;
                padding: 35px 20px;
            }
            .card-header img {
                width: 85px;
                height: 85px;
                border-radius: 50%;
                border: 5px solid rgba(255,255,255,0.3);
                object-fit: cover;
                margin-bottom: 10px;
            }
            .card-header h3 {
                margin: 0;
                font-weight: 700;
                font-size: 27px;
                letter-spacing: 0.8px;
            }
            .card-body {
                padding: 40px 35px;
            }
            .form-group {
                position: relative;
                margin-bottom: 1.5rem;
            }
            .form-control {
                height: 52px;
                padding: 12px 15px 12px 50px;
                border-radius: 14px;
                border: 2px solid #e0e0e0;
                font-size: 15px;
                transition: all 0.3s ease;
            }
            .form-control:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 0.25rem rgba(102, 126, 234, 0.25);
                transform: translateY(-2px);
            }
            .input-icon {
                position: absolute;
                left: 15px;
                top: 57px;
                transform: translateY(-50%);
                color: #667eea;
                font-size: 18px;
                z-index: 5;
                pointer-events: none;
            }
            .btn-login {
                height: 52px;
                font-size: 17px;
                font-weight: 600;
                border-radius: 50px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                border: none;
                box-shadow: 0 8px 20px rgba(102,126,234,0.4);
                transition: all 0.4s;
                width: 100%;
            }
            .btn-login:hover {
                transform: translateY(-3px);
                box-shadow: 0 15px 30px rgba(102,126,234,0.5);
            }
            .extra-links a {
                color: #667eea;
                font-weight: 600;
                text-decoration: none;
            }
            .extra-links a:hover {
                text-decoration: underline;
            }

            /* Ẩn icon con mắt mặc định của trình duyệt (Edge/Chrome) để không bị 2 icon đè nhau */
            input::-ms-reveal,
            input::-ms-clear {
                display: none;
            }

            /* === CSS Nút ẩn hiện mật khẩu ĐÃ CĂN CHỈNH === */
            .password-toggle {
                position: absolute;
                right: 15px;

                /* CĂN GIỮA: Dùng thông số y hệt icon cái khóa bên trái (.input-icon) */
                top: 42px;
                background: transparent;
                border: none;
                color: #888;
                z-index: 10;
                padding: 10px; /* Tăng vùng bấm cho dễ thao tác trên điện thoại */
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .password-toggle:focus {
                outline: none;
            }

            .password-toggle i {
                font-size: 1.1rem;
                transition: color 0.3s ease;
            }

            .password-toggle:hover i {
                color: #667eea;
            }

            .text-center a {
                color: #667eea;
                font-weight: 600;
            }
            .text-center a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <%@include file="Components/navbar.jsp"%>

        <div class="login-container">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-12">
                        <div class="login-card">
                            <div class="card-header">
                                <img src="Images/login.png" alt="Login">
                                <h3>Chào Mừng Trở Lại</h3>
                            </div>
                            <div class="card-body">
                                <%@include file="Components/alert_message.jsp"%>

                                <form action="LoginServlet" method="post">
                                    <input type="hidden" name="login" value="user">

                                    <!-- Email -->
                                    <div class="form-group">
                                        <label class="form-label mb-2">Email</label>
                                        <i class="fas fa-envelope input-icon"></i>
                                        <input type="email" name="user_email" class="form-control" placeholder="you@example.com" required>
                                    </div>

                                    <!-- Mật khẩu -->
                                    <div class="form-group">
                                        <label class="form-label mb-2">Mật khẩu</label>
                                        <i class="fas fa-lock input-icon"></i>
                                        <input id="login_password" type="password" name="user_password" class="form-control"
                                               placeholder="Nhập mật khẩu" required autocomplete="current-password">

                                        <button type="button" class="password-toggle" onclick="togglePasswordVisibility()">
                                            <i class="fas fa-eye" id="toggleIcon"></i>
                                        </button>
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-login">
                                        <i class="fas fa-sign-in-alt me-2"></i>Đăng Nhập
                                    </button>
                                </form>

                                <div class="extra-links mt-4 text-center">
                                    <a href="forgot_password.jsp">Quên mật khẩu?</a>
                                </div>

                                <div class="text-center mt-4">
                                    Chưa có tài khoản? <a href="register.jsp">Đăng ký ngay</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@include file="Components/footer.jsp"%>

        <script>
            function togglePasswordVisibility() {
                const passwordInput = document.getElementById('login_password');
                const toggleIcon = document.getElementById('toggleIcon');

                // Kiểm tra loại input hiện tại
                if (passwordInput.type === 'password') {
                    passwordInput.type = 'text'; // Hiện mật khẩu
                    toggleIcon.classList.remove('fa-eye');
                    toggleIcon.classList.add('fa-eye-slash'); // Đổi icon thành mắt gạch chéo
                } else {
                    passwordInput.type = 'password'; // Ẩn mật khẩu
                    toggleIcon.classList.remove('fa-eye-slash');
                    toggleIcon.classList.add('fa-eye'); // Đổi lại icon mắt thường
                }
            }
        </script>
    </body>
</html>