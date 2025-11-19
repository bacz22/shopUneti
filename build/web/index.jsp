<%@page import="dao.ProductDao"%>
<%@page import="entities.Product"%>
<%@page import="helper.ConnectionProvider"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
    List<Product> productList = productDao.getAllLatestProducts();
    List<Product> topDeals = productDao.getDiscountedProducts();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechMarket - Trang Chủ</title>
    <%@include file="Components/common_css_js.jsp"%>

    <!-- Font Awesome mới nhất -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        :root {
            --primary: #5b21b6;
            --primary-light: #7c3aed;
            --secondary: #ec4899;
            --accent: #f59e0b;
            --light: #f8fafc;
            --dark: #1e293b;
            --gray: #64748b;
        }

        body {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0e7ff 100%);
            font-family: 'Segoe UI', Tahoma, sans-serif;
            margin: 0;
            padding: 0;
        }

        /* Hero Carousel - Full màn hình */
        .hero-carousel {
            margin-top: -1px;
        }

        .hero-carousel img {
            height: 85vh;
            object-fit: cover;
            filter: brightness(65%);
        }

        .carousel-caption {
            bottom: 25%;
            left: 10% !important;
            right: auto;
            text-align: left;
            text-shadow: 0 3px 10px rgba(0,0,0,0.8);
        }

        .carousel-caption h1 {
            font-size: 4.5rem;
            font-weight: 900;
            color: #fff;
        }

        .carousel-caption p {
            font-size: 1.6rem;
            font-weight: 600;
        }

        /* Section Title */
        .section-title {
            font-size: 2.8rem;
            font-weight: 800;
            color: var(--dark);
            text-align: center;
            margin: 70px 0 50px;
            position: relative;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -15px;
            left: 50%;
            transform: translateX(-50%);
            width: 120px;
            height: 6px;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
            border-radius: 10px;
        }

        /* Product Card Siêu Đẹp */
        .product-card {
            border: none;
            border-radius: 20px;
            overflow: hidden;
            background: white;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            transition: all 0.4s ease;
            height: 100%;
        }

        .product-card:hover {
            transform: translateY(-12px);
            box-shadow: 0 25px 50px rgba(91, 33, 182, 0.25);
        }

        .product-card .img-wrapper {
            position: relative;
            overflow: hidden;
            background: #f8f9ff;
        }

        .product-card img {
            transition: transform 0.5s ease;
            height: 260px;
            object-fit: contain;
            padding: 20px;
        }

        .product-card:hover img {
            transform: scale(1.1);
        }

        /* Badge Mới & Hot */
        .badge-new, .badge-hot {
            position: absolute;
            top: 15px;
            left: 15px;
            padding: 8px 16px;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 700;
            z-index: 5;
        }

        .badge-new {
            background: #10b981;
            color: white;
            box-shadow: 0 4px 15px rgba(16,185,129,0.4);
        }

        .badge-hot {
            background: #ef4444;
            color: white;
            animation: pulse 2s infinite;
            box-shadow: 0 4px 20px rgba(239,68,68,0.5);
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.08); }
        }

        .product-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark);
            height: 50px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            margin-bottom: 15px;
        }

        .price-current {
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--primary);
        }

        .price-old {
            color: #94a3b8;
            text-decoration: line-through;
            font-size: 1rem;
        }

        .discount-tag {
            background: linear-gradient(135deg, #ff6b6b, #f43f5e);
            color: white;
            padding: 6px 14px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 0.9rem;
        }

        /* Header nổi bật */
        .hero-header {
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            color: white;
            padding: 60px 30px;
            border-radius: 25px;
            text-align: center;
            margin: 50px 0;
            box-shadow: 0 20px 40px rgba(91,33,182,0.3);
        }

        .hero-header h1 {
            font-size: 3.5rem;
            font-weight: 900;
            margin: 0;
        }

        @media (max-width: 768px) {
            .carousel-caption h1 { font-size: 2.5rem; }
            .carousel-caption p { font-size: 1.2rem; }
            .section-title { font-size: 2.2rem; }
            .hero-header h1 { font-size: 2.5rem; }
        }
    </style>
</head>
<body>

    <%@include file="Components/navbar.jsp"%>

    <!-- Hero Carousel -->
    <div id="heroCarousel" class="carousel slide hero-carousel" data-bs-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <img src="Images/scroll_img2.jpg" class="d-block w-100" alt="Sale lớn">
                <div class="carousel-caption">
                    <h1>SALE KHỦNG CUỐI NĂM</h1>
                    <p>Giảm tới 70% toàn bộ sản phẩm công nghệ</p>
                </div>
            </div>
            <div class="carousel-item">
                <img src="Images/scroll_img1.jpg" class="d-block w-100" alt="Sản phẩm mới">
                <div class="carousel-caption">
                    <h1>SẢN PHẨM MỚI 2025</h1>
                    <p>Công nghệ đỉnh cao - Thiết kế đột phá</p>
                </div>
            </div>
            <div class="carousel-item">
                <img src="Images/scroll_img0.png" class="d-block w-100" alt="Deal hot">
                <div class="carousel-caption">
                    <h1>DEAL GIỜ VÀNG</h1>
                    <p>Flash Sale chỉ từ 99k - Số lượng có hạn!</p>
                </div>
            </div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon"></span>
        </button>
        <button class="carousel-control-next" type="button" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
            <span class="carousel-control-next-icon"></span>
        </button>
    </div>

    <!-- Sản phẩm mới nhất -->
    <div class="container my-5">
        <div class="hero-header">
            <h1>SẢN PHẨM MỚI NHẤT</h1>
        </div>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-4 g-4">
            <%
                for (int i = 0; i < Math.min(8, productList.size()); i++) {
                    Product p = productList.get(i);
                    java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
            %>
            <div class="col">
                <a href="viewProduct.jsp?pid=<%=p.getProductId()%>" class="text-decoration-none">
                    <div class="card product-card h-100">
                        <div class="img-wrapper">
                            <% if(i < 4) { %>
                                <span class="badge-new">MỚI</span>
                            <% } %>
                            <img src="Images/<%=p.getProductImages()%>" class="card-img-top" alt="<%=p.getProductName()%>">
                        </div>
                        <div class="card-body d-flex flex-column">
                            <h5 class="product-title"><%=p.getProductName()%></h5>
                            <div class="mt-auto">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="price-current"><%=fmt.format(p.getProductPriceAfterDiscount())%> ₫</span>
                                    <% if(p.getProductDiscount() > 0) { %>
                                        <span class="discount-tag">-<%=p.getProductDiscount()%>%</span>
                                    <% } %>
                                </div>
                                <% if(p.getProductDiscount() > 0) { %>
                                    <div class="price-old"><%=fmt.format(p.getProductPrice())%> ₫</div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </a>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Khuyến mãi Hot -->
    <div class="container-fluid bg-white py-5">
        <h2 class="section-title text-danger">
            KHUYẾN MÃI HOT NHẤT
        </h2>

        <div class="container">
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-5 g-4">
                <%
                    for (Product p : topDeals) {
                        java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                %>
                <div class="col">
                    <a href="viewProduct.jsp?pid=<%=p.getProductId()%>" class="text-decoration-none">
                        <div class="card product-card h-100 border-0">
                            <div class="img-wrapper">
                                <span class="badge-hot">HOT</span>
                                <img src="Images/<%=p.getProductImages()%>" class="card-img-top" alt="<%=p.getProductName()%>">
                            </div>
                            <div class="card-body d-flex flex-column">
                                <h6 class="product-title"><%=p.getProductName()%></h6>
                                <div class="mt-auto">
                                    <div class="price-current text-danger fw-bold fs-5"><%=fmt.format(p.getProductPriceAfterDiscount())%> ₫</div>
                                    <del class="text-muted small"><%=fmt.format(p.getProductPrice())%> ₫</del>
                                    <div class="discount-tag mt-2">-<%=p.getProductDiscount()%>%</div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Thông báo đặt hàng thành công -->
    <%
        String order = (String) session.getAttribute("order");
        if (order != null) {
    %>
    <script>
        Swal.fire({
            icon: 'success',
            title: 'Đặt hàng thành công!',
            html: 'Cảm ơn quý khách đã tin tưởng TechMarket!<br>Mã đơn hàng đã gửi đến email: <strong><%= ((entities.User)session.getAttribute("activeUser")).getUserEmail() %></strong>',
            timer: 5000,
            timerProgressBar: true,
            showConfirmButton: true,
            confirmButtonText: 'Xem đơn hàng',
            confirmButtonColor: '#5b21b6'
        });
    </script>
    <%
        session.removeAttribute("order");
        }
    %>

    <%@include file="Components/footer.jsp"%>

</body>
</html>