<%@page import="entities.Category"%>
<%@page import="java.util.List"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.CategoryDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%
    // 1. Lấy danh sách danh mục từ DB
    CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
    List<Category> fullList = catDao.getAllCategories();

    // 2. Xử lý phân trang
    int itemsPerPage = 5; // Số lượng item mỗi trang
    int totalItems = (fullList != null) ? fullList.size() : 0;
    int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
    
    // Lấy trang hiện tại từ URL (mặc định là 1)
    int currentPage = 1;
    String pageParam = request.getParameter("p");
    if (pageParam != null) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

    // Cắt danh sách con cho trang hiện tại
    int startIdx = (currentPage - 1) * itemsPerPage;
    int endIdx = Math.min(startIdx + itemsPerPage, totalItems);
    
    List<Category> pagedList = null;
    if(totalItems > 0) {
        pagedList = fullList.subList(startIdx, endIdx);
    }
%>

<style>
    /* CSS CHO MODAL ĐẸP (Dùng chung cho cả Add và Edit) */
    .modal-header-custom {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 15px 15px 0 0;
        padding: 20px;
    }
    
    /* Avatar Upload Style */
    .edit-img-container {
        position: relative; width: 120px; height: 120px; margin: 0 auto 20px;
        border-radius: 50%; padding: 4px; background: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.15); cursor: pointer;
    }
    .edit-img-preview {
        width: 100%; height: 100%; object-fit: cover; border-radius: 50%;
        border: 2px solid #f0f0f0; transition: filter 0.3s;
    }
    .edit-img-container:hover .edit-img-preview { filter: brightness(0.7); }
    .edit-camera-icon {
        position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
        color: white; font-size: 1.5rem; opacity: 0; pointer-events: none; transition: opacity 0.3s;
    }
    .edit-img-container:hover .edit-camera-icon { opacity: 1; }
    .edit-upload-label {
        position: absolute; bottom: 0; right: 0; background: #667eea; color: white;
        width: 32px; height: 32px; border-radius: 50%; display: flex;
        align-items: center; justify-content: center; border: 3px solid white;
    }
    /* Custom Pagination Style (Đồng bộ với trang khác) */
    .pagination-custom .page-item { margin: 0 5px; }
    .pagination-custom .page-link {
        border-radius: 12px !important; border: 1px solid #e2e8f0;
        color: #6200ea; font-weight: 600; width: 40px; height: 40px;
        display: flex; align-items: center; justify-content: center;
        background-color: #fff; transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    .pagination-custom .page-link:hover {
        background-color: #f3e5f5; border-color: #6200ea; color: #6200ea;
    }
    .pagination-custom .page-item.active .page-link {
        background-color: #6200ea; border-color: #6200ea; color: #fff;
        box-shadow: 0 4px 10px rgba(98, 0, 234, 0.3);
    }
    .pagination-custom .page-item.disabled .page-link {
        background-color: #f1f5f9; color: #94a3b8; border-color: #f1f5f9; pointer-events: none;
    }
</style>

<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold text-secondary"><i class="fas fa-th-large me-2"></i>Quản lý Danh mục</h3>
        <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#add-category">
            <i class="fas fa-plus me-2"></i> Thêm mới
        </button>
    </div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <div><i class="fas fa-list me-2 text-primary"></i> Danh sách danh mục</div>
            <span class="badge bg-light text-dark border"><%= totalItems %> danh mục</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0 align-middle">
                    <thead class="bg-light">
                        <tr class="text-center">
                            <th style="width: 10%">ID</th>
                            <th style="width: 15%">Hình ảnh</th>
                            <th style="width: 55%">Tên danh mục</th>
                            <th style="width: 20%">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (pagedList != null && !pagedList.isEmpty()) {
                            for (Category c : pagedList) {
                        %>
                        <tr class="text-center">
                            <td class="fw-bold text-secondary">#<%=c.getCategoryId()%></td>
                            <td>
                                <img src="Images/<%=c.getCategoryImage()%>" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px; border: 1px solid #eee;">
                            </td>
                            <td class="fw-semibold text-start ps-5"><%=c.getCategoryName()%></td>
                            <td>
                                <button type="button" class="btn btn-light text-primary btn-sm me-2" title="Sửa"
                                        data-bs-toggle="modal" 
                                        data-bs-target="#editCategoryModal"
                                        data-id="<%=c.getCategoryId()%>"
                                        data-name="<%=c.getCategoryName()%>"
                                        data-img="<%=c.getCategoryImage()%>">
                                    <i class="fas fa-pen"></i>
                                </button>

                                <a href="#" onclick="confirmDelete(<%=c.getCategoryId()%>)" class="btn btn-light text-danger btn-sm" title="Xóa">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr><td colspan="4" class="text-center py-4 text-muted">Chưa có dữ liệu</td></tr>
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
                        <a class="page-link" href="admin.jsp?page=category&p=<%=currentPage - 1%>">
                            <i class="fas fa-chevron-left fa-xs"></i>
                        </a>
                    </li>

                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <li class="page-item <%= currentPage == i ? "active" : "" %>">
                        <a class="page-link" href="admin.jsp?page=category&p=<%=i%>"><%=i%></a>
                    </li>
                    <% } %>

                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="admin.jsp?page=category&p=<%=currentPage + 1%>">
                            <i class="fas fa-chevron-right fa-xs"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
        
    </div>
</div>

<%@include file="add_category.jsp" %>

<div class="modal fade" id="editCategoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; border: none;">
            <div class="modal-header modal-header-custom">
                <h5 class="modal-title fw-bold"><i class="fas fa-edit me-2"></i>Cập nhật danh mục</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <form action="AddOperationServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="operation" value="updateCategory">
                    <input type="hidden" name="cid" id="edit_cid">
                    <input type="hidden" name="image" id="edit_old_img">

                    <div class="text-center">
                        <input type="file" name="category_img" id="editFileInput" accept="image/*" style="display: none;" onchange="previewEditImage(this)">
                        <div class="edit-img-container" onclick="document.getElementById('editFileInput').click();">
                            <img src="" id="edit_img_preview" class="edit-img-preview">
                            <i class="fas fa-camera edit-camera-icon"></i>
                            <div class="edit-upload-label"><i class="fas fa-pen fa-xs"></i></div>
                        </div>
                        <p class="text-muted small mb-4">Chạm vào ảnh để thay đổi</p>
                    </div>

                    <div class="form-floating mb-4">
                        <input type="text" class="form-control" id="edit_name" name="category_name" placeholder="Tên danh mục" required>
                        <label for="edit_name">Tên danh mục</label>
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

<script>
    // 1. XỬ LÝ MODAL SỬA
    const editModal = document.getElementById('editCategoryModal');
    if (editModal) {
        editModal.addEventListener('show.bs.modal', event => {
            const button = event.relatedTarget;
            document.getElementById('edit_cid').value = button.getAttribute('data-id');
            document.getElementById('edit_name').value = button.getAttribute('data-name');
            document.getElementById('edit_old_img').value = button.getAttribute('data-img');
            document.getElementById('editFileInput').value = "";
            document.getElementById('edit_img_preview').src = 'Images/' + button.getAttribute('data-img');
        });
    }

    // 2. PREVIEW ẢNH (DÙNG CHO CẢ 2 MODAL)
    function previewAddImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) { document.getElementById('addCatPreview').src = e.target.result; }
            reader.readAsDataURL(input.files[0]);
        }
    }
    
    function previewEditImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) { document.getElementById('edit_img_preview').src = e.target.result; }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // 3. XÓA DANH MỤC (Dùng SweetAlert2)
    function confirmDelete(id) {
        Swal.fire({
            title: 'Bạn có chắc chắn?',
            text: "Hành động này sẽ xóa danh mục và không thể hoàn tác!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Xóa ngay',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                // Nếu người dùng bấm Xóa -> Chuyển hướng
                window.location.href = "AddOperationServlet?cid=" + id + "&operation=deleteCategory";
            }
        });
    }
</script>