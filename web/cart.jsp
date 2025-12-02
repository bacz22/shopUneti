<%@page import="entities.Message"%>
<%@page import="entities.Product"%>
<%@page import="dao.ProductDao"%>
<%@page import="entities.Cart"%>
<%@page import="dao.CartDao"%>
<%@page import="java.util.List"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%!
    // Hàm format tiền an toàn - quan trọng nhất!
    public String formatPrice(Object price) {
        if (price == null) {
            return "0 ₫";
        }
        double p = 0;
        try {
            p = Double.parseDouble(price.toString());
        } catch (Exception e) {
            p = 0;
        }
        java.text.NumberFormat formatter = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        return formatter.format(p) + " ₫";
    }
%>

<%
    User activeUser = (User) session.getAttribute("activeUser");
    if (activeUser == null) {
        Message message = new Message("Bạn chưa đăng nhập! Vui lòng đăng nhập!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Giỏ hàng của bạn</title>
        <%@include file="Components/common_css_js.jsp"%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css"/>
        <style>
            :root {
                --primary: #667eea;
                --primary-dark: #764ba2;
                --danger: #f44336;
                --success: #4caf50;
            }
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
                font-family: 'Segoe UI', sans-serif;
                display: flex;
                flex-direction: column;
            }
            .page-body {
                flex: 1;
                display: flex;
                flex-direction: column;
            }
            .cart-container {
                max-width: 1200px;
                margin: 24px auto 32px;
                padding: 0 15px;
                width: 100%;
            }
            .main-card {
                background: #ffffff;
                border-radius: 20px;
                overflow: hidden;
                box-shadow: 0 20px 40px rgba(0,0,0,0.08);
                margin-bottom: 24px;
            }
            .card-header {
                background: linear-gradient(135deg, var(--primary), var(--primary-dark));
                color: #ffffff;
                padding: 18px 26px;
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .card-header small {
                opacity: 0.9;
            }
            .product-item {
                border-bottom: 1px solid #f1f1f5;
                padding: 18px 22px;
                transition: all 0.25s ease;
            }
            .product-item:last-child {
                border-bottom: none;
            }
            .product-item:hover {
                background: #fafbff;
            }
            .cart-items {
                max-height: calc(100vh - 360px);
                overflow-y: auto;
                padding-right: 6px;
                scrollbar-width: thin;
                scrollbar-color: rgba(102, 126, 234, 0.7) transparent;
            }
            .cart-items::-webkit-scrollbar {
                width: 8px;
            }
            .cart-items::-webkit-scrollbar-track {
                background: transparent;
            }
            .cart-items::-webkit-scrollbar-thumb {
                background: linear-gradient(180deg, rgba(102,126,234,0.85), rgba(118,75,162,0.85));
                border-radius: 999px;
            }
            .product-img {
                width: 80px;
                height: 80px;
                object-fit: cover;
                border-radius: 14px;
                border: 3px solid #ffffff;
                box-shadow: 0 8px 24px rgba(0,0,0,0.12);
            }
            .product-name {
                font-weight: 600;
                font-size: 15px;
            }
            .badge-discount {
                background: rgba(76,175,80,0.12);
                color: #2e7d32;
                border-radius: 999px;
                padding: 4px 10px;
                font-size: 12px;
                font-weight: 600;
            }
            .quantity-container {
                display: inline-flex;
                align-items: center;
                gap: 10px;
                background: #f8f9ff;
                padding: 8px 16px;
                border-radius: 999px;
                border: 1px solid #dde1ff;
            }
            .quantity-btn {
                width: 34px;
                height: 34px;
                border-radius: 50%;
                background: #ffffff;
                border: 1px solid #d0d4ff;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                color: var(--primary);
                text-decoration: none;
                transition: all 0.2s ease;
            }
            .quantity-btn:hover:not(.disabled) {
                background: var(--primary);
                color: #ffffff;
                border-color: var(--primary);
                transform: translateY(-1px);
            }
            .quantity-btn.disabled {
                opacity: 0.4;
                cursor: not-allowed;
            }
            .qty-input {
                width: 52px;
                text-align: center;
                font-weight: 700;
                font-size: 16px;
                border: none;
                background: transparent;
                color: var(--primary);
            }
            .remove-btn {
                background: rgba(244, 67, 54, 0.08);
                color: var(--danger);
                width: 38px;
                height: 38px;
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                text-decoration: none;
                transition: all 0.2s;
            }
            .remove-btn:hover {
                background: var(--danger);
                color: #fff;
                transform: translateY(-1px);
            }
            .price {
                font-weight: 700;
                font-size: 17px;
                color: #d32f2f;
            }
            .price-label {
                font-size: 12px;
                color: #9e9e9e;
            }
            .total-section {
                background: #ffffff;
                margin-top: 18px;
                border-radius: 18px;
                padding: 20px 22px;
                box-shadow: 0 12px 32px rgba(0,0,0,0.06);
            }
            .total-section-inner {
                background: linear-gradient(135deg, var(--primary), var(--primary-dark));
                border-radius: 16px;
                padding: 18px 20px;
                color: #ffffff;
            }
            .total-price {
                font-size: 28px;
                font-weight: 800;
            }
            .checkout-btn {
                background: linear-gradient(135deg, var(--success), #43a047);
                padding: 14px 32px;
                border-radius: 999px;
                font-weight: 700;
                font-size: 16px;
                color: white;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                border: none;
                outline: none;
                box-shadow: 0 10px 26px rgba(76,175,80,0.45);
                transition: all 0.2s ease;
            }
            .checkout-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 16px 36px rgba(76,175,80,0.55);
                color: white;
            }
            .continue-link {
                color: #e3e7ff;
                font-size: 14px;
                text-decoration: none;
            }
            .continue-link:hover {
                text-decoration: underline;
                color: #ffffff;
            }
            @media (max-width: 768px) {
                .product-img {
                    width: 64px;
                    height: 64px;
                }
                .product-item {
                    padding: 14px 14px;
                }
                .cart-items {
                    max-height: none;
                }
                .total-price {
                    font-size: 22px;
                }
                .checkout-btn {
                    width: 100%;
                    justify-content: center;
                    margin-top: 8px;
                }
            }
        </style>
    </head>
    <body>
        <%@include file="Components/navbar.jsp"%>

        <main class="page-body">
            <%    double totalPrice = 0;  // đổi thành double cho chắc
                CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
                List<Cart> listOfCart = cartDao.getCartListByUserId(activeUser.getUserId());

                if (listOfCart == null || listOfCart.isEmpty()) {
            %>
            <div class="container text-center py-5">
                <img src="Images/empty-cart.png" class="img-fluid mb-4" style="max-width:280px;">
                <h3 class="text-muted">Giỏ hàng trống</h3>
                <a href="products.jsp" class="btn btn-primary btn-lg rounded-pill px-5 py-3 mt-3">
                    <i class="fas fa-shopping-bag me-2"></i> Mua sắm ngay
                </a>
            </div>
            <%
            } else {
            %>
            <div class="cart-container">
                <%@include file="Components/alert_message.jsp"%>

                <div class="main-card">
                    <div class="card-header">
                        <h4 class="mb-0 fw-bold">
                            <i class="fas fa-shopping-cart me-3"></i>
                            Giỏ hàng của bạn (<%=listOfCart.size()%> sản phẩm)
                        </h4>
                    </div>
                    <div class="cart-items">
                        <%
                            ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
                            for (Cart c : listOfCart) {
                                Product prod = productDao.getProductsByProductId(c.getProductId());
                                double itemTotal = c.getQuantity() * Double.parseDouble(prod.getProductPriceAfterDiscount() + "");
                                totalPrice += itemTotal;
                        %>
                        <div class="product-item">
                            <div class="row align-items-center">
                                <div class="col-md-2 col-3 text-center">
                                    <img src="Images/<%=prod.getProductImages()%>" class="product-img" alt="<%=prod.getProductName()%>">
                                </div>
                                <div class="col-md-4 col-9">
                                    <h6 class="mb-1 fw-bold"><%=prod.getProductName()%></h6>
                                    <% if (prod.getProductDiscount() > 0) {%>
                                    <span class="badge bg-success">Giảm <%=prod.getProductDiscount()%>%</span>
                                    <% }%>
                                </div>
                                <div class="col-md-2 text-md-center">
                                    <div class="price"><%=formatPrice(prod.getProductPriceAfterDiscount())%></div>
                                </div>
                                <div class="col-md-2 text-center">
                                    <div class="quantity-container">
                                        <a href="CartOperationServlet?cid=<%=c.getCartId()%>&opt=2" class="quantity-btn <%=c.getQuantity() <= 1 ? "disabled" : ""%>">-</a>
                                        <input type="text" class="qty-input" value="<%=c.getQuantity()%>" readonly>
                                        <a href="CartOperationServlet?cid=<%=c.getCartId()%>&opt=1" class="quantity-btn <%=c.getQuantity() >= 99 ? "disabled" : ""%>">+</a>
                                    </div>
                                </div>
                                <div class="col-md-2 text-md-end">
                                    <div class="price fs-5 fw-bold"><%=formatPrice(itemTotal)%></div>
                                </div>
                                <div class="col-md-1 text-end">
                                    <a href="CartOperationServlet?cid=<%=c.getCartId()%>&opt=3" class="remove-btn" onclick="confirmDelete(event, this)">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                        <% }%>
                    </div>
                </div>

                <div class="total-section">
                    <div class="row align-items-center justify-content-between">
                        <div class="col-lg-6 text-center text-lg-start">
                            <a href="products.jsp" class="text-white" style="opacity:0.9;">
                                <i class="fas fa-arrow-left me-2"></i> Tiếp tục mua sắm
                            </a>
                        </div>
                        <div class="col-lg-6 text-center text-lg-end">
                            <h4 class="mb-3">Tổng thanh toán</h4>
                            <div class="total-price"><%=formatPrice(totalPrice)%></div>
                            <a href="checkout.jsp" class="checkout-btn mt-3" id="checkoutBtn">
                                <i class="fas fa-credit-card me-2"></i> Thanh toán ngay
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <%
                session.setAttribute("totalPrice", totalPrice);
                session.setAttribute("cartList", listOfCart);
                session.setAttribute("from", "cart");
            %>
            <%
                }
            %>

        </main>
        <%@include file="Components/footer.jsp"%>
        <script>
            function confirmDelete(event, element) {
                // 1. Chặn việc chuyển trang ngay lập tức
                event.preventDefault();

                // 2. Lấy đường dẫn xóa từ thẻ <a>
                const deleteUrl = element.getAttribute('href');

                // 3. Hiện Popup hỏi
                Swal.fire({
                    title: 'Bạn chắc chắn chứ?',
                    text: "Sản phẩm sẽ bị xóa khỏi giỏ hàng!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33', // Màu đỏ cho nút Xóa
                    cancelButtonColor: '#3085d6', // Màu xanh cho nút Hủy
                    confirmButtonText: 'Xóa!',
                    cancelButtonText: 'Hủy bỏ'
                }).then((result) => {
                    // 4. Nếu người dùng bấm nút "Vâng, xóa đi!"
                    if (result.isConfirmed) {
                        window.location.href = deleteUrl; // Chuyển trang để xóa
                    }
                });
            }
        </script>
    </body>
</html>