<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<div class="modal fade" id="add-product" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content border-0 rounded-4">
            
            <div class="modal-header modal-header-custom">
                <h5 class="modal-title fw-bold text-white"><i class="fas fa-plus-circle me-2"></i>Thêm Sản Phẩm Mới</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            
            <div class="modal-body p-4">
                <form action="AddOperationServlet" method="post" enctype="multipart/form-data" onsubmit="return saveAddSpecs()">
                    
                    <input type="hidden" name="operation" value="addProduct">
                    <input type="hidden" name="specifications" id="add_final_spec">

                    <div class="row">
                        <div class="col-lg-4 border-end">
                            <div class="text-center mb-3">
                                <input type="file" name="pPic" id="addFileInput" accept="image/*" style="display: none;" onchange="previewAddProdImage(this)" required>
                                
                                <div class="prod-img-container" onclick="document.getElementById('addFileInput').click();">
                                    <img src="https://via.placeholder.com/150/f0f0f0/cccccc?text=Upload" id="add_img_preview" class="prod-img-preview">
                                    <i class="fas fa-camera camera-icon"></i>
                                </div>
                                <p class="text-muted small">Chạm vào ảnh để tải lên</p>
                            </div>
                            
                            <div class="form-floating mb-3">
                                <input type="text" class="form-control" name="pName" placeholder="Tên sp" required>
                                <label>Tên sản phẩm</label>
                            </div>
                            
                            <div class="form-floating mb-3">
                                <select class="form-select" name="catId" required>
                                    <option selected disabled value="">-- Chọn danh mục --</option>
                                    <% for(entities.Category c : categoryList) { %>
                                        <option value="<%=c.getCategoryId()%>"><%=c.getCategoryName()%></option>
                                    <% } %>
                                </select>
                                <label>Danh mục</label>
                            </div>
                            
                            <div class="row g-2">
                                <div class="col-6">
                                    <div class="form-floating">
                                        <input type="number" class="form-control" name="pPrice" placeholder="Giá" required>
                                        <label>Giá (VNĐ)</label>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="form-floating">
                                        <input type="number" class="form-control" name="pDiscount" placeholder="%" value="0">
                                        <label>Giảm giá (%)</label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-floating mt-3">
                                <input type="number" class="form-control" name="pQuantity" placeholder="SL" required>
                                <label>Số lượng kho</label>
                            </div>
                        </div>

                        <div class="col-lg-8 ps-4">
                            <div class="form-floating mb-4">
                                <textarea class="form-control" name="pDesc" placeholder="Mô tả" style="height: 100px"></textarea>
                                <label>Mô tả sản phẩm</label>
                            </div>
                            
                            <div class="card bg-light border-0">
                                <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                    <h6 class="fw-bold mb-0 text-secondary"><i class="fas fa-table me-2"></i>Thông số kỹ thuật</h6>
                                    <button type="button" class="btn btn-sm btn-outline-primary rounded-pill" onclick="addNewSpecRow()">
                                        <i class="fas fa-plus"></i> Thêm dòng
                                    </button>
                                </div>
                                <div class="card-body p-2">
                                    <div class="table-responsive" style="max-height: 250px; overflow-y: auto;">
                                        <table class="table table-bordered bg-white mb-0 spec-table">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="width: 40%">Tên thông số</th>
                                                    <th style="width: 50%">Chi tiết</th>
                                                    <th style="width: 10%" class="text-center"><i class="fas fa-trash"></i></th>
                                                </tr>
                                            </thead>
                                            <tbody id="addSpecBody">
                                                <tr>
                                                    <td><input type="text" class="form-control form-control-sm add-spec-key" placeholder="VD: RAM"></td>
                                                    <td><input type="text" class="form-control form-control-sm add-spec-val" placeholder="VD: 8GB"></td>
                                                    <td class="text-center align-middle">
                                                        <i class="fas fa-times-circle btn-remove-row fa-lg" onclick="this.closest('tr').remove()" style="color:red; cursor:pointer;"></i>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <small class="text-muted mt-2 d-block ms-1">* Nhập thông số để hiển thị chi tiết cho khách hàng.</small>
                                </div>
                            </div>

                            <div class="d-grid mt-4">
                                <button type="submit" class="btn btn-primary py-2 fw-bold fs-5" style="background: #667eea; border: none;">
                                    <i class="fas fa-plus-circle me-2"></i>Thêm sản phẩm
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
    // 1. Preview Ảnh
    function previewAddProdImage(input) {
        if (input.files && input.files[0]) {
            var r = new FileReader();
            r.onload = function(e) { document.getElementById('add_img_preview').src = e.target.result; }
            r.readAsDataURL(input.files[0]);
        }
    }

    // 2. Thêm dòng thông số mới
    function addNewSpecRow() {
        const tbody = document.getElementById('addSpecBody');
        const row = document.createElement('tr');
        row.innerHTML = `
            <td><input type="text" class="form-control form-control-sm add-spec-key" placeholder="VD: Màn hình"></td>
            <td><input type="text" class="form-control form-control-sm add-spec-val" placeholder="VD: 15.6 inch"></td>
            <td class="text-center align-middle">
                <i class="fas fa-times-circle btn-remove-row fa-lg" onclick="this.closest('tr').remove()" style="color:red; cursor:pointer;"></i>
            </td>
        `;
        tbody.appendChild(row);
    }

    // 3. Gom dữ liệu trước khi Submit
    function saveAddSpecs() {
        const keys = document.querySelectorAll('.add-spec-key');
        const vals = document.querySelectorAll('.add-spec-val');
        let finalString = "";

        for(let i=0; i<keys.length; i++) {
            let k = keys[i].value.trim();
            let v = vals[i].value.trim();
            if(k !== "" && v !== "") {
                finalString += k + ":" + v + ";"; 
            }
        }
        document.getElementById('add_final_spec').value = finalString;
        return true;
    }
</script>