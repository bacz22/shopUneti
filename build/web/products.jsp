<%@page import="java.util.ArrayList"%>
<%@page import="java.util.stream.Collectors"%>
<%@page import="dao.WishlistDao"%>
<%@page import="entities.User"%>
<%@page import="dao.CategoryDao"%>
<%@page import="entities.Category"%>
<%@page import="entities.Product"%>
<%@page import="java.util.List"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.ProductDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    // 1. KHỞI TẠO CÁC DAO VÀ USER
    User u = (User) session.getAttribute("activeUser");
    WishlistDao wishlistDao = new WishlistDao(ConnectionProvider.getConnection());
    ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
    CategoryDao categoryDao = new CategoryDao(ConnectionProvider.getConnection());

    // 2. LẤY DỮ LIỆU TỪ REQUEST
    String searchKey = request.getParameter("search");
    String catIdParam = request.getParameter("category");
    String minPriceParam = request.getParameter("minPrice");
    String maxPriceParam = request.getParameter("maxPrice");
    String pageParam = request.getParameter("page");

    // 3. XỬ LÝ LOGIC LẤY DANH SÁCH GỐC
    List<Product> allProducts = null;
    String message = "";
    String filterInfo = "";

    int currentCatId = (catIdParam != null && !catIdParam.isEmpty()) ? Integer.parseInt(catIdParam) : 0;

    // Lấy danh sách danh mục để hiển thị sidebar
    List<Category> categoryList = categoryDao.getAllCategories();

    // Logic lấy sản phẩm ban đầu
    if (searchKey != null && !searchKey.trim().isEmpty()) {
        allProducts = productDao.getAllProductsBySearchKey(searchKey.trim());
        message = "Tìm kiếm: \"" + searchKey.trim() + "\"";
    } else if (currentCatId > 0) {
        allProducts = productDao.getAllProductsByCategoryId(currentCatId);
        message = categoryDao.getCategoryName(currentCatId);
    } else {
        allProducts = productDao.getAllProducts();
        message = "Tất cả sản phẩm";
    }

    // 4. XỬ LÝ LỌC THEO GIÁ (FILTERING IN MEMORY)
    // Lưu ý: Tốt nhất nên xử lý trong DAO (SQL), nhưng để tiện tôi xử lý tại đây
    double minPrice = (minPriceParam != null && !minPriceParam.isEmpty()) ? Double.parseDouble(minPriceParam) : 0;
    double maxPrice = (maxPriceParam != null && !maxPriceParam.isEmpty()) ? Double.parseDouble(maxPriceParam) : Double.MAX_VALUE;

    if (minPrice > 0 || maxPrice < Double.MAX_VALUE) {
        allProducts = allProducts.stream()
                .filter(p -> {
                    double price = p.getProductPriceAfterDiscount();
                    return price >= minPrice && price <= maxPrice;
                })
                .collect(Collectors.toList());
        filterInfo = "(Đã lọc giá)";
    }

    // 5. PHÂN TRANG
    int totalProducts = allProducts.size();
    int itemsPerPage = 9;
    int currentPage = (pageParam == null || pageParam.isEmpty()) ? 1 : Integer.parseInt(pageParam);
    int totalPages = (int) Math.ceil((double) totalProducts / itemsPerPage);
    int offset = (currentPage - 1) * itemsPerPage;

    // Cắt list cho trang hiện tại
    List<Product> prodList = new ArrayList<>();
    if (totalProducts > 0) {
        int toIndex = Math.min(offset + itemsPerPage, totalProducts);
        if (offset < toIndex) {
            prodList = allProducts.subList(offset, toIndex);
        }
    } else {
        message = "Không tìm thấy sản phẩm nào!";
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sản phẩm - TechZone</title>
        <%@include file="Components/common_css_js.jsp"%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

        <style>
            :root {
                --primary: #5b21b6;
                --primary-light: #7c3aed;
                --gray-100: #f3f4f6;
                --dark: #1f2937;
            }

            body {
                background-color: #f9fafb;
                font-family: 'Segoe UI', sans-serif;
            }

            /* Sidebar Styles */
            .sidebar {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                position: sticky;
                top: 20px;
            }

            .sidebar-title {
                font-size: 1.1rem;
                font-weight: 700;
                color: var(--dark);
                margin-bottom: 1rem;
                padding-bottom: 0.5rem;
                border-bottom: 2px solid var(--gray-100);
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .category-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .category-item a {
                display: block;
                padding: 10px 14px;
                color: #4b5563;
                text-decoration: none;
                border-radius: 8px;
                transition: all 0.2s;
                font-weight: 500;
            }

            .category-item a:hover {
                background-color: #f5f3ff;
                color: var(--primary);
                transform: translateX(5px);
            }

            .category-item a.active {
                background-color: var(--primary);
                color: white;
                box-shadow: 0 4px 6px -1px rgba(91, 33, 182, 0.3);
            }

            /* Search & Filter Inputs */
            .filter-input {
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                padding: 10px 14px;
                width: 100%;
                margin-bottom: 12px;
                transition: all 0.2s;
            }
            .filter-input:focus {
                border-color: var(--primary);
                outline: none;
                box-shadow: 0 0 0 3px rgba(91, 33, 182, 0.1);
            }

            .btn-filter {
                width: 100%;
                background: var(--primary);
                color: white;
                border: none;
                padding: 10px;
                border-radius: 8px;
                font-weight: 600;
                transition: all 0.2s;
            }
            .btn-filter:hover {
                background: var(--primary-light);
                transform: translateY(-1px);
            }

            /* Product Card (Minimal Adjustments) */
            .product-card {
                border: none;
                border-radius: 16px;
                background: white;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
                transition: all 0.3s;
                height: 100%;
                position: relative;
                overflow: hidden;
            }
            .product-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            }
            .img-wrapper {
                position: relative;
                padding: 20px;
                background: #fff;
                text-align: center;
                height: 220px;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .img-wrapper img {
                max-height: 180px;
                max-width: 100%;
                object-fit: contain;
                transition: transform 0.3s;
            }
            .product-card:hover img {
                transform: scale(1.05);
            }

            /* Badges */
            .badge-discount {
                position: absolute;
                top: 10px;
                left: 10px;
                background: #ef4444;
                color: white;
                padding: 4px 10px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: 700;
                z-index: 2;
            }
            .btn-wishlist {
                position: absolute;
                top: 10px;
                right: 10px;
                width: 35px;
                height: 35px;
                border-radius: 50%;
                border: none;
                background: white;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
                z-index: 2;
                color: #9ca3af;
                transition: all 0.2s;
            }
            .btn-wishlist:hover {
                color: #ef4444;
                transform: scale(1.1);
            }
            .btn-wishlist.active {
                color: #ef4444;
            }

            /* Prices */
            .price-current {
                color: var(--primary);
                font-weight: 800;
                font-size: 1.2rem;
            }
            .price-old {
                text-decoration: line-through;
                color: #9ca3af;
                font-size: 0.9rem;
                margin-left: 8px;
            }

            /* Action Buttons */
            .card-actions {
                padding: 15px;
                border-top: 1px solid #f3f4f6;
            }
            .btn-view {
                background: #f3f4f6;
                color: var(--dark);
                border: none;
                width: 40px;
                height: 40px;
                border-radius: 8px;
            }
            .btn-view:hover {
                background: #e5e7eb;
            }
            .btn-add-cart {
                background: var(--primary);
                color: white;
                border: none;
                padding: 0 20px;
                height: 40px;
                border-radius: 8px;
                flex-grow: 1;
                font-weight: 600;
            }
            .btn-add-cart:hover {
                background: var(--primary-light);
            }

            /* Pagination */
            .pagination .page-link {
                color: var(--primary);
                border-radius: 8px;
                margin: 0 3px;
                border: 1px solid #e5e7eb;
            }
            .pagination .active .page-link {
                background-color: var(--primary);
                border-color: var(--primary);
                color: white;
            }
            .tensanpham{
                text-decoration: none;
            }
        </style>
    </head>
    <body>

        <%@include file="Components/navbar.jsp"%>
        <%@include file="Components/alert_message.jsp"%>
        <div class="container py-5">
            <div class="row">

                <div class="col-lg-3 mb-4">
                    <div class="sidebar">

                        <div class="mb-4">
                            <div class="sidebar-title"><i class="fas fa-search"></i> Tìm kiếm</div>
                            <form action="products.jsp" method="get" id="searchForm">
                                <div class="input-group">
                                    <input type="search" 
                                           id="searchInput" 
                                           name="search" 
                                           class="form-control" 
                                           placeholder="Nhập tên sản phẩm..." 
                                           value="<%= searchKey != null ? searchKey : ""%>"
                                           style="border-top-right-radius: 0; border-bottom-right-radius: 0;">

                                    <button type="submit" class="btn btn-primary" style="background-color: #5b21b6; border-top-left-radius: 0; border-bottom-left-radius: 0;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>

                                <% if (currentCatId > 0) {%> 
                                <input type="hidden" name="category" id="hiddenCatId" value="<%=currentCatId%>"> 
                                <% }%>
                            </form>
                        </div>

                        <div class="mb-4">
                            <div class="sidebar-title"><i class="fas fa-list"></i> Danh mục</div>
                            <ul class="category-list">
                                <li class="category-item mb-2">
                                    <a href="products.jsp?category=0" class="<%= currentCatId == 0 ? "active" : ""%>">
                                        <i class="fas fa-layer-group me-2"></i> Tất cả sản phẩm
                                    </a>
                                </li>
                                <% for (Category c : categoryList) {%>
                                <li class="category-item mb-2">
                                    <a href="products.jsp?category=<%=c.getCategoryId()%>" class="<%= c.getCategoryId() == currentCatId ? "active" : ""%>">
                                        <i class="fas fa-tag me-2"></i> <%= c.getCategoryName()%>
                                    </a>
                                </li>
                                <% } %>
                            </ul>
                        </div>

                        <div>
                            <div class="sidebar-title"><i class="fas fa-filter"></i> Lọc theo giá</div>
                            <form action="products.jsp" method="get">
                                <% if (searchKey != null) {%> <input type="hidden" name="search" value="<%=searchKey%>"> <% } %>
                                <% if (currentCatId > 0) {%> <input type="hidden" name="category" value="<%=currentCatId%>"> <% }%>

                                <div class="mb-2">
                                    <label class="small text-muted">Thấp nhất</label>
                                    <input type="number" name="minPrice" class="filter-input" value="<%= minPriceParam != null ? minPriceParam : ""%>">
                                </div>
                                <div class="mb-3">
                                    <label class="small text-muted">Cao nhất</label>
                                    <input type="number" name="maxPrice" class="filter-input" value="<%= maxPriceParam != null ? maxPriceParam : ""%>">
                                </div>
                                <button type="submit" class="btn-filter">
                                    <i class="fas fa-check me-2"></i> Áp dụng
                                </button>
                            </form>
                            <% if (filterInfo.length() > 0) { %>
                            <a href="products.jsp" class="btn btn-sm btn-outline-secondary w-100 mt-2 border-0">Xóa bộ lọc</a>
                            <% }%>
                        </div>

                    </div>
                </div>
                <div class="col-lg-9">

                    <div class="d-flex justify-content-between align-items-center mb-4 bg-white p-3 rounded-3 shadow-sm">
                        <h4 class="mb-0 fw-bold text-dark">
                            <%= message%> <%= filterInfo%>
                        </h4>
                        <span class="badge bg-light text-dark border"><%= totalProducts%> sản phẩm</span>
                    </div>

                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
                        <%
                            for (Product p : prodList) {
                                java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                                boolean isWishlisted = u != null && wishlistDao.getWishlist(u.getUserId(), p.getProductId());
                        %>
                        <div class="col">
                            <div class="card product-card h-100">

                                <% if (p.getProductDiscount() > 0) {%>
                                <span class="badge-discount">-<%= p.getProductDiscount()%>%</span>
                                <% }%>
                                <button class="btn-wishlist <%= isWishlisted ? "active" : ""%>"
                                        onclick="window.location.href = 'WishlistServlet?uid=<%= u != null ? u.getUserId() : 0%>&pid=<%= p.getProductId()%>&op=<%= isWishlisted ? "remove" : "add"%>&return=products'">
                                    <i class="<%= isWishlisted ? "fa-solid" : "fa-regular"%> fa-heart"></i>
                                </button>


                                <a href="viewProduct.jsp?pid=<%= p.getProductId()%>" title="Xem chi tiết">
                                    <div class="img-wrapper">
                                        <img src="Images/<%= p.getProductImages()%>" alt="<%= p.getProductName()%>">
                                    </div>
                                </a>

                                <div class="card-body d-flex flex-column pt-0">

                                    <a href="viewProduct.jsp?pid=<%= p.getProductId()%>" class="tensanpham" title="Xem chi tiết">
                                        <h6 class="card-title text-dark fw-bold mb-2" style="min-height: 40px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                            <%= p.getProductName()%>
                                        </h6>
                                    </a>

                                    <div class="mt-auto mb-3">
                                        <span class="price-current"><%= fmt.format(p.getProductPriceAfterDiscount())%> ₫</span>
                                        <% if (p.getProductDiscount() > 0) {%>
                                        <span class="price-old"><%= fmt.format(p.getProductPrice())%> ₫</span>
                                        <% }%>
                                    </div>
                                </div>

                                <div class="card-actions d-flex gap-2">
                                    <a href="viewProduct.jsp?pid=<%= p.getProductId()%>" class="btn btn-view d-flex align-items-center justify-content-center" title="Xem chi tiết">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <% if (u != null) {%>
                                    <form action="AddToCartServlet" method="post" class="flex-grow-1">
                                        <input type="hidden" name="uid" value="<%= u.getUserId()%>">
                                        <input type="hidden" name="pid" value="<%= p.getProductId()%>">
                                        <input type="hidden" name="page" value="products">
                                        <button type="submit" class="btn btn-add-cart w-100">
                                            <i class="fas fa-cart-plus me-2"></i> Thêm
                                        </button>
                                    </form>
                                    <% } else { %>
                                    <button onclick="window.location.href = 'login.jsp'" class="btn btn-add-cart w-100">
                                        <i class="fas fa-cart-plus me-2"></i> Thêm
                                    </button>
                                    <% } %>
                                </div>

                            </div>
                        </div>
                        <% } %>
                    </div>

                    <%
                        // Chuẩn bị chuỗi query params để giữ lại các bộ lọc khi chuyển trang
                        StringBuilder queryParams = new StringBuilder();
                        if (searchKey != null) {
                            queryParams.append("&search=").append(searchKey);
                        }
                        if (catIdParam != null) {
                            queryParams.append("&category=").append(catIdParam);
                        }
                        if (minPriceParam != null) {
                            queryParams.append("&minPrice=").append(minPriceParam);
                        }
                        if (maxPriceParam != null) {
                            queryParams.append("&maxPrice=").append(maxPriceParam);
                        }
                        String qs = queryParams.toString();
                    %>

                    <% if (totalPages > 1) {%>
                    <nav class="mt-5">
                        <ul class="pagination justify-content-center">
                            <li class="page-item <%= (currentPage == 1) ? "disabled" : ""%>">
                                <a class="page-link" href="?page=<%= currentPage - 1%><%= qs%>"><i class="fas fa-chevron-left"></i></a>
                            </li>

                            <%
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                if (startPage > 1) {
                            %>
                            <li class="page-item"><a class="page-link" href="?page=1<%= qs%>">1</a></li>
                            <% if (startPage > 2) { %><li class="page-item disabled"><span class="page-link">...</span></li><% } %>
                                <% }
                                    for (int i = startPage; i <= endPage; i++) {%>
                            <li class="page-item <%= (i == currentPage) ? "active" : ""%>">
                                <a class="page-link" href="?page=<%= i%><%= qs%>"><%= i%></a>
                            </li>
                            <% }
                                if (endPage < totalPages) {
                                    if (endPage < totalPages - 1) { %><li class="page-item disabled"><span class="page-link">...</span></li><% }
                                %>
                            <li class="page-item"><a class="page-link" href="?page=<%= totalPages%><%= qs%>"><%= totalPages%></a></li>
                                <% }%>

                            <li class="page-item <%= (currentPage == totalPages) ? "disabled" : ""%>">
                                <a class="page-link" href="?page=<%= currentPage + 1%><%= qs%>"><i class="fas fa-chevron-right"></i></a>
                            </li>
                        </ul>
                    </nav>
                    <% }%>
                </div>
            </div>
        </div>
        <script>
            const searchInput = document.getElementById('searchInput');
            const hiddenCatId = document.getElementById('hiddenCatId');

            searchInput.addEventListener('input', function () {
                // Kiểm tra nếu ô tìm kiếm rỗng (người dùng đã xóa hết chữ)
                if (this.value.trim() === "") {

                    let redirectUrl = 'products.jsp';

                    // Nếu đang ở trong một danh mục cụ thể, giữ lại danh mục đó
                    if (hiddenCatId) {
                        redirectUrl += '?category=' + hiddenCatId.value;
                    }

                    // Load lại trang
                    window.location.href = redirectUrl;
                }
            });
            
        </script>
        <%@include file="Components/footer.jsp"%>
    </body>
</html>