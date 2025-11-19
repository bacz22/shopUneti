<%@page import="entities.Category"%>
<%@page import="java.util.List"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.CategoryDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%
    CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
    List<Category> categoryList = catDao.getAllCategories();
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
</style>

<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold text-secondary"><i class="fas fa-th-large me-2"></i>Quản lý Danh mục</h3>
        <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#add-category">
            <i class="fas fa-plus me-2"></i> Thêm mới
        </button>
    </div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header bg-white py-3">
            <i class="fas fa-list me-2 text-primary"></i> Danh sách danh mục
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
                        if (categoryList != null && !categoryList.isEmpty()) {
                            for (Category c : categoryList) {
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