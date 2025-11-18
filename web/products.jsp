<%@page import="dao.WishlistDao"%>
<%@page import="entities.User"%>
<%@page import="dao.CategoryDao"%>
<%@page import="entities.Product"%>
<%@page import="java.util.List"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.ProductDao"%>
<%
User u = (User) session.getAttribute("activeUser");
WishlistDao wishlistDao = new WishlistDao(ConnectionProvider.getConnection());

String searchKey = request.getParameter("search");
String catId = request.getParameter("category");
CategoryDao categoryDao = new CategoryDao(ConnectionProvider.getConnection());
String message = "";

ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
List<Product> prodList = null;
if (searchKey != null) {
	if (!searchKey.isEmpty()) {
		message = "Showing results for \"" + searchKey + "\"";
	} else {
		message = "No product found!";
	}
	prodList = productDao.getAllProductsBySearchKey(searchKey);

} else if (catId != null && !(catId.trim().equals("0"))) {
	prodList = productDao.getAllProductsByCategoryId(Integer.parseInt(catId.trim()));
	message = "Showing results for \"" + categoryDao.getCategoryName(Integer.parseInt(catId.trim())) + "\"";
} else {
	prodList = productDao.getAllProducts();
	message = "All Products";
}

if (prodList != null && prodList.size() == 0) {
	String noResultLabel = "All Products";
	if (searchKey != null && !searchKey.isEmpty()) {
		noResultLabel = searchKey;
	} else if (catId != null && !(catId.trim().equals("0"))) {
		noResultLabel = categoryDao.getCategoryName(Integer.parseInt(catId.trim()));
	}
	message = "No items are available for \"" + noResultLabel + "\"";
	prodList = productDao.getAllProducts();
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Products</title>
<%@include file="Components/common_css_js.jsp"%>
<style>
.real-price {
	font-size: 22px !important;
	font-weight: 600;
}

.product-price {
	font-size: 17px !important;
	text-decoration: line-through;
}

.product-discount {
	font-size: 15px !important;
	color: #027a3e;
}

.wishlist-icon {
	cursor: pointer;
	position: absolute;
	right: 10px;
	top: 10px;
	width: 36px;
	height: 36px;
	border-radius: 50%;
	border: 1px solid #f0f0f0;
	box-shadow: 0 1px 4px 0 rgba(0, 0, 0, .1);
	padding-right: 40px;
	background: #fff;
}

.product-card {
	border: none;
	border-radius: 18px;
	box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
	transition: all 0.3s ease;
	background: #ffffff;
}

.product-card:hover {
	transform: translateY(-8px);
	box-shadow: 0 22px 40px rgba(0, 0, 0, 0.12);
}

.product-image-wrapper {
	position: relative;
	background: #f8fbff;
	border-radius: 14px;
	padding: 16px;
	min-height: 230px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.product-card img {
	transition: transform 0.3s ease;
}

.product-card:hover img {
	transform: scale(1.03);
}

.btn-view {
	border-radius: 30px;
	padding: 8px 20px;
}

.btn-cart {
	border-radius: 30px;
	padding: 8px 22px;
	background: linear-gradient(135deg, #00b5ff, #0066ff);
	border: none;
}

.btn-cart:hover {
	background: linear-gradient(135deg, #009eea, #0053d9);
}
</style>
</head>
<body style="background-color: #f0f0f0;">
	<!--navbar -->
	<%@include file="Components/navbar.jsp"%>

	<!--show products-->
	<h4 class="text-center mt-2"><%=message%></h4>
	<div class="container-fluid my-3 px-5">

		<div class="row row-cols-1 row-cols-md-4 g-3">
			<%
			for (Product p : prodList) {
			%>
			<div class="col">

				<div class="card h-100 px-3 py-3 product-card">
					<div class="product-image-wrapper text-center position-relative">
						<img src="Images/<%=p.getProductImages()%>"
							class="card-img-top"
							style="max-width: 100%; max-height: 220px; width: auto;">
						<div class="wishlist-icon">
							<%
							if (u != null) {
								if (wishlistDao.getWishlist(u.getUserId(), p.getProductId())) {
							%>
							<button
								onclick="window.open('WishlistServlet?uid=<%=u.getUserId()%>&pid=<%=p.getProductId()%>&op=remove', '_self')"
								class="btn btn-link" type="submit">
								<i class="fa-sharp fa-solid fa-heart" style="color: #ff0303;"></i>
							</button>
							<%
							} else {
							%>
							<button type="submit"
								onclick="window.open('WishlistServlet?uid=<%=u.getUserId()%>&pid=<%=p.getProductId()%>&op=add', '_self')"
								class="btn btn-link">
								<i class="fa-sharp fa-solid fa-heart" style="color: #909191;"></i>
							</button>
							<%
							}
							} else {
							%>
							<button onclick="window.open('login.jsp', '_self')"
								class="btn btn-link" type="submit">
								<i class="fa-sharp fa-solid fa-heart" style="color: #909191;"></i>
							</button>
							<%
							}
							%>

						</div>
					</div>
					<h5 class="card-title text-center mt-3"><%=p.getProductName()%></h5>

					<div class="container text-center">
						<span class="real-price">&#8377;<%=p.getProductPriceAfterDiscount()%></span>&ensp;
						<span class="product-price">&#8377;<%=p.getProductPrice()%></span>&ensp;
						<span class="product-discount"><%=p.getProductDiscount()%>&#37;off</span>
					</div>
					<div class="d-flex justify-content-center gap-2 flex-wrap mt-3">
						<button type="button"
							onclick="window.open('viewProduct.jsp?pid=<%=p.getProductId()%>', '_self')"
							class="btn btn-outline-primary btn-view">View Details</button>
						<%
						if (u != null) {
						%>
						<form action="AddToCartServlet" method="post" class="d-inline">
							<input type="hidden" name="uid" value="<%=u.getUserId()%>">
							<input type="hidden" name="pid" value="<%=p.getProductId()%>">
							<button type="submit" class="btn btn-cart text-white">Add to Cart</button>
						</form>
						<%
						} else {
						%>
						<button type="button" onclick="window.open('login.jsp', '_self')"
							class="btn btn-cart text-white">Add to Cart</button>
						<%
						}
						%>
					</div>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</div>
</body>
</html>

