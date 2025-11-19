<%@page import="entities.Category"%>
<%@page import="dao.CategoryDao"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    // 1. Kiểm tra Admin
    Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
    if (activeAdmin == null) {
        Message message = new Message("Phiên đăng nhập hết hạn!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    // 2. Lấy thông tin Category
    String cidStr = request.getParameter("cid");
    if(cidStr == null || cidStr.trim().isEmpty()){
        response.sendRedirect("admin.jsp?page=category");
        return;
    }
    
    int cid = Integer.parseInt(cidStr);
    CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
    Category category = catDao.getCategoryById(cid);
    
    if(category == null) {
        response.sendRedirect("admin.jsp?page=category");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập nhật danh mục | Admin</title>
    <%@include file="Components/common_css_js.jsp"%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --primary-color: #667eea;
        }
        
        body {
            background-color: #f0f2f5;
            font-family: 'Segoe UI', sans-serif;
        }

        .main-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .card-update {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
            width: 100%;
            max-width: 550px;
            position: relative;
        }

        .card-header-custom {
            background: var(--primary-gradient);
            padding: 30px 20px;
            text-align: center;
            color: white;
            position: relative;
        }

        .card-header-custom h4 {
            font-weight: 700;
            margin: 0;
            font-size: 1.5rem;
        }

        /* Image Upload Styling */
        .img-upload-container {
            position: relative;
            width: 140px;
            height: 140px;
            margin: -70px auto 20px; /* Đẩy lên đè vào header */
            border-radius: 50%;
            padding: 5px;
            background: white;
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }

        .img-preview {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
            border: 2px solid #f0f0f0;
            cursor: pointer;
            transition: all 0.3s;
        }

        .img-upload-container:hover .img-preview {
            filter: brightness(0.7);
        }

        .camera-icon {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 2rem;
            opacity: 0;
            pointer-events: none;
            transition: all 0.3s;
        }

        .img-upload-container:hover .camera-icon {
            opacity: 1;
        }

        .upload-label {
            position: absolute;
            bottom: 5px;
            right: 5px;
            background: var(--primary-color);
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid white;
            cursor: pointer;
        }

        /* Input Styling */
        .form-floating > .form-control:focus,
        .form-floating > .form-control:not(:placeholder-shown) {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(102, 126, 234, 0.25);
        }
        
        .btn-save {
            background: var(--primary-gradient);
            border: none;
            padding: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            border-radius: 10px;
            transition: transform 0.2s;
        }
        
        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-back {
            border-radius: 10px;
            font-weight: 600;
            padding: 12px;
            border: 2px solid #e0e0e0;
            color: #666;
            background: transparent;
        }
        .btn-back:hover {
            background: #f8f9fa;
            color: #333;
        }
    </style>
</head>
<body>

    <%@include file="Components/navbar.jsp"%>

    <div class="main-container">
        <div class="card-update animate__animated animate__fadeInUp">
            
            <div class="card-header-custom">
                <h4>Chỉnh sửa danh mục</h4>
                <p class="mb-0 opacity-75">Cập nhật thông tin hiển thị</p>
                <div style="height: 40px;"></div> </div>

            <div class="card-body px-4 pb-4">
                <form action="ProductOperationServlet" method="post" enctype="multipart/form-data">
                    
                    <input type="hidden" name="operation" value="updateCategory">
                    <input type="hidden" name="cid" value="<%= category.getCategoryId() %>">
                    <input type="file" name="catImage" id="fileInput" accept="image/*" style="display: none;" onchange="previewImage(this)">
                    <input type="hidden" name="oldImage" value="<%= category.getCategoryImage() %>">

                    <div class="img-upload-container" onclick="document.getElementById('fileInput').click();">
                        <img src="Images/<%= category.getCategoryImage() %>" id="avatarPreview" class="img-preview" title="Nhấn để đổi ảnh">
                        <i class="fas fa-camera camera-icon"></i>
                        <div class="upload-label">
                            <i class="fas fa-pen fa-xs"></i>
                        </div>
                    </div>
                    <p class="text-center text-muted small mb-4">Nhấn vào ảnh để thay đổi</p>

                    <div class="form-floating mb-4">
                        <input type="text" class="form-control" id="catName" name="catTitle" 
                               placeholder="Tên danh mục" value="<%= category.getCategoryName() %>" required>
                        <label for="catName"><i class="fas fa-tag me-2"></i>Tên danh mục</label>
                    </div>

                    <div class="row g-2">
                        <div class="col-6">
                            <a href="admin.jsp?page=category" class="btn btn-back w-100 text-center text-decoration-none">
                                <i class="fas fa-arrow-left me-2"></i>Hủy bỏ
                            </a>
                        </div>
                        <div class="col-6">
                            <button type="submit" class="btn btn-primary btn-save w-100">
                                <i class="fas fa-save me-2"></i>Lưu lại
                            </button>
                        </div>
                    </div>

                </form>
            </div>
        </div>
    </div>

    <%@include file="Components/footer.jsp"%>

    <script>
        function previewImage(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('avatarPreview').src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>

</body>
</html>