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
        }

        .card-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-align: center;
            padding: 30px 20px;
        }

        .card-header img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 5px solid rgba(255,255,255,0.3);
            object-fit: cover;
        }

        .card-header h3 {
            margin: 15px 0 0;
            font-weight: 700;
            font-size: 26px;
            letter-spacing: 0.5px;
        }

        .card-body {
            padding: 40px 35px;
        }

        .form-group {
            position: relative;
            margin-bottom: 20px;
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
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #667eea;
            font-size: 18px;
            z-index: none;
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

        .extra-links {
            text-align: center;
            margin-top: 25px;
        }

        .extra-links a {
            color: #667eea;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
        }

        .extra-links a:hover {
            text-decoration: underline;
        }

        .divider {
            margin: 20px 0;
            color: #888;
            font-size: 14px;
        }

        /* Hiển thị thông báo thành công từ register */
        .alert {
            border-radius: 12px;
            font-weight: 500;
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

                        <!-- Hiển thị thông báo từ RegisterServlet hoặc LoginServlet -->
                        <%@include file="Components/alert_message.jsp"%>

                        <form action="LoginServlet" method="post">
                            <input type="hidden" name="login" value="user">

                            <div class="form-group">
                                <label class="form-label mb-2">Email</label>
                                <div class="position-relative">
                                    <i class="fas fa-envelope input-icon"></i>
                                    <input type="email" name="user_email" class="form-control" 
                                           placeholder="you@example.com" required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label mb-2">Mật khẩu</label>
                                <div class="position-relative">
                                    <i class="fas fa-lock input-icon"></i>
                                    <input type="password" name="user_password" class="form-control" 
                                           placeholder="Nhập mật khẩu" required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary btn-login mt-3">
                                Đăng Nhập
                            </button>
                        </form>

                        <div class="extra-links mt-4">
                            <a href="forgot_password.jsp">Quên mật khẩu?</a>
                        </div>
                        <div class="text-center">
                            <span>Chưa có tài khoản? </span>
                            <a href="register.jsp">Đăng ký ngay</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@include file="Components/footer.jsp"%>
</body>
</html>