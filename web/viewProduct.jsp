<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.ProductDao"%>
<%@page import="dao.CategoryDao"%>
<%@page import="entities.Product"%>
<%@page import="entities.User"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    int productId = Integer.parseInt(request.getParameter("pid"));
    ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
    Product product = productDao.getProductsByProductId(productId);
    
    // Tách thông số kỹ thuật từ cột specifications (dùng dấu ;)
    String specs = product.getSpecifications();
    String[] specArray = specs != null && !specs.trim().isEmpty() ? specs.split(";") : new String[0];
    
    java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getProductName() %> - UnetiShop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        :root {
            --primary: #2563eb;
            --danger: #dc2626;
            --gray: #64748b;
            --light: #f8fafc;
        }
        body { background: #f8fafc; font-family: 'Segoe UI', sans-serif; }

        .product-wrapper {
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
        }

        /* Ảnh sản phẩm */
        .product-gallery {
            padding: 40px;
            background: #f8f9ff;
            text-align: center;
        }
        .product-gallery img {
            max-height: 520px;
            width: auto;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            transition: transform 0.5s ease;
        }
        .product-gallery img:hover {
            transform: scale(1.05);
        }

        /* Thông tin bên phải */
        .product-info {
            padding: 40px;
        }
        .price-big {
            font-size: 3rem;
            font-weight: 800;
            color: var(--danger);
        }
        .price-old {
            font-size: 1.4rem;
            color: #94a3b8;
            text-decoration: line-through;
            margin-left: 15px;
        }
        .discount-badge {
            background: var(--danger);
            color: white;
            padding: 8px 16px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            margin-left: 15px;
        }

        /* Bảng thông số kỹ thuật - ĐẸP NHƯ SHOPEE */
        .spec-section {
            margin-top: 20px;
            margin-bottom: 30px;
            background: #f8f9ff;
            border-radius: 16px;
            padding: 30px;
            border: 1px solid #e2e8f0;
        }
        .spec-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 1rem;
        }
        .spec-table td {
            padding: 16px 20px;
            border-bottom: 1px solid #e2e8f0;
        }
        .spec-table tr td:first-child {
            background: #f1f5f9;
            font-weight: 600;
            width: 35%;
            color: var(--gray);
        }
        .spec-table tr:last-child td {
            border-bottom: none;
        }

        .btn-add-cart, .btn-buy-now {
            border-radius: 12px;
            padding: 16px 40px;
            font-size: 1.2rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-add-cart {
            background: var(--primary);
            color: white;
            border: none;
        }
        .btn-add-cart:hover {
            background: #1d4ed8;
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(37,99,235,0.4);
        }
        .btn-buy-now {
            background: var(--danger);
            color: white;
            border: none;
        }
        .btn-buy-now:hover {
            background: #b91c1c;
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(220,38,38,0.4);
        }

        /* Phần số lượng sản phẩm - ĐẸP HƠN */
        .quantity-section {
            background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
            border-radius: 16px;
            padding: 24px;
            border: 2px solid #e2e8f0;
            margin-bottom: 24px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .quantity-label {
            font-size: 1.1rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .quantity-label i {
            color: var(--primary);
            font-size: 1.2rem;
        }
        .quantity-controls {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .qty-btn {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            border: 2px solid #e2e8f0;
            background: white;
            color: #475569;
            font-size: 1.2rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .qty-btn:hover:not(:disabled) {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(37,99,235,0.3);
        }
        .qty-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f1f5f9;
        }
        .qty-input {
            width: 100px;
            height: 48px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            text-align: center;
            font-size: 1.4rem;
            font-weight: 700;
            color: #1e293b;
            background: white;
            transition: all 0.3s ease;
        }
        .qty-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
        }
        .stock-info {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
            border-radius: 12px;
            border-left: 4px solid #10b981;
            margin-left: auto;
        }
        .stock-info i {
            color: #10b981;
            font-size: 1.1rem;
        }
        .stock-info strong {
            color: #065f46;
            font-size: 1.1rem;
        }
        .stock-info .text-muted {
            color: #047857;
            font-size: 0.95rem;
        }

        @media (max-width: 992px) {
            .product-info { padding: 30px 20px; }
            .product-gallery { padding: 20px; }
            .price-big { font-size: 2.4rem; }
            .quantity-controls {
                flex-direction: column;
                align-items: stretch;
            }
            .stock-info {
                margin-left: 0;
                margin-top: 12px;
            }
        }
    </style>
</head>
<body>

    <%@include file="Components/navbar.jsp"%>
    <%@include file="Components/alert_message.jsp"%>

    <div class="container-fluid">
        <div class="product-wrapper">
            <div class="row g-0">
                <!-- Ảnh + Thông số kỹ thuật -->
                <div class="col-lg-6">
                    <!-- Ảnh sản phẩm -->
                    <div class="product-gallery">
                        <img src="Images<%= product.getProductImages() %>" alt="<%= product.getProductName() %>">
                    </div>
                </div>

                <!-- Thông tin chi tiết (giá, mô tả, nút mua) -->
                <div class="col-lg-6">
                    <div class="product-info">
                        <h1 class="fw-bold mb-3"><%= product.getProductName() %></h1>

                        <!-- Giá -->
                        <div class="d-flex align-items-center mb-4">
                            <span class="price-big">
                                <%= fmt.format(product.getProductPriceAfterDiscount()) %> ₫
                            </span>
                            <% if (product.getProductDiscount() > 0) { %>
                                <span class="price-old">
                                    <%= fmt.format(product.getProductPrice()) %> ₫
                                </span>
                                <span class="discount-badge">
                                    -<%= product.getProductDiscount() %>%
                                </span>
                            <% } %>
                        </div>

                        <!-- Mô tả -->
                        <p class="text-muted fs-5 lh-lg mb-3">
                            <%= product.getProductDescription() %>
                        </p>

                        <!-- Thông tin phụ -->
                        <div class="row g-4 mb-3">
                            <div class="col-md-4">
                                <div class="d-flex align-items-center gap-3">
                                    <i class="fas fa-truck text-primary fs-3"></i>
                                    <div>
                                        <strong>Giao hàng</strong><br>
                                        <small class="text-muted">Giao nhanh 2h nội thành</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex align-items-center gap-3">
                                    <i class="fas fa-shield-alt text-success fs-3"></i>
                                    <div>
                                        <strong>Bảo hành</strong><br>
                                        <small class="text-muted">24 tháng chính hãng</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex align-items-center gap-3">
                                    <i class="fas fa-box-open text-warning fs-3"></i>
                                    <div>
                                        <strong>Đóng gói</strong><br>
                                        <small class="text-muted">Nguyên seal, đầy đủ phụ kiện</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <% 
                            int stock = product.getProductQunatity();
                            int maxQty = stock > 0 ? stock : 1;
                        %>
                        <% if (stock > 0) { %>
                        <div class="quantity-section">
                            <div class="quantity-label">
                                <i class="fas fa-shopping-bag"></i>
                                <span>Số lượng</span>
                            </div>
                            <div class="quantity-controls">
                                <button type="button" class="qty-btn decrease" 
                                        onclick="changeQuantity(-1, <%= maxQty %>)"
                                        title="Giảm số lượng">
                                    <i class="fas fa-minus"></i>
                                </button>
                                <input type="text" id="quantity" name="quantity" value="1" readonly
                                       class="qty-input">
                                <button type="button" class="qty-btn increase"
                                        onclick="changeQuantity(1, <%= maxQty %>)"
                                        title="Tăng số lượng">
                                    <i class="fas fa-plus"></i>
                                </button>
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i>
                                    <span class="text-muted">Còn</span>
                                    <strong><%= stock %></strong>
                                    <span class="text-muted">sản phẩm</span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        
                        <!-- ====================== NÚT HÀNH ĐỘNG ====================== -->
                        <div class="d-flex gap-3 flex-wrap">
                            <% if (user == null) { %>
                                <button onclick="location.href='login.jsp'" class="btn btn-add-cart btn-lg px-5">
                                    <i class="fas fa-cart-plus me-2"></i> Thêm vào giỏ hàng
                                </button>
                                <button onclick="location.href='login.jsp'" class="btn btn-buy-now btn-lg px-5">
                                    Mua ngay
                                </button>

                            <% } else { %>
                                <% if (stock > 0) { %>
                                    <form action="AddToCartServlet" method="post" class="d-inline">
                                        <input type="hidden" name="uid" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="pid" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="quantity" id="hidden-qty" value="1">
                                        <button type="submit" class="btn btn-add-cart btn-lg px-5">
                                            <i class="fas fa-cart-plus me-2"></i> Thêm vào giỏ hàng
                                        </button>
                                    </form>

                                    <form action="checkout.jsp" method="post" class="d-inline" id="buyNowForm" onsubmit="return updateBuyNowQuantity()">
                                        <input type="hidden" name="pid" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="quantity" id="buy-now-qty" value="1">
                                        <button type="submit" class="btn btn-buy-now btn-lg px-5">
                                            Mua ngay
                                        </button>
                                    </form>
                                    <script>
                                        function updateBuyNowQuantity() {
                                            var qtyInput = document.getElementById('quantity');
                                            var buyNowQtyInput = document.getElementById('buy-now-qty');
                                            if (qtyInput && buyNowQtyInput) {
                                                buyNowQtyInput.value = qtyInput.value;
                                            }
                                            return true; // Cho phép form submit
                                        }
                                    </script>
                                <% } else { %>
                                    <button class="btn btn-secondary btn-lg px-5" disabled>
                                        <i class="fas fa-ban"></i> Hết hàng
                                    </button>
                                <% } %>
                            <% } %>
                        </div>

                        <!-- Thông báo hết hàng -->
                        <% if (stock <= 0) { %>
                            <div class="alert alert-danger mt-4 text-center fw-bold fs-5">
                                <i class="fas fa-times-circle"></i> Hiện tại sản phẩm đã hết hàng
                            </div>
                        <% } %>
                </div>
            </div>
                
                <div class="col-lg-12">
                    <!-- Bảng thông số kỹ thuật - ĐẶT DƯỚI ẢNH -->
                        <% if (specArray.length > 0) { %>
                        <div class="spec-section container">
                            <h4 class="fw-bold mb-4 text-primary">
                                Thông số kỹ thuật
                            </h4>
                            <table class="spec-table">
                                <% for (String spec : specArray) {
                                    if (spec.trim().isEmpty()) continue;
                                    String[] parts = spec.split(":", 2);
                                    String label = parts.length > 0 ? parts[0].trim() : "Thông số";
                                    String value = parts.length > 1 ? parts[1].trim() : spec.trim();
                                %>
                                <tr>
                                    <td><%= label %></td>
                                    <td><%= value %></td>
                                </tr>
                                <% } %>
                            </table>
                        </div>
                        <% } %>
                                        <!-- ====================== ĐÁNH GIÁ SẢN PHẨM ====================== -->
                <div class="container mt-5">
                    <div class="bg-white rounded-4 shadow-lg p-4 p-md-5" style="border: 1px solid #e2e8f0;">
                        <h3 class="fw-bold text-primary mb-4">
                            <i class="fas fa-star text-warning"></i> Đánh giá sản phẩm
                        </h3>

                        <!-- Tổng quan đánh giá -->
                        <div class="row align-items-center mb-5">
                            <div class="col-md-4 text-center">
                                <div class="display-4 fw-bold text-primary">4.8</div>
                                <div class="stars fs-3 text-warning">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star-half-alt"></i>
                                </div>
                                <p class="text-muted mt-2">Dựa trên 128 đánh giá</p>
                            </div>
                            <div class="col-md-8">
                                <div class="row g-2">
                                    <div class="col-12 d-flex align-items-center">
                                        <span class="me-3 fw-bold">5</span>
                                        <div class="progress flex-grow-1" style="height: 12px;">
                                            <div class="progress-bar bg-warning" style="width: 78%"></div>
                                        </div>
                                        <span class="ms-3 text-muted">78%</span>
                                    </div>
                                    <div class="col-12 d-flex align-items-center">
                                        <span class="me-3 fw-bold">4</span>
                                        <div class="progress flex-grow-1" style="height: 12px;">
                                            <div class="progress-bar bg-warning" style="width: 15%"></div>
                                        </div>
                                        <span class="ms-3 text-muted">15%</span>
                                    </div>
                                    <div class="col-12 d-flex align-items-center">
                                        <span class="me-3 fw-bold">3</span>
                                        <div class="progress flex-grow-1" style="height: 12px;">
                                            <div class="progress-bar bg-warning" style="width: 5%"></div>
                                        </div>
                                        <span class="ms-3 text-muted">5%</span>
                                    </div>
                                    <div class="col-12 d-flex align-items-center">
                                        <span class="me-3 fw-bold">2</span>
                                        <div class="progress flex-grow-1" style="height: 12px;">
                                            <div class="progress-bar bg-warning" style="width: 2%"></div>
                                        </div>
                                        <span class="ms-3 text-muted">2%</span>
                                    </div>
                                    <div class="col-12 d-flex align-items-center">
                                        <span class="me-3 fw-bold">1</span>
                                        <div class="progress flex-grow-1" style="height: 12px;">
                                            <div class="progress-bar bg-danger" style="width: 0%"></div>
                                        </div>
                                        <span class="ms-3 text-muted">0%</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Form đánh giá (chỉ hiện khi đã đăng nhập) -->
                        <% if (user != null) { %>
                        <div class="border rounded-4 p-4 mb-5" style="background: #f8f9ff;">
                            <h5 class="fw-bold mb-3">Chia sẻ trải nghiệm của bạn</h5>
                            <form action="AddReviewServlet" method="post">
                                <input type="hidden" name="pid" value="<%= product.getProductId() %>">
                                <input type="hidden" name="uid" value="<%= user.getUserId() %>">

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Đánh giá của bạn</label>
                                    <div class="star-rating">
                                        <input type="radio" name="rating" value="5" id="star5" required>
                                        <label for="star5"><i class="fas fa-star"></i></label>
                                        <input type="radio" name="rating" value="4" id="star4">
                                        <label for="star4"><i class="fas fa-star"></i></label>
                                        <input type="radio" name="rating" value="3" id="star3">
                                        <label for="star3"><i class="fas fa-star"></i></label>
                                        <input type="radio" name="rating" value="2" id="star2">
                                        <label for="star2"><i class="fas fa-star"></i></label>
                                        <input type="radio" name="rating" value="1" id="star1">
                                        <label for="star1"><i class="fas fa-star"></i></label>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <textarea name="comment" class="form-control" rows="4" 
                                              placeholder="Hãy chia sẻ cảm nhận của bạn về sản phẩm này..." 
                                              style="border-radius: 16px; padding: 16px;" required></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary btn-lg px-5 rounded-pill">
                                    Gửi đánh giá
                                </button>
                            </form>
                        </div>
                        <% } else { %>
                        <div class="text-center py-5 bg-light rounded-4">
                            <i class="fas fa-comment-dots fs-1 text-muted mb-3"></i>
                            <p class="text-muted fs-5">Đăng nhập để viết đánh giá</p>
                            <a href="login.jsp" class="btn btn-outline-primary rounded-pill px-4">Đăng nhập ngay</a>
                        </div>
                        <% } %>

                        <!-- Danh sách đánh giá -->
                        <h5 class="fw-bold mb-4 mt-5">Ý kiến khách hàng</h5>
                        <div class="row g-4" id="reviewsContainer">
                            <!-- Review mẫu 1 -->
                            <div class="col-12 review-item">
                                <div class="d-flex gap-3 p-4 border rounded-4" style="background: #f8f9ff;">
                                    <img src="https://via.placeholder.com/60" class="rounded-circle" alt="User">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="fw-bold m-0">Nguyễn Văn A</h6>
                                            <small class="text-muted">12/04/2025</small>
                                        </div>
                                        <div class="text-warning mb-2">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                                        </div>
                                        <p class="mb-0">Sản phẩm rất tốt, giao hàng nhanh, đóng gói cẩn thận. Mình rất hài lòng!</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Review mẫu 2 -->
                            <div class="col-12 review-item">
                                <div class="d-flex gap-3 p-4 border rounded-4">
                                    <img src="https://via.placeholder.com/60" class="rounded-circle" alt="User">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="fw-bold m-0">Trần Thị B</h6>
                                            <small class="text-muted">08/04/2025</small>
                                        </div>
                                        <div class="text-warning mb-2">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>
                                        </div>
                                        <p class="mb-0">Chất lượng ổn, giá hơi cao nhưng đáng tiền. Sẽ ủng hộ shop tiếp!</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Review mẫu 3 -->
                            <div class="col-12 review-item review-item-hidden">
                                <div class="d-flex gap-3 p-4 border rounded-4">
                                    <img src="https://via.placeholder.com/60" class="rounded-circle" alt="User">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="fw-bold m-0">Lê Văn C</h6>
                                            <small class="text-muted">05/04/2025</small>
                                        </div>
                                        <div class="text-warning mb-2">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                                        </div>
                                        <p class="mb-0">Tuyệt vời! Sản phẩm đúng như mô tả, chất lượng tốt, giá cả hợp lý. Đã mua lần 2 rồi!</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Review mẫu 4 -->
                            <div class="col-12 review-item review-item-hidden">
                                <div class="d-flex gap-3 p-4 border rounded-4" style="background: #f8f9ff;">
                                    <img src="https://via.placeholder.com/60" class="rounded-circle" alt="User">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="fw-bold m-0">Phạm Thị D</h6>
                                            <small class="text-muted">01/04/2025</small>
                                        </div>
                                        <div class="text-warning mb-2">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i><i class="far fa-star"></i>
                                        </div>
                                        <p class="mb-0">Sản phẩm ổn nhưng giao hàng hơi chậm. Chất lượng đúng như mong đợi.</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Review mẫu 5 -->
                            <div class="col-12 review-item review-item-hidden">
                                <div class="d-flex gap-3 p-4 border rounded-4">
                                    <img src="https://via.placeholder.com/60" class="rounded-circle" alt="User">
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="fw-bold m-0">Hoàng Văn E</h6>
                                            <small class="text-muted">28/03/2025</small>
                                        </div>
                                        <div class="text-warning mb-2">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                                        </div>
                                        <p class="mb-0">Rất hài lòng với sản phẩm này. Đóng gói cẩn thận, giao hàng đúng hẹn. Sẽ quay lại mua tiếp!</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="text-center mt-4" id="showMoreReviewsBtn" style="display: none;">
                            <button type="button" class="btn btn-outline-primary rounded-pill px-5" onclick="toggleReviews()">
                                <i class="fas fa-chevron-down me-2"></i>Xem thêm đánh giá
                            </button>
                        </div>
                        <div class="text-center mt-4" id="showLessReviewsBtn" style="display: none;">
                            <button type="button" class="btn btn-outline-secondary rounded-pill px-5" onclick="toggleReviews()">
                                <i class="fas fa-chevron-up me-2"></i>Thu gọn
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
                </div>
        </div>
    </div>

    <%@include file="Components/footer.jsp"%>
</body>
</html>

<!-- JavaScript xử lý cộng trừ số lượng -->
    <script>
        function changeQuantity(change, maxQty) {
            let input = document.getElementById('quantity');
            let hiddenInput = document.getElementById('hidden-qty');
            let buyNowQtyInput = document.getElementById('buy-now-qty');
            let current = parseInt(input.value);
            let newQty = current + change;
            console.log(newQty);

            if (newQty < 1) newQty = 1;
            if (newQty > maxQty) newQty = maxQty;

            input.value = newQty;
            if (hiddenInput) hiddenInput.value = newQty;
            if (buyNowQtyInput) buyNowQtyInput.value = newQty;

            // Cập nhật nút
            document.querySelector('.decrease').disabled = (newQty <= 1);
            document.querySelector('.increase').disabled = (newQty >= maxQty);

            // Hiệu ứng viền đỏ khi đạt giới hạn
            if (newQty >= maxQty || newQty <= 1) {
                input.style.borderColor = '#dc3545';
                input.style.color = '#dc3545';
                input.style.boxShadow = '0 0 0 3px rgba(220,38,38,0.1)';
            } else {
                input.style.borderColor = '#e2e8f0';
                input.style.color = '#1e293b';
                input.style.boxShadow = 'none';
            }
        }

        // Khởi tạo ban đầu
        document.addEventListener('DOMContentLoaded', function() {
            const qty = parseInt(document.getElementById('quantity')?.value || 1);
            const max = <%= maxQty %>;
            const qtyInput = document.getElementById('quantity');
            const increaseBtn = document.querySelector('.increase');
            
            if (qty >= max) {
                if (increaseBtn) increaseBtn.disabled = true;
                if (qtyInput) {
                    qtyInput.style.borderColor = '#dc3545';
                    qtyInput.style.color = '#dc3545';
                    qtyInput.style.boxShadow = '0 0 0 3px rgba(220,38,38,0.1)';
                }
            }
            if (qty <= 1) {
                const decreaseBtn = document.querySelector('.decrease');
                if (decreaseBtn) decreaseBtn.disabled = true;
            }

            // Logic xử lý nút "Xem thêm đánh giá"
            initReviewsToggle();
        });

        // Khởi tạo logic reviews
        function initReviewsToggle() {
            const reviewItems = document.querySelectorAll('.review-item');
            const hiddenReviews = document.querySelectorAll('.review-item-hidden');
            const showMoreBtn = document.getElementById('showMoreReviewsBtn');
            const showLessBtn = document.getElementById('showLessReviewsBtn');
            
            // Ẩn các review từ thứ 3 trở đi
            hiddenReviews.forEach(function(item) {
                item.style.display = 'none';
            });
            
            // Chỉ hiển thị nút "Xem thêm" nếu có hơn 2 review
            if (reviewItems.length > 2 && showMoreBtn) {
                showMoreBtn.style.display = 'block';
            }
        }

        // Toggle hiển thị/ẩn reviews
        function toggleReviews() {
            const hiddenReviews = document.querySelectorAll('.review-item-hidden');
            const showMoreBtn = document.getElementById('showMoreReviewsBtn');
            const showLessBtn = document.getElementById('showLessReviewsBtn');
            
            if (!hiddenReviews.length) return;
            
            // Kiểm tra xem đang ẩn hay hiện
            const isHidden = hiddenReviews[0].style.display === 'none' || hiddenReviews[0].style.display === '';
            
            if (isHidden) {
                // Hiển thị tất cả reviews
                hiddenReviews.forEach(function(item, index) {
                    setTimeout(function() {
                        item.style.display = 'block';
                        item.style.animation = 'fadeIn 0.3s ease-in';
                    }, index * 50); // Stagger animation
                });
                if (showMoreBtn) showMoreBtn.style.display = 'none';
                if (showLessBtn) showLessBtn.style.display = 'block';
            } else {
                // Ẩn các reviews từ thứ 3 trở đi
                hiddenReviews.forEach(function(item) {
                    item.style.display = 'none';
                });
                if (showMoreBtn) showMoreBtn.style.display = 'block';
                if (showLessBtn) showLessBtn.style.display = 'none';
            }
        }
    </script>
    
    <style>
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>