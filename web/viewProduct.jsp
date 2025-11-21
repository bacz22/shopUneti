<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="entities.Review"%>
<%@page import="dao.ReviewDao"%>
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
    
    // Tách thông số kỹ thuật
    String specs = product.getSpecifications();
    String[] specArray = specs != null && !specs.trim().isEmpty() ? specs.split(";") : new String[0];
    
    java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
    
    // XỬ LÝ ĐÁNH GIÁ
    ReviewDao reviewDao = new ReviewDao(ConnectionProvider.getConnection());
    List<Review> reviews = reviewDao.getReviewsByProductId(productId);
    
    // Tính điểm trung bình
    float avgRating = 0;
    if(reviews.size() > 0) {
        int sum = 0;
        for(Review r : reviews) sum += r.getRating();
        avgRating = (float) sum / reviews.size();
    }
    
    // Kiểm tra quyền đánh giá
    // --- SỬA LỖI TẠI ĐÂY: Đổi tên 'user' thành 'currentUser' ---
    User currentUser = (User) session.getAttribute("activeUser");
    boolean canReview = false;
    if(currentUser != null) {
        canReview = reviewDao.hasUserBoughtProduct(currentUser.getUserId(), productId);
    }
    
    SimpleDateFormat sdfDate = new SimpleDateFormat("dd/MM/yyyy");
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
        :root { --primary: #2563eb; --danger: #dc2626; --gray: #64748b; --light: #f8fafc; }
        body { background: #f8fafc; font-family: 'Segoe UI', sans-serif; }

        .product-wrapper { max-width: 1200px; margin: 30px auto; background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 15px 40px rgba(0,0,0,0.1); }
        
        /* Ảnh sản phẩm */
        .product-gallery { padding: 40px; background: #f8f9ff; text-align: center; }
        .product-gallery img { max-height: 520px; width: auto; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); transition: transform 0.5s ease; }
        .product-gallery img:hover { transform: scale(1.05); }

        /* Thông tin bên phải */
        .product-info { padding: 40px; }
        .price-big { font-size: 3rem; font-weight: 800; color: var(--danger); }
        .price-old { font-size: 1.4rem; color: #94a3b8; text-decoration: line-through; margin-left: 15px; }
        .discount-badge { background: var(--danger); color: white; padding: 8px 16px; border-radius: 50px; font-weight: 700; font-size: 1.1rem; margin-left: 15px; }

        /* Bảng thông số */
        .spec-section { margin-top: 20px; margin-bottom: 30px; background: #f8f9ff; border-radius: 16px; padding: 30px; border: 1px solid #e2e8f0; }
        .spec-table { width: 100%; border-collapse: collapse; font-size: 1rem; }
        .spec-table td { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
        .spec-table tr td:first-child { background: #f1f5f9; font-weight: 600; width: 35%; color: var(--gray); }
        .spec-table tr:last-child td { border-bottom: none; }

        /* Nút mua hàng */
        .btn-add-cart, .btn-buy-now { border-radius: 12px; padding: 16px 40px; font-size: 1.2rem; font-weight: 600; transition: all 0.3s ease; }
        .btn-add-cart { background: var(--primary); color: white; border: none; }
        .btn-add-cart:hover { background: #1d4ed8; transform: translateY(-4px); box-shadow: 0 10px 25px rgba(37,99,235,0.4); }
        .btn-buy-now { background: var(--danger); color: white; border: none; }
        .btn-buy-now:hover { background: #b91c1c; transform: translateY(-4px); box-shadow: 0 10px 25px rgba(220,38,38,0.4); }

        /* Số lượng */
        .quantity-section { background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%); border-radius: 16px; padding: 24px; border: 2px solid #e2e8f0; margin-bottom: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .quantity-label { font-size: 1.1rem; font-weight: 600; color: #1e293b; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
        .quantity-label i { color: var(--primary); font-size: 1.2rem; }
        .quantity-controls { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .qty-btn { width: 48px; height: 48px; border-radius: 12px; border: 2px solid #e2e8f0; background: white; color: #475569; font-size: 1.2rem; font-weight: 600; display: flex; align-items: center; justify-content: center; transition: all 0.3s ease; cursor: pointer; }
        .qty-btn:hover:not(:disabled) { background: var(--primary); color: white; border-color: var(--primary); transform: scale(1.05); box-shadow: 0 4px 12px rgba(37,99,235,0.3); }
        .qty-btn:disabled { opacity: 0.5; cursor: not-allowed; background: #f1f5f9; }
        .qty-input { width: 100px; height: 48px; border: 2px solid #e2e8f0; border-radius: 12px; text-align: center; font-size: 1.4rem; font-weight: 700; color: #1e293b; background: white; transition: all 0.3s ease; }
        .qty-input:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(37,99,235,0.1); }
        
        /* Stock Info */
        .stock-info { display: flex; align-items: center; gap: 8px; padding: 12px 20px; background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%); border-radius: 12px; border-left: 4px solid #10b981; margin-left: auto; }
        .stock-info i { color: #10b981; font-size: 1.1rem; }
        .stock-info strong { color: #065f46; font-size: 1.1rem; }
        .stock-info .text-muted { color: #047857; font-size: 0.95rem; }

        /* Responsive */
        @media (max-width: 992px) {
            .product-info { padding: 30px 20px; }
            .product-gallery { padding: 20px; }
            .price-big { font-size: 2.4rem; }
            .quantity-controls { flex-direction: column; align-items: stretch; }
            .stock-info { margin-left: 0; margin-top: 12px; }
        }
        
        /* Star Rating Input */
        .star-rating { direction: rtl; display: inline-block; font-size: 1.5em; }
        .star-rating input { display: none; }
        .star-rating label { color: #ddd; cursor: pointer; margin: 0 2px; transition: color 0.2s; }
        .star-rating input:checked ~ label, .star-rating label:hover, .star-rating label:hover ~ label { color: #ffc107; }
        
        /* Animation */
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

    <%@include file="Components/navbar.jsp"%>
    <%@include file="Components/alert_message.jsp"%>

    <div class="container-fluid">
        <div class="product-wrapper">
            <div class="row g-0">
                <div class="col-lg-6">
                    <div class="product-gallery">
                        <img src="Images/<%= product.getProductImages() %>" alt="<%= product.getProductName() %>">
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="product-info">
                        <h1 class="fw-bold mb-3"><%= product.getProductName() %></h1>

                        <div class="d-flex align-items-center mb-4">
                            <span class="price-big"><%= fmt.format(product.getProductPriceAfterDiscount()) %> ₫</span>
                            <% if (product.getProductDiscount() > 0) { %>
                                <span class="price-old"><%= fmt.format(product.getProductPrice()) %> ₫</span>
                                <span class="discount-badge">-<%= product.getProductDiscount() %>%</span>
                            <% } %>
                        </div>

                        <p class="text-muted fs-5 lh-lg mb-3"><%= product.getProductDescription() %></p>

                        <div class="row g-4 mb-3">
                            <div class="col-md-4"><div class="d-flex align-items-center gap-3"><i class="fas fa-truck text-primary fs-3"></i><div><strong>Giao hàng</strong><br><small class="text-muted">Nhanh 2h nội thành</small></div></div></div>
                            <div class="col-md-4"><div class="d-flex align-items-center gap-3"><i class="fas fa-shield-alt text-success fs-3"></i><div><strong>Bảo hành</strong><br><small class="text-muted">24 tháng chính hãng</small></div></div></div>
                            <div class="col-md-4"><div class="d-flex align-items-center gap-3"><i class="fas fa-box-open text-warning fs-3"></i><div><strong>Đóng gói</strong><br><small class="text-muted">Nguyên seal</small></div></div></div>
                        </div>
                        
                        <% 
                            int stock = product.getProductQunatity();
                            int maxQty = stock > 0 ? stock : 1;
                        %>
                        <% if (stock > 0) { %>
                        <div class="quantity-section">
                            <div class="quantity-label"><i class="fas fa-shopping-bag"></i><span>Số lượng</span></div>
                            <div class="quantity-controls">
                                <button type="button" class="qty-btn decrease" onclick="changeQuantity(-1, <%= maxQty %>)"><i class="fas fa-minus"></i></button>
                                <input type="text" id="quantity" name="quantity" value="1" readonly class="qty-input">
                                <button type="button" class="qty-btn increase" onclick="changeQuantity(1, <%= maxQty %>)"><i class="fas fa-plus"></i></button>
                                
                                <div class="stock-info">
                                    <i class="fas fa-check-circle"></i><span class="text-muted">Còn</span><strong><%= stock %></strong><span class="text-muted">sản phẩm</span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                        
                        <div class="d-flex gap-3 flex-wrap">
                            <% if (user == null) { %>
                                <button onclick="location.href='login.jsp'" class="btn btn-add-cart btn-lg px-5"><i class="fas fa-cart-plus me-2"></i> Thêm vào giỏ</button>
                                <button onclick="location.href='login.jsp'" class="btn btn-buy-now btn-lg px-5">Mua ngay</button>
                            <% } else { %>
                                <% if (stock > 0) { %>
                                    <form action="AddToCartServlet" method="post" class="d-inline">
                                        <input type="hidden" name="uid" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="pid" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="quantity" id="hidden-qty" value="1">
                                        <button type="submit" class="btn btn-add-cart btn-lg px-5"><i class="fas fa-cart-plus me-2"></i> Thêm vào giỏ</button>
                                    </form>

                                    <form action="checkout.jsp" method="post" class="d-inline" id="buyNowForm">
                                        <input type="hidden" name="pid" value="<%= product.getProductId() %>">
                                        <input type="hidden" name="quantity" id="buy-now-qty" value="1">
                                        <button type="submit" class="btn btn-buy-now btn-lg px-5" onclick="updateBuyNowQuantity()">Mua ngay</button>
                                    </form>
                                <% } else { %>
                                    <button class="btn btn-secondary btn-lg px-5" disabled><i class="fas fa-ban"></i> Hết hàng</button>
                                <% } %>
                            <% } %>
                        </div>

                        <% if (stock <= 0) { %>
                            <div class="alert alert-danger mt-4 text-center fw-bold fs-5"><i class="fas fa-times-circle"></i> Sản phẩm đã hết hàng</div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container mt-4">
        <% if (specArray.length > 0) { %>
        <div class="spec-section">
            <h4 class="fw-bold mb-4 text-primary">Thông số kỹ thuật</h4>
            <table class="spec-table">
                <% for (String spec : specArray) {
                    if (spec.trim().isEmpty()) continue;
                    String[] parts = spec.split(":", 2);
                    String label = parts.length > 0 ? parts[0].trim() : "Thông số";
                    String value = parts.length > 1 ? parts[1].trim() : spec.trim();
                %>
                <tr><td><%= label %></td><td><%= value %></td></tr>
                <% } %>
            </table>
        </div>
        <% } %>
    </div>

    <div class="container mt-5">
        <div class="bg-white rounded-4 shadow-lg p-4 p-md-5 border">
            <h3 class="fw-bold text-primary mb-4"><i class="fas fa-star text-warning"></i> Đánh giá sản phẩm</h3>
            
            <div class="row align-items-center mb-5">
                <div class="col-md-4 text-center">
                    <div class="display-4 fw-bold text-primary"><%= String.format("%.1f", avgRating) %></div>
                    <div class="text-warning fs-3">
                        <% for(int i=1; i<=5; i++) { %>
                            <% if(i <= avgRating) { %><i class="fas fa-star"></i>
                            <% } else if(i - 0.5 <= avgRating) { %><i class="fas fa-star-half-alt"></i>
                            <% } else { %><i class="far fa-star"></i><% } %>
                        <% } %>
                    </div>
                    <p class="text-muted mt-2">Dựa trên <%= reviews.size() %> đánh giá</p>
                </div>
                <div class="col-md-8"><p class="text-muted fst-italic">Thống kê chi tiết...</p></div>
            </div>

            <% if (user != null) { %>
                <% if (canReview) { %>
                    <div class="border rounded-4 p-4 mb-5" style="background: #f8f9ff;">
                        <h5 class="fw-bold mb-3">Chia sẻ trải nghiệm của bạn</h5>
                        <form action="AddReviewServlet" method="post">
                            <input type="hidden" name="pid" value="<%= productId %>">
                            <input type="hidden" name="uid" value="<%= user.getUserId() %>">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Đánh giá:</label>
                                <div class="star-rating">
                                    <input type="radio" name="rating" value="5" id="star5" required><label for="star5"><i class="fas fa-star"></i></label>
                                    <input type="radio" name="rating" value="4" id="star4"><label for="star4"><i class="fas fa-star"></i></label>
                                    <input type="radio" name="rating" value="3" id="star3"><label for="star3"><i class="fas fa-star"></i></label>
                                    <input type="radio" name="rating" value="2" id="star2"><label for="star2"><i class="fas fa-star"></i></label>
                                    <input type="radio" name="rating" value="1" id="star1"><label for="star1"><i class="fas fa-star"></i></label>
                                </div>
                            </div>
                            <div class="mb-3">
                                <textarea name="comment" class="form-control" rows="3" placeholder="Sản phẩm thế nào?..." required></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary rounded-pill px-5">Gửi đánh giá</button>
                        </form>
                    </div>
                <% } else { %>
                    <div class="alert alert-warning text-center mb-5"><i class="fas fa-info-circle me-2"></i> Bạn cần mua sản phẩm này mới có thể đánh giá.</div>
                <% } %>
            <% } else { %>
                <div class="text-center py-4 bg-light rounded-4 mb-5">
                    <p class="text-muted mb-3">Đăng nhập để viết đánh giá</p>
                    <a href="login.jsp" class="btn btn-outline-primary rounded-pill px-4">Đăng nhập ngay</a>
                </div>
            <% } %>

            <h5 class="fw-bold mb-4">Ý kiến khách hàng (<%= reviews.size() %>)</h5>
            <div class="row g-4">
                <% if(reviews.isEmpty()) { %>
                    <p class="text-muted text-center">Chưa có đánh giá nào.</p>
                <% } else { 
                    int count = 0;
                    for(Review r : reviews) { 
                        count++;
                        String hiddenClass = (count > 3) ? "review-item-hidden" : "";
                        String userInitial = (r.getUserName() != null) ? r.getUserName().substring(0, 1).toUpperCase() : "U";
                %>
                <div class="col-12 review-item <%= hiddenClass %>" <% if(count > 3) { %>style="display:none;"<% } %>>
                    <div class="d-flex gap-3 p-4 border rounded-4" style="background: #fff;">
                        <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center fw-bold" style="width:50px; height:50px; font-size:1.2rem;">
                            <%= userInitial %>
                        </div>
                        <div class="flex-grow-1">
                            <div class="d-flex justify-content-between align-items-center mb-1">
                                <h6 class="fw-bold m-0"><%= r.getUserName() %></h6>
                                <small class="text-muted"><%= sdfDate.format(r.getReviewDate()) %></small>
                            </div>
                            <div class="text-warning mb-2 small">
                                <% for(int j=0; j<r.getRating(); j++) { %><i class="fas fa-star"></i><% } %>
                                <% for(int j=r.getRating(); j<5; j++) { %><i class="far fa-star"></i><% } %>
                            </div>
                            <p class="mb-0 text-secondary"><%= r.getComment() %></p>
                            <div class="mt-2 text-success small"><i class="fas fa-check-circle"></i> Đã mua hàng</div>
                        </div>
                    </div>
                </div>
                <% } } %>
            </div>

            <% if(reviews.size() > 3) { %>
                <div class="text-center mt-4" id="showMoreReviewsBtn">
                    <button type="button" class="btn btn-outline-primary rounded-pill px-5" onclick="toggleReviews()">
                        <i class="fas fa-chevron-down me-2"></i>Xem thêm đánh giá
                    </button>
                </div>
                <div class="text-center mt-4" id="showLessReviewsBtn" style="display: none;">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-5" onclick="toggleReviews()">
                        <i class="fas fa-chevron-up me-2"></i>Thu gọn
                    </button>
                </div>
            <% } %>
        </div>
    </div>

    <%@include file="Components/footer.jsp"%>

    <script>
        function changeQuantity(change, maxQty) {
            let input = document.getElementById('quantity');
            let hiddenInput = document.getElementById('hidden-qty');
            let buyNowQtyInput = document.getElementById('buy-now-qty');
            
            let current = parseInt(input.value);
            let newQty = current + change;

            if (newQty < 1) newQty = 1;
            if (newQty > maxQty) newQty = maxQty;

            input.value = newQty;
            
            // Cập nhật ngay giá trị cho các input ẩn
            if (hiddenInput) hiddenInput.value = newQty;
            if (buyNowQtyInput) buyNowQtyInput.value = newQty;

            // Cập nhật trạng thái nút
            const decBtn = document.querySelector('.decrease');
            const incBtn = document.querySelector('.increase');
            if(decBtn) decBtn.disabled = (newQty <= 1);
            if(incBtn) incBtn.disabled = (newQty >= maxQty);
        }
        
        function updateBuyNowQuantity() {
            // Hàm này để chắc chắn cập nhật lần cuối trước khi submit form mua ngay
            let input = document.getElementById('quantity');
            let buyNowQtyInput = document.getElementById('buy-now-qty');
            if(input && buyNowQtyInput) {
                buyNowQtyInput.value = input.value;
            }
            return true;
        }

        // Logic Xem thêm / Thu gọn đánh giá
        function toggleReviews() {
            const hiddenReviews = document.querySelectorAll('.review-item-hidden');
            const showMoreBtn = document.getElementById('showMoreReviewsBtn');
            const showLessBtn = document.getElementById('showLessReviewsBtn');
            
            if (!hiddenReviews.length) return;
            
            const isHidden = hiddenReviews[0].style.display === 'none';
            
            if (isHidden) {
                hiddenReviews.forEach(item => {
                    item.style.display = 'block';
                    item.style.animation = 'fadeIn 0.5s';
                });
                if (showMoreBtn) showMoreBtn.style.display = 'none';
                if (showLessBtn) showLessBtn.style.display = 'block';
            } else {
                hiddenReviews.forEach(item => item.style.display = 'none');
                if (showMoreBtn) showMoreBtn.style.display = 'block';
                if (showLessBtn) showLessBtn.style.display = 'none';
            }
        }
    </script>
</body>
</html>