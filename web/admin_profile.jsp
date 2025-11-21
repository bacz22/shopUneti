<%@page import="entities.Admin"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    // Lấy lại thông tin Admin từ Session (để đảm bảo dữ liệu mới nhất)
    Admin myProfile = (Admin) session.getAttribute("activeAdmin");
%>

<style>
    .profile-header-bg {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        height: 150px;
        border-radius: 15px 15px 0 0;
    }
    .profile-avatar-wrapper {
        margin-top: -75px;
        text-align: center;
    }
    .profile-avatar-large {
        width: 150px; height: 150px; border-radius: 50%;
        border: 5px solid white; box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        background: white; padding: 5px; object-fit: contain;
    }
    .profile-card {
        border: none; border-radius: 15px;
        box-shadow: 0 0 20px rgba(0,0,0,0.05); background: white;
        overflow: hidden;
    }
    /* Modal Style */
    .modal-header-profile {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }
</style>

<div class="container-fluid px-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            
            <div class="card profile-card mb-4">
                <div class="profile-header-bg"></div>
                
                <div class="card-body pt-0">
                    <div class="profile-avatar-wrapper">
                        <img src="Images/admin.png" class="profile-avatar-large" alt="Admin Avatar">
                    </div>
                    
                    <div class="text-center mt-3 mb-5">
                        <h3 class="fw-bold text-dark"><%= myProfile.getName() %></h3>
                        <span class="badge bg-primary px-3 py-2 rounded-pill">Administrator</span>
                    </div>

                    <h5 class="border-bottom pb-2 mb-4 text-secondary"><i class="fas fa-user-edit me-2"></i>Thông tin chi tiết</h5>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted">Họ và tên</label>
                            <input type="text" class="form-control form-control-lg bg-light" value="<%= myProfile.getName() %>" readonly>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted">Email đăng nhập</label>
                            <input type="text" class="form-control form-control-lg bg-light" value="<%= myProfile.getEmail() %>" readonly>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted">Số điện thoại</label>
                            <input type="text" class="form-control form-control-lg bg-light" value="<%= myProfile.getPhone() %>" readonly>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-muted">Mật khẩu</label>
                            <input type="password" class="form-control form-control-lg bg-light" value="<%= myProfile.getPassword() %>" readonly>
                        </div>
                    </div>
                    
                    <div class="mt-5 text-end">
                        <button type="button" class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                            <i class="fas fa-pen me-2"></i>Chỉnh sửa hồ sơ
                        </button>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="editProfileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4">
            <div class="modal-header modal-header-profile">
                <h5 class="modal-title fw-bold"><i class="fas fa-user-cog me-2"></i>Cập nhật thông tin Admin</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <form action="AddOperationServlet" method="post">
                    <input type="hidden" name="operation" value="updateAdmin">
                    <input type="hidden" name="aid" value="<%= myProfile.getId() %>"> 

                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" name="name" placeholder="Họ tên" value="<%= myProfile.getName() %>" required>
                        <label>Họ và tên</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="email" class="form-control" name="email" placeholder="Email" value="<%= myProfile.getEmail() %>" required>
                        <label>Email (Tài khoản)</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" name="phone" placeholder="SĐT" value="<%= myProfile.getPhone() %>" required>
                        <label>Số điện thoại</label>
                    </div>

                    <div class="form-floating mb-4">
                        <input type="text" class="form-control" name="password" placeholder="Pass" value="<%= myProfile.getPassword() %>" required>
                        <label>Mật khẩu</label>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary py-2 fw-bold" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none;">
                            Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>