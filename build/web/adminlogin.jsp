<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Login</title>
    <%@include file="Components/common_css_js.jsp"%>
    
    <style>
        body {
            background: linear-gradient(-135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            max-width: 420px;
            width: 100%;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .card-header-custom {
            background: linear-gradient(135deg, #667eea, #764ba2);
            padding: 40px 30px;
            text-align: center;
            color: white;
        }
        
        .admin-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: white;
            padding: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            margin-bottom: 20px;
        }
        
        .card-header-custom h3 {
            margin: 0;
            font-weight: 600;
            font-size: 28px;
            letter-spacing: 1px;
        }
        
        .card-header-custom p {
            margin: 10px 0 0;
            opacity: 0.9;
            font-size: 15px;
        }
        
        .card-body {
            padding: 40px 35px;
        }
        
        .form-control {
            border-radius: 12px;
            padding: 12px 16px;
            border: 1px solid #ddd;
            transition: all 0.3s ease;
            font-size: 15px;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }
        
        .form-label {
            font-weight: 600;
            color: #444;
            margin-bottom: 8px;
        }
        
        .btn-login {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
            border-radius: 12px;
            padding: 12px 30px;
            font-weight: 600;
            font-size: 16px;
            letter-spacing: 0.5px;
            transition: all 0.3s ease;
            text-transform: uppercase;
        }
        
        .btn-login:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }
        
        .input-group-text {
            border-radius: 12px 0 0 12px;
            background: #f8f9fa;
            border: 1px solid #ddd;
            border-right: none;
        }
        
        /* Hiệu ứng sóng khi load */
        .login-card {
            animation: fadeInUp 0.8s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
<%@include file="Components/navbar.jsp"%>
<div class="login-container">
    <div class="login-card">
        <!-- Header -->
        <div class="card-header-custom">
            <img src="Images/admin.png" alt="Admin" class="admin-avatar img-fluid">
            <h3>Admin Portal</h3>
            <p>Đăng nhập để quản trị hệ thống</p>
        </div>

        <!-- Body -->
        <div class="card-body">
            <%@include file="Components/alert_message.jsp"%>

            <form id="login-form" action="LoginServlet" method="post">
                <input type="hidden" name="login" value="admin">

                <div class="mb-4">
                    <label class="form-label">
                        <i class="fas fa-envelope me-2"></i>Email
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user-shield"></i></span>
                        <input type="email" name="email" class="form-control" 
                               placeholder="nhập email của bạn" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label">
                        <i class="fas fa-lock me-2"></i>Mật khẩu
                    </label>
                    <div class="input-group position-relative">
                        <span class="input-group-text"><i class="fas fa-key"></i></span>
                        <input id="admin_password" type="password" name="password" class="form-control pe-5" 
                               placeholder="nhập mật khẩu" required>
                        <button type="button" class="btn btn-sm password-toggle" data-target="admin_password" aria-label="Hiện/ẩn mật khẩu" aria-pressed="false">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <div class="d-grid mt-5">
                    <button type="submit" class="btn btn-primary btn-login text-white">
                        <i class="fas fa-sign-in-alt me-2"></i>Đăng nhập ngay
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Font Awesome nếu chưa có trong common_css_js.jsp -->
<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
 <%@include file="Components/footer.jsp"%>
</body>
</html>