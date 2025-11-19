<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="entities.Message"%>
<%@page import="entities.Product"%>
<%@page import="dao.ProductDao"%>
<%@page import="entities.Wishlist"%>
<%@page import="java.util.List"%>
<%@page errorPage="error_exception.jsp"%>
<%@page import="entities.User"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="dao.WishlistDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    User u1 = (User) session.getAttribute("activeUser");
    if (u1 == null) {
        Message message = new Message("You are not logged in! Login first!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("login.jsp");
        return;
    }
    WishlistDao wishListDao = new WishlistDao(ConnectionProvider.getConnection());
    List<Wishlist> wlist = wishListDao.getListByUserId(u1.getUserId());
    ProductDao pDao = new ProductDao(ConnectionProvider.getConnection());

    // Cấu hình phân trang
    int wishPageSize = 3;
    int totalWishItems = (wlist != null) ? wlist.size() : 0;
    int totalWishPages = totalWishItems == 0 ? 1 : (int) Math.ceil(totalWishItems / (double) wishPageSize);
    int currentWishPage = 1;
    String wishPageParam = request.getParameter("wishPage");
    if (wishPageParam != null) {
        try {
            currentWishPage = Integer.parseInt(wishPageParam);
        } catch (NumberFormatException e) {
            currentWishPage = 1;
        }
    }
    if (currentWishPage < 1) currentWishPage = 1;
    if (currentWishPage > totalWishPages) currentWishPage = totalWishPages;
    int wishStartIndex = (currentWishPage - 1) * wishPageSize;
    int wishEndIndex = Math.min(wishStartIndex + wishPageSize, totalWishItems);
    List<Wishlist> pagedWishlist = (wlist != null && totalWishItems > 0) ? wlist.subList(wishStartIndex, wishEndIndex) : java.util.Collections.emptyList();
%>
<style>
    /* Custom Pagination Style */
    .pagination-custom .page-item { margin: 0 5px; }
    .pagination-custom .page-link {
        border-radius: 12px !important;
        border: 1px solid #e2e8f0;
        color: #6200ea;
        font-weight: 600;
        width: 45px; height: 45px;
        display: flex; align-items: center; justify-content: center;
        background-color: #fff;
        transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    .pagination-custom .page-link:hover { background-color: #f3e5f5; border-color: #6200ea; color: #6200ea; }
    .pagination-custom .page-item.active .page-link {
        background-color: #6200ea; border-color: #6200ea; color: #fff;
        box-shadow: 0 4px 10px rgba(98, 0, 234, 0.3);
    }
    .pagination-custom .page-item.disabled .page-link {
        background-color: #f1f5f9; color: #94a3b8; border-color: #f1f5f9; pointer-events: none;
    }
    .pagination-custom i { font-size: 0.9rem; }
    
    /* Giới hạn độ dài tên sản phẩm */
    .wishlist-text-limit {
        max-width: 300px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        display: block;
    }
</style>

<div class="container px-3 py-3">
    <%
    if (totalWishItems == 0) {
    %>
    <div class="container mt-5 mb-5 text-center">
        <img src="Images/wishlist.png" style="max-width: 200px;" class="img-fluid">
        <h4 class="mt-3">Danh sách trống</h4>
        Bạn không có sản phẩm nào trong danh sách yêu thích. Hãy bắt đầu thêm!
    </div>
    <%
    } else {
    %>
    <h4>Danh sách yêu thích (<%=wlist.size()%>)</h4>
    <hr>
    <div class="container">
        <div class="table-responsive"> <table class="table table-hover align-middle">
                <thead class="table-secondary text-center">
                    <tr>
                        <th style="width: 15%">Hình ảnh</th>
                        <th style="width: 45%">Tên sản phẩm</th>
                        <th style="width: 25%">Giá</th>
                        <th style="width: 15%">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    // Tạo bộ định dạng tiền tệ VN
                    NumberFormat currencyFormat = NumberFormat.getInstance(new Locale("vi", "VN"));

                    for (Wishlist w : pagedWishlist) {
                        Product p = pDao.getProductsByProductId(w.getProductId());
                    %>
                    <tr class="text-center">
                        <td>
                            <img src="Images/<%=p.getProductImages()%>" 
                                 style="width: 50px; height: 50px; object-fit: contain;">
                        </td>
                        
                        <td class="text-start">
                            <span class="wishlist-text-limit" title="<%=p.getProductName()%>">
                                <%=p.getProductName()%>
                            </span>
                        </td>
                        
                        <td class="fw-bold text-danger">
                            <%= currencyFormat.format(p.getProductPriceAfterDiscount()) %> VND
                        </td>
                        
                        <td>
                            <a href="WishlistServlet?uid=<%=u1.getUserId()%>&pid=<%=p.getProductId()%>&op=delete"
                               class="btn btn-outline-danger btn-sm" role="button">
                                <i class="fas fa-trash-alt"></i> Xóa
                            </a>
                        </td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>
        
        <%
        if (totalWishPages > 1) {
        %>
        <nav class="d-flex justify-content-center mt-4">
            <ul class="pagination pagination-custom"> 
                <li class="page-item <%= currentWishPage == 1 ? "disabled" : "" %>">
                    <a class="page-link" href="profile.jsp?section=wishlist&wishPage=<%=currentWishPage - 1%>#wishlist">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>

                <%
                for (int i = 1; i <= totalWishPages; i++) {
                %>
                <li class="page-item <%= currentWishPage == i ? "active" : "" %>">
                    <a class="page-link" href="profile.jsp?section=wishlist&wishPage=<%=i%>#wishlist"><%=i%></a>
                </li>
                <%
                }
                %>

                <li class="page-item <%= currentWishPage == totalWishPages ? "disabled" : "" %>">
                    <a class="page-link" href="profile.jsp?section=wishlist&wishPage=<%=currentWishPage + 1%>#wishlist">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <%
        }
        %>
    </div>
    <%
    }
    %>
</div>