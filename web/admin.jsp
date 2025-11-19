<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page errorPage="error_exception.jsp"%>
<%
    Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
    if (activeAdmin == null) {
        Message message = new Message("Bạn chưa đăng nhập! Vui lòng đăng nhập trước!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("adminlogin.jsp");
        return;
    }
    
    // Lấy tham số 'page' từ URL để biết cần hiện nội dung gì
    String pageParam = request.getParameter("page");
    if(pageParam == null) {
        pageParam = "dashboard"; // Mặc định là dashboard
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard | UnetiShop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    
    <style>
        :root { --sidebar-width: 260px; --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        body { background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        .admin-wrapper { display: flex; min-height: 100vh; }
        
        /* Sidebar Styles */
        .sidebar { width: var(--sidebar-width); background: var(--primary-gradient); color: white; position: fixed; top: 0; left: 0; height: 100vh; z-index: 1000; display: flex; flex-direction: column; }
        .sidebar-header { padding: 25px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); font-size: 1.4rem; font-weight: 800; }
        .admin-profile { padding: 30px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .admin-avatar { width: 80px; height: 80px; border-radius: 50%; background: white; padding: 3px; margin-bottom: 10px; }
        .sidebar-menu { padding: 20px 0; flex-grow: 1; overflow-y: auto; }
        .menu-item { display: flex; align-items: center; padding: 12px 25px; color: rgba(255,255,255,0.8); text-decoration: none; transition: all 0.3s; font-weight: 500; }
        .menu-item:hover, .menu-item.active { background: rgba(255,255,255,0.1); color: white; border-left: 4px solid #fff; }
        .menu-item i { width: 25px; margin-right: 10px; }
        
        /* Main Content */
        .main-content { margin-left: var(--sidebar-width); flex-grow: 1; padding: 30px; }
        
        /* Stats Cards Styles (Chỉ dùng cho Dashboard) */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; }
        .stat-card { background: white; border-radius: 16px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); display: flex; align-items: center; justify-content: space-between; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .bg-cat { background: rgba(17, 153, 142, 0.1); color: #11998e; }
    </style>
</head>
<body>

<div class="admin-wrapper">
    
    <nav class="sidebar">
        <div class="sidebar-header"><i class="fas fa-store me-2"></i> UnetiShop</div>
        <div class="admin-profile">
            <img src="Images/admin.png" class="admin-avatar" alt="Admin">
            <h6 class="mb-0 mt-2"><%= activeAdmin.getName() %></h6>
        </div>

        <div class="sidebar-menu">
            <a href="admin.jsp?page=dashboard" class="menu-item <%= pageParam.equals("dashboard") ? "active" : "" %>">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a href="admin.jsp?page=category" class="menu-item <%= pageParam.equals("category") ? "active" : "" %>">
                <i class="fas fa-th-large"></i> Quản lý Danh mục
            </a>
            <a href="admin.jsp?page=products" class="menu-item <%= pageParam.equals("products") ? "active" : "" %>">
                <i class="fas fa-box-open"></i> Quản lý Sản phẩm
            </a>
            <a href="admin.jsp?page=orders" class="menu-item <%= pageParam.equals("orders") ? "active" : "" %>">
                <i class="fas fa-shopping-cart"></i> Quản lý Đơn hàng
            </a>
            <a href="admin.jsp?page=users" class="menu-item <%= pageParam.equals("users") ? "active" : "" %>">
                <i class="fas fa-users"></i> Quản lý Người dùng
            </a>
        </div>
        <div class="p-3">
            <a href="LogoutServlet?user=admin" class="btn btn-outline-light w-100">Đăng xuất</a>
        </div>
    </nav>

    <main class="main-content">
        <%@include file="Components/alert_message.jsp"%>

        <% 
        // LOGIC ĐIỀU HƯỚNG NỘI DUNG
        if(pageParam.equals("dashboard")) {
        %>
            <h4 class="mb-4 fw-bold text-secondary">Tổng quan hệ thống</h4>
            <div class="stats-grid">
                <div class="stat-card">
                    <div><h5>Danh mục</h5><h3>Quản lý</h3></div>
                    <div class="stat-icon bg-cat"><i class="fas fa-th-large"></i></div>
                </div>
                </div>
        
        <% } else if(pageParam.equals("category")) { %>
            
            <jsp:include page="display_category.jsp" />
            
        <% } else if(pageParam.equals("products")) { %>
            
             <jsp:include page="display_products.jsp" />
             
        <% } else if(pageParam.equals("orders")) { %>
             <div class="alert alert-info">Trang quản lý đơn hàng (Chưa include)</div>
        <% } %>

    </main>
</div>

</body>
</html>