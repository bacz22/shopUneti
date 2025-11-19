<%@page import="entities.Admin"%>
<%@page import="entities.Cart"%>
<%@page import="dao.CartDao"%>
<%@page import="entities.User"%>
<%@page import="java.util.List"%>
<%@page import="entities.Category"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.CategoryDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<meta charset="UTF-8">
<%
User user = (User) session.getAttribute("activeUser");
Admin admin = (Admin) session.getAttribute("activeAdmin");

%>

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

.navbar {
	font-weight: 500;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
	transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
	backdrop-filter: blur(10px);
	padding: 1rem 0;
	position: sticky;
	top: 0;
	z-index: 9999 !important;
}

.navbar:hover {
	box-shadow: 0 6px 30px rgba(0, 0, 0, 0.18);
}

.custom-color {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%) !important;
	position: relative;
	overflow: hidden;
}

.custom-color::before {
	content: '';
	position: absolute;
	top: 0;
	left: -100%;
	width: 100%;
	height: 100%;
	background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
	transition: left 0.5s;
}

.custom-color:hover::before {
	left: 100%;
}

.navbar-brand {
	font-weight: 800;
	font-size: 28px;
	transition: all 0.3s ease;
	display: flex;
	align-items: center;
	gap: 8px;
	background: linear-gradient(45deg, #fff, #ffd700);
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
	background-clip: text;
	text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.navbar-brand i {
	-webkit-text-fill-color: white;
	filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3));
	animation: float 3s ease-in-out infinite;
}

@keyframes float {
	0%, 100% { transform: translateY(0px); }
	50% { transform: translateY(-5px); }
}

.navbar-brand:hover {
	transform: scale(1.08);
	filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.5));
}

.nav-link {
	color: rgb(255 255 255 / 95%) !important;
	transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	padding: 10px 18px !important;
	border-radius: 12px;
	margin: 0 4px;
	font-weight: 500;
	position: relative;
	overflow: hidden;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	white-space: nowrap;
}

.nav-link::before {
	content: '';
	position: absolute;
	bottom: 0;
	left: 50%;
	width: 0;
	height: 2px;
	background: white;
	transition: all 0.3s ease;
	transform: translateX(-50%);
}

.nav-link:hover {
	background-color: rgba(255, 255, 255, 0.2) !important;
	transform: translateY(-2px);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.nav-link:hover::before {
	width: 80%;
}

.dropdown-menu {
	background: rgba(255, 255, 255, 0.98) !important;
	backdrop-filter: blur(10px);
	border: none;
	border-radius: 16px;
	box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
	padding: 12px;
	margin-top: 12px;
	animation: slideDown 0.3s ease;
	z-index: 99999 !important;
	position: absolute !important;
}

@keyframes slideDown {
	from {
		opacity: 0;
		transform: translateY(-10px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

.dropdown-item {
	border-radius: 10px;
	padding: 12px 18px;
	transition: all 0.3s ease;
	font-weight: 500;
	color: #333;
	margin: 2px 0;
}

.dropdown-item:hover {
	background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
	color: white !important;
	transform: translateX(8px);
	box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.search-form {
	position: relative;
	display: flex;
	gap: 10px;
}

.search-form .form-control {
	border-radius: 30px;
	padding: 12px 24px;
	border: 2px solid rgba(255, 255, 255, 0.4);
	background-color: rgba(255, 255, 255, 0.95) !important;
	transition: all 0.4s ease;
	font-size: 15px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.search-form .form-control:focus {
	border-color: white;
	box-shadow: 0 0 0 4px rgba(255, 255, 255, 0.3), 0 8px 20px rgba(0, 0, 0, 0.15);
	background-color: white !important;
	transform: translateY(-2px);
}

.search-form .form-control::placeholder {
	color: #999;
	font-weight: 400;
}

.btn-outline-light {
	border-radius: 30px;
	padding: 12px 26px;
	border: 2px solid white;
	transition: all 0.3s ease;
	font-weight: 600;
	background: transparent;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.btn-outline-light:hover {
	background: white;
	color: #667eea;
	transform: translateY(-3px);
	box-shadow: 0 6px 20px rgba(255, 255, 255, 0.4);
	border-color: white;
}

/* Cart badge styling */
.cart-badge {
	position: absolute;
	top: 1px;
	right: 3px;
	font-size: 10px;
	padding: 4px 8px;
	width: 18px;
	height: 18px;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	animation: pulse-badge 2s ease-in-out infinite;
	background: linear-gradient(135deg, #ff416c, #ff4b2b) !important;
	box-shadow: 0 2px 8px rgba(255, 65, 108, 0.6);
	font-weight: 700;
	z-index: 2;
	border-radius: 50px;
}

@keyframes pulse-badge {
	0%, 100% {
		transform: scale(1);
		box-shadow: 0 2px 8px rgba(255, 65, 108, 0.6);
	}
	50% {
		transform: scale(1.15);
		box-shadow: 0 4px 12px rgba(255, 65, 108, 0.8);
	}
}

.navbar-toggler {
	border: 2px solid rgba(255, 255, 255, 0.6);
	border-radius: 12px;
	padding: 8px 12px;
	transition: all 0.3s ease;
}

.navbar-toggler:hover {
	background: rgba(255, 255, 255, 0.1);
	transform: scale(1.05);
}

.navbar-toggler:focus {
	box-shadow: 0 0 0 4px rgba(255, 255, 255, 0.3);
}

.navbar-toggler-icon {
	filter: brightness(0) invert(1);
}

.nav-item {
	display: flex;
	align-items: center;
	position: relative;
	z-index: 10000;
}

.nav-item i {
	transition: transform 0.3s ease;
}

.nav-link:hover i {
	transform: scale(1.2) rotate(5deg);
}

/* Button styling for admin */
.btn.nav-link {
	background: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.3);
	display: inline-flex;
	align-items: center;
	gap: 6px;
	white-space: nowrap;
}

.btn.nav-link:hover {
	background: rgba(255, 255, 255, 0.25);
	border-color: rgba(255, 255, 255, 0.5);
}

/* Enhanced cart icon */
.fa-cart-shopping {
	position: relative;
	display: inline-block;
}

.dropdown-menu {
    opacity: 0;
    visibility: hidden;
    transform: translateY(10px);
    transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    display: block !important; /* Bootstrap vẫn dùng display block khi show */
}

.dropdown-menu.show {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
	z-index: 9999 !important;
	-webkit-transform: translateZ(0);
}

/* Responsive improvements */
@media (max-width: 991px) {
	.navbar-nav {
		padding: 1rem 0;
	}
	
	.nav-link {
		margin: 4px 0;
	}
	
	.search-form {
		margin: 1rem 0;
		flex-direction: column;
	}
	
	.search-form .form-control {
		width: 100%;
	}
	
	.cart-badge {
		top: -5px;
		right: -8px;
	}
}

	/* Smooth transitions for collapsing */
	.navbar-collapse {
		transition: all 0.3s ease;
	}

	/* === FIX DROPDOWN BỊ ẨN DƯỚI CÁC LAYOUT KHÁC === */
	.navbar {
		position: relative; /* đảm bảo navbar là reference cho dropdown */
		z-index: 1055;      /* cao hơn hầu hết các component Bootstrap thông thường */
	}

	.navbar-collapse {
		position: relative;
		z-index: 1055;
	}

	/* Quan trọng nhất: dropdown menu phải có z-index cực cao và position absolute */
	.dropdown-menu {
		z-index: 1060 !important;   /* cao hơn navbar và mọi thứ khác */
		position: absolute !important;
		top: 100% !important;
		left: 0 !important;
		margin-top: 8px !important; /* khoảng cách đẹp với nav item */
	}

	/* Nếu bạn có container/wrapper nào đó bao ngoài navbar và có overflow: hidden */
	.container, .container-fluid, .row, 
	.wrapper, .content-wrapper, header, main, section {
		overflow: visible !important;
	}

	/* Đặc biệt nếu bạn dùng card, carousel, hero section... hay có overflow hidden */
	.card, .carousel, .hero-banner, .banner, .section-wrapper {
		overflow: visible !important;
	}

	/* Fix cho trường hợp navbar nằm trong một div có position relative + overflow hidden */
	.navbar-container,
	.header-wrapper,
	.main-header {
		overflow: visible !important;
		position: static !important; /* hoặc relative nhưng không cắt dropdown */
	}
</style>

<nav class="navbar navbar-expand-lg custom-color" data-bs-theme="dark">
	<%
	if (admin != null) {
	%>
	<div class="container">
		<a class="navbar-brand" href="admin.jsp">
			<i class="fa-sharp fa-solid fa-house"></i>
			<span>UnetiShop</span>
		</a>
		<button class="navbar-toggler" type="button" data-bs-toggle="collapse"
			data-bs-target="#navbarSupportedContent"
			aria-controls="navbarSupportedContent" aria-expanded="false"
			aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarSupportedContent">
			<div class="container text-end">
				<ul class="navbar-nav justify-content-end">
					<li class="nav-item">
						<a class="nav-link" aria-current="page" href="admin.jsp">
							<i class="fa-solid fa-user-shield"></i>
							<span><%=admin.getName()%></span>
						</a>
					</li>
					<li class="nav-item">
						<a class="nav-link" aria-current="page" href="LogoutServlet?user=admin">
							<i class="fa-solid fa-right-from-bracket"></i>
							<span>Đăng Xuất</span>
						</a>
					</li>
				</ul>
			</div>
		</div>
	</div>
	<%
	} else {
	%>

	<div class="container">
		<a class="navbar-brand" href="index.jsp">
			<i class="fa-sharp fa-solid fa-house"></i>
			<span>UnetiShop</span>
		</a>
		<button class="navbar-toggler" type="button" data-bs-toggle="collapse"
			data-bs-target="#navbarSupportedContent"
			aria-controls="navbarSupportedContent" aria-expanded="false"
			aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarSupportedContent">
			<ul class="navbar-nav me-auto mb-2 mb-lg-0">
				<li class="nav-item">
					<a class="nav-link" href="products.jsp">
						<i class="fa-solid fa-box"></i>
						<span>Sản Phẩm</span>
					</a>
				</li>
				
			</ul>
			
			<form class="d-flex pe-5 search-form" role="search" action="products.jsp" method="get">
				<input name="search" class="form-control me-2" size="50"
					type="search" placeholder="Tìm kiếm sản phẩm..." aria-label="Search">
				<button class="btn btn-outline-light" type="submit">
					<i class="fas fa-search"></i>
				</button>
			</form>

			<%
			if (user != null) {
				CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
				int cartCount = cartDao.getCartCountByUserId(user.getUserId());
			%>
			<ul class="navbar-nav ml-auto">
				<li class="nav-item active pe-3">
					<a class="nav-link" aria-current="page" href="cart.jsp" style="position: relative;">
						<i class="fa-solid fa-cart-shopping"></i>
						<span class="cart-badge"><%=cartCount%></span>
					</a>
				</li>
				<li class="nav-item active pe-3">
					<a class="nav-link" aria-current="page" href="profile.jsp">
						<i class="fa-solid fa-user"></i>
						<span><%=user.getUserName()%></span>
					</a>
				</li>
				<li class="nav-item pe-3">
					<a class="nav-link" aria-current="page" href="LogoutServlet?user=user">
						<i class="fa-solid fa-right-from-bracket"></i>
						<span>Đăng Xuất</span>
					</a>
				</li>
			</ul>
			<%
			} else {
			%>
			<ul class="navbar-nav ml-auto">
				<li class="nav-item active pe-2">
					<a class="nav-link" aria-current="page" href="register.jsp">
						<i class="fa-solid fa-user-plus"></i>
						<span>Đăng Ký</span>
					</a>
				</li>
				<li class="nav-item pe-2">
					<a class="nav-link" aria-current="page" href="login.jsp">
						<i class="fa-solid fa-right-to-bracket"></i>
						<span>Đăng Nhập</span>
					</a>
				</li>
				<li class="nav-item pe-2">
					<a class="nav-link" aria-current="page" href="adminlogin.jsp">
						<i class="fa-solid fa-user-shield"></i>
						<span>Quản Trị</span>
					</a>
				</li>
			</ul>
			<%
			}
			%>
		</div>
	</div>
	<%
	}
	%>
</nav>