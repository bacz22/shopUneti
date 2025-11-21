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
    // 1. Khởi tạo DAO & Lấy dữ liệu
    ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
    CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
    
    List<Product> fullList = productDao.getAllProducts();
    List<Category> categoryList = catDao.getAllCategories(); // Để dùng trong Modal

    // 2. Xử lý phân trang
    int itemsPerPage = 8; // Số lượng sản phẩm mỗi trang
    int totalItems = (fullList != null) ? fullList.size() : 0;
    int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
    
    // Lấy trang hiện tại từ URL (mặc định 1)
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

    // Cắt danh sách con
    int startIdx = (currentPage - 1) * itemsPerPage;
    int endIdx = Math.min(startIdx + itemsPerPage, totalItems);
    
    List<Product> pagedList = null;
    if(totalItems > 0) {
        pagedList = fullList.subList(startIdx, endIdx);
    }
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
    /* --- CSS PHÂN TRANG ĐẸP --- */
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
        <h3 class="fw-bold text-secondary"><i class="fas fa-box-open me-2"></i>Quản lý Sản phẩm</h3>
        <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#add-product">
            <i class="fas fa-plus me-2"></i> Thêm mới
        </button>
    </div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <div><i class="fas fa-list me-2 text-primary"></i> Danh sách sản phẩm</div>
            <span class="badge bg-light text-dark border"><%= totalItems %> sản phẩm</span>
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
                        if (pagedList != null && !pagedList.isEmpty()) {
                            java.text.NumberFormat currencyFormat = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                            
                            for (Product prod : pagedList) {
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
                        <% 
                            }
                        } else { 
                        %>
                            <tr><td colspan="8" class="text-center py-4 text-muted">Chưa có sản phẩm nào.</td></tr>
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
                        <a class="page-link" href="admin.jsp?page=products&p=<%=currentPage - 1%>">
                            <i class="fas fa-chevron-left fa-xs"></i>
                        </a>
                    </li>

                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <li class="page-item <%= currentPage == i ? "active" : "" %>">
                        <a class="page-link" href="admin.jsp?page=products&p=<%=i%>"><%=i%></a>
                    </li>
                    <% } %>

                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="admin.jsp?page=products&p=<%=currentPage + 1%>">
                            <i class="fas fa-chevron-right fa-xs"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>

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
