<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="entities.User"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@page import="dao.UserDao"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%
    // 1. Kiểm tra Admin
    Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
    if (activeAdmin == null) {
        Message message = new Message("Bạn chưa đăng nhập! Vui lòng đăng nhập trước!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    // 2. Lấy dữ liệu & Phân trang
    UserDao userDao = new UserDao(ConnectionProvider.getConnection());
    List<User> fullList = userDao.getAllUser();

    int itemsPerPage = 8; // 8 người dùng mỗi trang
    int totalItems = (fullList != null) ? fullList.size() : 0;
    int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
    
    int currentPage = 1;
    String pageParam = request.getParameter("p");
    if (pageParam != null) {
        try { currentPage = Integer.parseInt(pageParam); } catch (Exception e) {}
    }
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

    int startIdx = (currentPage - 1) * itemsPerPage;
    int endIdx = Math.min(startIdx + itemsPerPage, totalItems);
    
    List<User> pagedList = null;
    if(totalItems > 0) {
        pagedList = fullList.subList(startIdx, endIdx);
    }
    
    // Format ngày
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>

<style>
    /* Card & Header */
    .card-custom { border: none; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); background: white; }
    .card-header-custom {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; padding: 15px 20px; border-radius: 12px 12px 0 0 !important;
    }
    
    /* User Avatar */
    .user-avatar-circle {
        width: 40px; height: 40px; border-radius: 50%;
        background-color: #f0f2f5; color: #667eea;
        display: flex; align-items: center; justify-content: center;
        font-weight: bold; font-size: 1.2rem; border: 2px solid #fff;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }

    /* Pagination */
    .pagination-custom .page-item { margin: 0 5px; }
    .pagination-custom .page-link {
        border-radius: 12px !important; border: 1px solid #e2e8f0;
        color: #6200ea; font-weight: 600; width: 40px; height: 40px;
        display: flex; align-items: center; justify-content: center;
        background-color: #fff; transition: all 0.3s ease;
    }
    .pagination-custom .page-link:hover { background-color: #f3e5f5; color: #6200ea; }
    .pagination-custom .page-item.active .page-link { background-color: #6200ea; color: #fff; border-color: #6200ea; }
    .pagination-custom .page-item.disabled .page-link { background-color: #f1f5f9; color: #94a3b8; }
</style>

<div class="container-fluid px-4 mt-4">
    
    <div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-secondary"><i class="fas fa-users me-2"></i>Quản lý Người dùng</h3>
    
    <a href="ExportUserServlet" class="btn btn-success rounded-pill px-4 shadow-sm">
        <i class="fas fa-file-excel me-2"></i> Xuất Excel
    </a>
</div>

    <div class="card card-custom">
        <div class="card-header card-header-custom">
            <div class="d-flex justify-content-between align-items-center">
                <span><i class="fas fa-list me-2"></i>Danh sách khách hàng</span>
                <span class="badge bg-white text-primary"><%=totalItems%> tài khoản</span>
            </div>
        </div>
        
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light text-secondary text-center small text-uppercase">
                        <tr>
                            <th>ID</th>
                            <th>Họ và Tên</th>
                            <th>Email</th>
                            <th>Số điện thoại</th>
                            <th>Giới tính</th>
                            <th style="width: 20%">Địa chỉ</th>
                            <th>Ngày đăng ký</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (pagedList != null && !pagedList.isEmpty()) {
                            for (User u : pagedList) {
                                String address = userDao.getUserAddress(u.getUserId());
                                if(address == null || address.trim().isEmpty()) address = "Chưa cập nhật";
                                
                                // Avatar giả lập theo tên
                                String firstLetter = u.getUserName().substring(0, 1).toUpperCase();
                                String genderIcon = u.getUserGender().equalsIgnoreCase("Male") ? "text-primary" : "text-danger";
                        %>
                        <tr>
                            <td class="text-center fw-bold text-muted">#<%=u.getUserId()%></td>
                            
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="user-avatar-circle me-3"><%=firstLetter%></div>
                                    <div class="fw-semibold"><%=u.getUserName()%></div>
                                </div>
                            </td>
                            
                            <td class="text-start small"><%=u.getUserEmail()%></td>
                            <td class="text-center"><%=u.getUserPhone()%></td>
                            
                            <td class="text-center">
                                <% if(u.getUserGender().equalsIgnoreCase("Male") || u.getUserGender().equalsIgnoreCase("Nam")) { %>
                                    <span class="badge bg-blue-100 text-primary"><i class="fas fa-mars"></i> Nam</span>
                                <% } else { %>
                                    <span class="badge bg-pink-100 text-danger"><i class="fas fa-venus"></i> Nữ</span>
                                <% } %>
                            </td>
                            
                            <td class="small text-truncate" style="max-width: 200px;" title="<%=address%>">
                                <%=address%>
                            </td>
                            
                            <td class="text-center small">
                                <% try { out.print(dateFormat.format(u.getDateTime())); } catch(Exception e){ out.print("-"); } %>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                            <tr><td colspan="8" class="text-center py-4 text-muted">Chưa có người dùng nào.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <% if (totalPages > 1) { %>
        <div class="card-footer bg-white border-0 py-3">
            <nav class="d-flex justify-content-center">
                <ul class="pagination pagination-custom mb-0">
                    <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                        <a class="page-link" href="admin.jsp?page=users&p=<%=currentPage - 1%>"><i class="fas fa-chevron-left fa-xs"></i></a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <li class="page-item <%= currentPage == i ? "active" : "" %>">
                        <a class="page-link" href="admin.jsp?page=users&p=<%=i%>"><%=i%></a>
                    </li>
                    <% } %>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="admin.jsp?page=users&p=<%=currentPage + 1%>"><i class="fas fa-chevron-right fa-xs"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
    </div>
</div>
