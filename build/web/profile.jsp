<%@page import="entities.Message"%>
<%@page import="entities.User"%>
<%@page errorPage="error_exception.jsp"%>
<%
User activeUser = (User) session.getAttribute("activeUser");
if (activeUser == null) {
	Message message = new Message("You are not logged in! Login first!!", "error", "alert-danger");
	session.setAttribute("message", message);
	response.sendRedirect("login.jsp");
	return;  
}
%>  


<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
  <meta charset="UTF-8">

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tài khoản của tôi</title>
<%@include file="Components/common_css_js.jsp"%>
<%
String sectionParam = request.getParameter("section");
if (sectionParam == null || sectionParam.trim().isEmpty()) {
    sectionParam = "profile";
} else {
    sectionParam = sectionParam.toLowerCase();
    if (!sectionParam.equals("profile") && !sectionParam.equals("wishlist") && !sectionParam.equals("order")) {
        sectionParam = "profile";
    }
}
%>
<style>
    :root {
        --primary: #667eea;
        --primary-dark: #764ba2;
        --card-bg: rgba(255,255,255,0.95);
        --text-muted: #6c757d;
    }
    body {
        background: linear-gradient(135deg, #f4f7fb, #dfe9f3);
        min-height: 100vh;
        font-family: 'Segoe UI', sans-serif;
    }
    .profile-page {
        padding: 32px 0 48px;
    }
    .profile-wrapper {
        max-width: 1200px;
        margin: 0 auto;
    }
    .info-card, .nav-card, .content-card {
        background: var(--card-bg);
        border-radius: 20px;
        padding: 24px 28px;
        box-shadow: 0 18px 35px rgba(0,0,0,0.08);
        border: 1px solid rgba(255,255,255,0.7);
    }
    .avatar-wrapper {
        width: 72px;
        height: 72px;
        border-radius: 18px;
        overflow: hidden;
        margin-right: 16px;
        background: #f0f3ff;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
    .avatar-wrapper img {
        width: 60px;
    }
    .hello-text {
        color: var(--text-muted);
        font-size: 14px;
    }
    .nav-card {
        margin-top: 24px;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    .nav-btn {
        border: 1px solid transparent;
        border-radius: 16px;
        padding: 16px 18px;
        background: rgba(247,248,255,0.8);
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
        transition: all 0.25s ease;
        color: #3c4257;
    }
    .nav-btn i:first-child {
        width: 42px;
        height: 42px;
        border-radius: 12px;
        background: rgba(102,126,234,0.12);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin-right: 12px;
        color: var(--primary);
        font-size: 18px;
    }
    .nav-btn small {
        color: var(--text-muted);
        display: block;
    }
    .nav-btn:hover, .nav-btn.cus-active {
        background: linear-gradient(135deg, rgba(102,126,234,0.15), rgba(118,75,162,0.15));
        border-color: rgba(102,126,234,0.4);
        box-shadow: 0 12px 30px rgba(102,126,234,0.2);
    }
    .logout-btn {
        width: 100%;
        margin-top: 12px;
        border: none;
        border-radius: 16px;
        padding: 14px 0;
        font-weight: 600;
        background: rgba(244,67,54,0.12);
        color: #d84315;
        transition: all 0.2s ease;
    }
    .logout-btn:hover {
        background: rgba(244,67,54,0.2);
    }
    @media (max-width: 991px) {
        .profile-wrapper {
            padding: 0 15px;
        }
        .info-card, .nav-card, .content-card {
            padding: 20px;
        }
    }
</style>
</head>
<body>
	<%@include file="Components/navbar.jsp"%>

	<div class="profile-page">
		<div class="profile-wrapper">
			<div class="row g-4">
				<div class="col-lg-4">
					<div class="info-card mb-4">
						<div class="avatar-wrapper">
							<img src="Images/profile.png" alt="avatar">
						</div>
						<div>
							<p class="hello-text mb-1">Xin chào,</p>
							<h4><%=activeUser.getUserName()%></h4>
							<span class="badge rounded-pill text-bg-light mt-1"><i class="fa fa-envelope me-1"></i><%=activeUser.getUserEmail()%></span>
						</div>
					</div>

					<div class="nav-card">
						<div class="nav-btn cus-active" id="profile-btn">
							<div class="d-flex align-items-center">
								<i class="fas fa-user-circle"></i>
								<div>
									<strong>Thông tin cá nhân</strong>
									<small>Cập nhật tên, email, địa chỉ</small>
								</div>
							</div>
							<i class="fas fa-chevron-right"></i>
						</div>
						<div class="nav-btn" id="wishlist-btn">
							<div class="d-flex align-items-center">
								<i class="fas fa-heart"></i>
								<div>
									<strong>Yêu thích</strong>
									<small>Danh sách sản phẩm bạn lưu</small>
								</div>
							</div>
							<i class="fas fa-chevron-right"></i>
						</div>
						<div class="nav-btn" id="order-btn">
							<div class="d-flex align-items-center">
								<i class="fas fa-box"></i>
								<div>
									<strong>Đơn hàng</strong>
									<small>Theo dõi trạng thái giao hàng</small>
								</div>
							</div>
							<i class="fas fa-chevron-right"></i>
						</div>
						<button class="logout-btn" onclick="window.open('LogoutServlet?user=user', '_self')">
							Đăng xuất <i class="fas fa-sign-out-alt ms-2"></i>
						</button>
					</div>
				</div>

				<div class="col-lg-8">
					<div class="content-card">
						<div id="profile">
							<%@include file="Components/alert_message.jsp"%>
							<%@include file="personalInfo.jsp"%>
						</div>
						<div id="wishlist" style="display:none;">
							<%@include file="wishlist.jsp"%>
						</div>
						<div id="order" style="display:none;">
							<%@include file="order.jsp"%>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script>
		(() => {
			const sections = {
				profile: document.getElementById("profile"),
				wishlist: document.getElementById("wishlist"),
				order: document.getElementById("order"),
			};

			const buttons = {
				profile: document.getElementById("profile-btn"),
				wishlist: document.getElementById("wishlist-btn"),
				order: document.getElementById("order-btn"),
			};

			const showSection = (key) => {
				Object.keys(sections).forEach(section => {
					sections[section].style.display = section === key ? "block" : "none";
				});
				Object.keys(buttons).forEach(btn => {
					if (btn === key) {
						buttons[btn].classList.add("cus-active");
					} else {
						buttons[btn].classList.remove("cus-active");
					}
				});
			};

			const defaultSection = "<%=sectionParam%>";
			const initialSection = sections[defaultSection] ? defaultSection : "profile";
			showSection(initialSection);

			const updateQueryParam = (key, value) => {
				const url = new URL(window.location.href);
				url.searchParams.set("section", key);
				url.searchParams.delete("orderPage");
				url.searchParams.delete("wishPage");
				window.history.replaceState({}, "", url.toString().split("#")[0] + "#" + key);
			};

			Object.keys(buttons).forEach(key => {
				buttons[key].addEventListener("click", () => {
					updateQueryParam(key, 1);
					showSection(key);
				});
			});
		})();
	</script>
<%@include file="Components/footer.jsp"%>        
</body>
</html>
