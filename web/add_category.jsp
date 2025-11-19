<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<div class="modal fade" id="add-category" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; border: none;">
            
            <div class="modal-header modal-header-custom">
                <h5 class="modal-title fw-bold"><i class="fas fa-plus-circle me-2"></i>Thêm Danh Mục Mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="modal-body p-4">
                <form action="AddOperationServlet" method="post" enctype="multipart/form-data">
                    
                    <input type="hidden" name="operation" value="addCategory">

                    <div class="text-center">
                        <input type="file" name="category_img" id="addCatInput" accept="image/*" style="display: none;" onchange="previewAddImage(this)" required>
                        
                        <div class="edit-img-container" onclick="document.getElementById('addCatInput').click();">
                            <img src="https://via.placeholder.com/150/f0f0f0/cccccc?text=Upload" id="addCatPreview" class="edit-img-preview">
                            
                            <i class="fas fa-camera edit-camera-icon"></i>
                            <div class="edit-upload-label">
                                <i class="fas fa-plus fa-xs"></i>
                            </div>
                        </div>
                        <p class="text-muted small mb-4">Chạm vào để tải ảnh lên</p>
                    </div>

                    <div class="form-floating mb-4">
                        <input type="text" class="form-control" id="addCatName" name="category_name" placeholder="Tên danh mục" required>
                        <label for="addCatName">Tên danh mục</label>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary py-2 fw-bold" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none;">
                            Thêm danh mục
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>