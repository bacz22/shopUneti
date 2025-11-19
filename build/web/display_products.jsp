<%@page import="entities.Category"%>
<%@page import="dao.CategoryDao"%>
<%@page import="java.util.List"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.ProductDao"%>
<%@page import="entities.Product"%>
<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<%
    // 1. Khởi tạo DAO
    ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
    CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
    List<Product> productList = productDao.getAllProducts();
    
    // Biến này sẽ được dùng bên trong file update_product.jsp
    List<Category> categoryList = catDao.getAllCategories();
%>

<style>
    .modal-header-custom {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white; padding: 20px;
    }
    .prod-img-container {
        position: relative; width: 140px; height: 140px; margin: 0 auto 20px;
        border-radius: 50%; padding: 4px; background: white;
        box-shadow: 0 5px 15px rgba(0,0,0,0.15); cursor: pointer;
    }
    .prod-img-preview {
        width: 100%; height: 100%; object-fit: contain; border-radius: 50%;
        border: 1px solid #eee; transition: filter 0.3s;
    }
    .prod-img-container:hover .prod-img-preview { filter: brightness(0.7); }
    .camera-icon {
        position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
        color: white; font-size: 1.8rem; opacity: 0; transition: opacity 0.3s;
    }
    .prod-img-container:hover .camera-icon { opacity: 1; }
    .upload-label {
        position: absolute; bottom: 0; right: 10px; background: #667eea;
        color: white; width: 35px; height: 35px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center; border: 3px solid white;
    }
    .spec-table th { background-color: #f8f9fa; font-size: 0.9rem; }
</style>

<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold text-secondary"><i class="fas fa-box-open me-2"></i>Quản lý Sản phẩm</h3>
        <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#add-product">
            <i class="fas fa-plus me-2"></i> Thêm mới
        </button>
    </div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header bg-white py-3">
            <i class="fas fa-list me-2 text-primary"></i> Danh sách sản phẩm
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light text-secondary text-center small text-uppercase">
                        <tr>
                            <th>ID</th>
                            <th>Hình ảnh</th>
                            <th>Tên sản phẩm</th>
                            <th>Danh mục</th>
                            <th>Giá bán</th>
                            <th>Kho</th>
                            <th>Giảm giá</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        java.text.NumberFormat currencyFormat = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                        
                        for (Product prod : productList) {
                            String categoryName = "---";
                            for(Category c : categoryList){
                                if(c.getCategoryId() == prod.getCategoryId()){ categoryName = c.getCategoryName(); break; }
                            }
                        %>
                        <tr class="text-center">
                            <td class="fw-bold text-muted">#<%=prod.getProductId()%></td>
                            <td><img src="Images/<%=prod.getProductImages()%>" style="width: 50px; height: 50px; object-fit: contain;"></td>
                            <td class="text-start fw-semibold text-truncate" style="max-width: 200px;" title="<%=prod.getProductName()%>">
                                <%=prod.getProductName()%>
                            </td>
                            <td class="text-start small"><%=categoryName%></td>
                            <td class="fw-bold text-success"><%=currencyFormat.format(prod.getProductPriceAfterDiscount())%> ₫</td>
                            <td><%=prod.getProductQunatity()%></td>
                            <td><% if(prod.getProductDiscount()>0){ %><span class="badge bg-danger">-<%=prod.getProductDiscount()%>%</span><% } %></td>
                            <td>
                                <button class="btn btn-light text-primary btn-sm me-1" 
                                        data-bs-toggle="modal" 
                                        data-bs-target="#editProductModal"
                                        data-pid="<%=prod.getProductId()%>"
                                        data-name="<%=prod.getProductName()%>"
                                        data-price="<%=prod.getProductPrice()%>"
                                        data-qty="<%=prod.getProductQunatity()%>"
                                        data-discount="<%=prod.getProductDiscount()%>"
                                        data-desc="<%=prod.getProductDescription()%>"
                                        
                                        <%
                                            String safeSpec = "";
                                            if (prod.getSpecifications() != null) {
                                                safeSpec = prod.getSpecifications().replace("\"", "&quot;");
                                            }
                                        %>
                                        data-spec="<%=safeSpec%>"    
                                        
                                        data-catid="<%=prod.getCategoryId()%>"
                                        data-img="<%=prod.getProductImages()%>">
                                    <i class="fas fa-pen"></i>
                                </button>
                                
                                <button onclick="confirmDelete(<%=prod.getProductId()%>)" class="btn btn-light text-danger btn-sm"><i class="fas fa-trash"></i></button>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%@include file="add_product.jsp"%>
<%@include file="update_product.jsp"%>

<script>
    // HÀM XÓA SẢN PHẨM (Dùng SweetAlert2)
    function confirmDelete(pid) {
        Swal.fire({
            title: 'Bạn có chắc chắn?',
            text: "Sản phẩm này sẽ bị xóa vĩnh viễn!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Xóa ngay',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                // Chuyển hướng để xóa
                window.location.href = "AddOperationServlet?pid=" + pid + "&operation=deleteProduct";
            }
        });
    }
</script>
