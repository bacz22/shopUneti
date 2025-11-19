<%@page import="java.util.Random"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<meta charset="UTF-8">
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Quên Mật Khẩu</title>
<%@include file="Components/common_css_js.jsp"%>
<style>
body {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

.forgot-password-container {
	min-height: calc(100vh - 60px);
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.forgot-password-card {
	background: #ffffff;
	border-radius: 20px;
	box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
	padding: 40px;
	max-width: 480px;
	width: 100%;
	animation: slideUp 0.5s ease-out;
}

@keyframes slideUp {
	from {
		opacity: 0;
		transform: translateY(30px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

.icon-wrapper {
	width: 120px;
	height: 120px;
	margin: 0 auto 30px;
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
	animation: pulse 2s infinite;
}

@keyframes pulse {
	0%, 100% {
		transform: scale(1);
	}
	50% {
		transform: scale(1.05);
	}
}

.icon-wrapper img {
	width: 70px;
	height: 70px;
	filter: brightness(0) invert(1);
}

.card-title {
	color: #333;
	font-weight: 700;
	font-size: 28px;
	margin-bottom: 10px;
	text-align: center;
}

.card-subtitle {
	color: #666;
	font-size: 14px;
	text-align: center;
	margin-bottom: 30px;
}

.form-label {
	font-weight: 600;
	color: #333;
	margin-bottom: 8px;
	font-size: 14px;
}

.form-control {
	border: 2px solid #e0e0e0;
	border-radius: 10px;
	padding: 12px 16px;
	font-size: 15px;
	transition: all 0.3s ease;
}

.form-control:focus {
	border-color: #667eea;
	box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
	outline: none;
}

.btn-submit {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	border: none;
	border-radius: 10px;
	padding: 12px 40px;
	font-weight: 600;
	font-size: 16px;
	color: white;
	width: 100%;
	transition: all 0.3s ease;
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.btn-submit:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
	background: linear-gradient(135deg, #5568d3 0%, #6a3f8f 100%);
}

.btn-submit:active {
	transform: translateY(0);
}

.back-to-login {
	text-align: center;
	margin-top: 25px;
}

.btn-back {
	background: transparent;
	border: 2px solid #667eea;
	border-radius: 10px;
	padding: 10px 30px;
	font-weight: 600;
	font-size: 15px;
	color: #667eea;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	transition: all 0.3s ease;
	width: 100%;
}

.btn-back:hover {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
	color: white;
	border-color: transparent;
	transform: translateY(-2px);
	box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-back:active {
	transform: translateY(0);
}

.input-group-icon {
	position: relative;
}

.input-group-icon i {
	position: absolute;
	left: 15px;
	top: 50%;
	transform: translateY(-50%);
	color: #999;
	z-index: 10;
}

.input-group-icon .form-control {
	padding-left: 45px;
}
</style>
</head>
<body>
	<!--navbar -->
	<%@include file="Components/navbar.jsp"%>

	<div class="forgot-password-container">
		<div class="forgot-password-card">
			<div class="icon-wrapper">
				<img src="Images/forgot-password.png" alt="Forgot Password">
			</div>
			
			<h2 class="card-title">Quên Mật Khẩu?</h2>
			<p class="card-subtitle">Nhập email của bạn để nhận mã xác thực đặt lại mật khẩu</p>
			
			<%@include file="Components/alert_message.jsp"%>

			<!--change password-->
			<form action="ChangePasswordServlet" method="post">
				<div class="mb-4">
					<label class="form-label">
						<i class="fas fa-envelope me-2"></i>Địa chỉ Email
					</label>
					<div class="input-group-icon">
						<i class="fas fa-envelope"></i>
						<input type="email" name="email" placeholder="Nhập email của bạn" 
							class="form-control" required autocomplete="email">
					</div>
				</div>
				
				<button type="submit" class="btn btn-submit">
					<i class="fas fa-paper-plane me-2"></i>Gửi Mã Xác Thực
				</button>
			</form>
			
			<div class="back-to-login">
				<a href="login.jsp" class="btn btn-back">
					<i class="fas fa-arrow-left me-2"></i>Quay lại đăng nhập
				</a>
			</div>
		</div>
	</div>
</body>
<%@include file="Components/footer.jsp"%>
</html>