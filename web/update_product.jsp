<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<div class="modal fade" id="editProductModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered"> 
        <div class="modal-content border-0 rounded-4">
            <div class="modal-header modal-header-custom">
                <h5 class="modal-title fw-bold text-white"><i class="fas fa-edit me-2"></i>Cập nhật sản phẩm</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            
            <div class="modal-body p-4">
                <form action="AddOperationServlet" method="post" enctype="multipart/form-data" name="updateProductForm" onsubmit="return saveSpecsBeforeSubmit()">
                    
                    <input type="hidden" name="operation" value="updateProduct">
                    <input type="hidden" name="pid" id="edit_pid">
                    <input type="hidden" name="oldImage" id="edit_old_image">
                    <input type="hidden" name="specifications" id="final_spec_input">

                    <div class="row">
                        <div class="col-lg-4 border-end">
                            <div class="text-center mb-3">
                                <input type="file" name="pPic" id="editFileInput" accept="image/*" style="display: none;" onchange="previewEditImage(this)">
                                <div class="prod-img-container" onclick="document.getElementById('editFileInput').click();">
                                    <img src="" id="edit_img_preview" class="prod-img-preview">
                                    <i class="fas fa-camera camera-icon"></i>
                                </div>
                                <p class="text-muted small">Chạm vào ảnh để thay đổi</p>
                            </div>
                            
                            <div class="form-floating mb-3">
                                <input type="text" class="form-control" id="edit_name" name="pName" placeholder="Tên sp" required>
                                <label>Tên sản phẩm</label>
                            </div>
                            <div class="form-floating mb-3">
                                <select class="form-select" id="edit_catId" name="catId" required>
                                    <% for(entities.Category c : categoryList) { %>
                                        <option value="<%=c.getCategoryId()%>"><%=c.getCategoryName()%></option>
                                    <% } %>
                                </select>
                                <label>Danh mục</label>
                            </div>
                            <div class="row g-2">
                                <div class="col-6">
                                    <div class="form-floating">
                                        <input type="number" class="form-control" id="edit_price" name="pPrice" placeholder="Giá" required>
                                        <label>Giá (VNĐ)</label>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="form-floating">
                                        <input type="number" class="form-control" id="edit_discount" name="pDiscount" placeholder="%">
                                        <label>Giảm giá (%)</label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-floating mt-3">
                                <input type="number" class="form-control" id="edit_qty" name="pQuantity" placeholder="SL" required>
                                <label>Số lượng kho</label>
                            </div>
                        </div>

                        <div class="col-lg-8 ps-4">
                            <div class="form-floating mb-4">
                                <textarea class="form-control" id="edit_desc" name="pDesc" placeholder="Mô tả" style="height: 100px"></textarea>
                                <label>Mô tả sản phẩm</label>
                            </div>
                            
                            <div class="card bg-light border-0">
                                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                    <h6 class="fw-bold mb-0 text-secondary"><i class="fas fa-table me-2"></i>Thông số kỹ thuật</h6>
                                    <button type="button" class="btn btn-sm btn-outline-primary rounded-pill" onclick="addSpecRow()">
                                        <i class="fas fa-plus"></i> Thêm dòng
                                    </button>
                                </div>
                                <div class="card-body p-2">
                                    <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                                        <table class="table table-bordered bg-white mb-0 spec-table" id="tableSpecs">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 40%">Tên thông số (VD: RAM)</th>
                                                    <th style="width: 50%">Chi tiết (VD: 8GB)</th>
                                                    <th style="width: 10%" class="text-center"><i class="fas fa-trash"></i></th>
                                                </tr>
                                            </thead>
                                            <tbody id="tbodySpecs">
                                                </tbody>
                                        </table>
                                    </div>
                                    <small class="text-muted mt-2 d-block ms-1">* Nhập tên thông số và giá trị tương ứng.</small>
                                </div>
                            </div>

                            <div class="d-grid mt-4">
                                <button type="submit" class="btn btn-primary py-2 fw-bold fs-5" style="background: #667eea; border: none;">
                                    <i class="fas fa-save me-2"></i>Lưu thay đổi
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // 1. KHI MỞ MODAL SỬA
    const editProdModal = document.getElementById('editProductModal');
    if (editProdModal) {
        editProdModal.addEventListener('show.bs.modal', event => {
            const btn = event.relatedTarget;
            
            // Điền thông tin cơ bản
            document.getElementById('edit_pid').value = btn.getAttribute('data-pid');
            document.getElementById('edit_name').value = btn.getAttribute('data-name');
            document.getElementById('edit_price').value = btn.getAttribute('data-price');
            document.getElementById('edit_qty').value = btn.getAttribute('data-qty');
            document.getElementById('edit_discount').value = btn.getAttribute('data-discount');
            document.getElementById('edit_desc').value = btn.getAttribute('data-desc');
            document.getElementById('edit_catId').value = btn.getAttribute('data-catid');
            
            // Ảnh
            const imgName = btn.getAttribute('data-img');
            document.getElementById('edit_old_image').value = imgName;
            document.getElementById('edit_img_preview').src = 'Images/' + imgName;
            document.getElementById('editFileInput').value = "";

            // Xử lý bảng thông số
            const specString = btn.getAttribute('data-spec');
            loadSpecsToTable(specString);
        });
    }

    // 2. HÀM LOAD THÔNG SỐ VÀO BẢNG
    function loadSpecsToTable(specStr) {
        const tbody = document.getElementById('tbodySpecs');
        tbody.innerHTML = ""; 

        if (!specStr || specStr.trim() === "") return;

        const items = specStr.split(';');
        
        items.forEach(item => {
            if(item && item.trim() !== "") {
                let key = "";
                let val = "";
                if (item.includes(':')) {
                    const firstColonIndex = item.indexOf(':');
                    key = item.substring(0, firstColonIndex).trim();
                    val = item.substring(firstColonIndex + 1).trim();
                } else {
                    key = item.trim();
                }
                addSpecRow(key, val);
            }
        });
    }

    // 3. HÀM THÊM DÒNG MỚI
    function addSpecRow(key = "", value = "") {
        const tbody = document.getElementById('tbodySpecs');
        const row = document.createElement('tr');
        
        row.innerHTML = `
            <td><input type="text" class="form-control form-control-sm spec-key" placeholder="VD: Màn hình"></td>
            <td><input type="text" class="form-control form-control-sm spec-val" placeholder="VD: 15.6 inch"></td>
            <td class="text-center align-middle">
                <i class="fas fa-times-circle btn-remove-row fa-lg" onclick="this.closest('tr').remove()" style="cursor:pointer; color:red;"></i>
            </td>
        `;
        // Gán giá trị an toàn
        row.querySelector('.spec-key').value = key;
        row.querySelector('.spec-val').value = value;
        tbody.appendChild(row);
    }

    // 4. GOM DỮ LIỆU TRƯỚC KHI SUBMIT
    function saveSpecsBeforeSubmit() {
        const keys = document.querySelectorAll('.spec-key');
        const vals = document.querySelectorAll('.spec-val');
        let finalString = "";

        for(let i=0; i<keys.length; i++) {
            let k = keys[i].value.trim();
            let v = vals[i].value.trim();
            if(k !== "" && v !== "") {
                finalString += k + ":" + v + ";"; 
            }
        }
        document.getElementById('final_spec_input').value = finalString;
        return true;
    }

    // Preview Ảnh
    function previewEditImage(input) {
        if (input.files && input.files[0]) {
            var r = new FileReader();
            r.onload = function(e) { document.getElementById('edit_img_preview').src = e.target.result; }
            r.readAsDataURL(input.files[0]);
        }
    }
</script>