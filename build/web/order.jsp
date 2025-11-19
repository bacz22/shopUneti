<%@page import="entities.Message"%>
<%@page import="entities.OrderedProduct"%>
<%@page import="entities.Order"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="dao.OrderedProductDao"%>
<%@page import="dao.OrderDao"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="entities.User"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    User u2 = (User) session.getAttribute("activeUser");
    if (u2 == null) {
        Message message = new Message("You are not logged in! Login first!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("login.jsp");
        return;
    }
    OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
    OrderedProductDao ordProdDao = new OrderedProductDao(ConnectionProvider.getConnection());

    List<Order> orderList = orderDao.getAllOrderByUserId(u2.getUserId());
    List<Object[]> orderEntries = new ArrayList<>();

    if (orderList != null) {
        for (Order order : orderList) {
            List<OrderedProduct> ordProdList = ordProdDao.getAllOrderedProduct(order.getId());
            for (OrderedProduct orderProduct : ordProdList) {
                orderEntries.add(new Object[]{order, orderProduct});
            }
        }
    }

    int orderPageSize = 3;
    int totalEntries = orderEntries.size();
    int totalOrderPages = totalEntries == 0 ? 1 : (int) Math.ceil(totalEntries / (double) orderPageSize);
    int currentOrderPage = 1;
    String orderPageParam = request.getParameter("orderPage");
    if (orderPageParam != null) {
        try {
            currentOrderPage = Integer.parseInt(orderPageParam);
        } catch (NumberFormatException e) {
            currentOrderPage = 1;
        }
    }
    if (currentOrderPage < 1) {
        currentOrderPage = 1;
    }
    if (currentOrderPage > totalOrderPages) {
        currentOrderPage = totalOrderPages;
    }
    int orderStartIndex = (currentOrderPage - 1) * orderPageSize;
    int orderEndIndex = Math.min(orderStartIndex + orderPageSize, totalEntries);
    List<Object[]> pagedEntries = orderEntries.size() > 0 ? orderEntries.subList(orderStartIndex, orderEndIndex) : java.util.Collections.emptyList();
%>
<style>
    /* Custom Pagination Style */
    .pagination-custom .page-item {
        margin: 0 5px; /* Tạo khoảng cách giữa các nút */
    }

    .pagination-custom .page-link {
        border-radius: 12px !important; /* Bo góc nhẹ giống hình */
        border: 1px solid #e2e8f0;
        color: #6200ea; /* Màu tím của chữ/icon */
        font-weight: 600;
        width: 45px;   /* Chiều rộng cố định để nút vuông vắn */
        height: 45px;  /* Chiều cao cố định */
        display: flex;
        align-items: center;
        justify-content: center;
        background-color: #fff;
        transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }

    /* Hover hiệu ứng */
    .pagination-custom .page-link:hover {
        background-color: #f3e5f5; /* Tím nhạt khi di chuột */
        border-color: #6200ea;
        color: #6200ea;
    }

    /* Trạng thái Active (Trang hiện tại) */
    .pagination-custom .page-item.active .page-link {
        background-color: #6200ea; /* Nền tím đậm */
        border-color: #6200ea;
        color: #fff; /* Chữ trắng */
        box-shadow: 0 4px 10px rgba(98, 0, 234, 0.3);
    }

    /* Trạng thái Disabled (Nút Previous/Next khi không bấm được) */
    .pagination-custom .page-item.disabled .page-link {
        background-color: #f1f5f9; /* Nền xám */
        color: #94a3b8; /* Icon xám */
        border-color: #f1f5f9;
        pointer-events: none; /* Không cho click */
    }

    /* Icon mũi tên */
    .pagination-custom i {
        font-size: 0.9rem;
    }
    .table-fixed-layout {
        table-layout: fixed; /* Quan trọng: Cố định chia cột theo % */
        width: 100%;
    }

    /* Sửa lại text-limit: Cho phép xuống dòng */
    .text-wrap-custom {
        white-space: normal;      /* Cho phép xuống dòng */
        word-wrap: break-word;    /* Cắt từ nếu quá dài */
        font-size: 0.9rem;
    }
    
    /* Order ID và Date: Cho phép xuống dòng, chữ nhỏ lại chút */
    .small-text-wrap {
        font-size: 0.85rem;
        white-space: normal;      /* Cho phép xuống dòng */
        word-wrap: break-word;
        overflow-wrap: break-word;
    }
</style>
<div class="container-fluid px-3 py-3">
    <%
        if (totalEntries == 0) {
    %>
    <div class="container mt-5 mb-5 text-center">
        <img src="Images/empty-cart.png" style="max-width: 200px;"
             class="img-fluid">
        <h4 class="mt-3">Zero Order found</h4>
        Looks like you haven't placed any order!
    </div>
    <%
    } else {
    %>
    <h4>My Order</h4>
    <hr>
    <div>
        <table class="table table-hover align-middle table-fixed-layout">
            
            <colgroup>
                <col style="width: 8%;">  <col style="width: 17%;"> <col style="width: 25%;"> <col style="width: 7%;">  <col style="width: 12%;"> <col style="width: 11%;"> <col style="width: 10%;"> <col style="width: 10%;"> </colgroup>

            <thead class="table-secondary text-center">
                <tr>
                    <th>Hình ảnh</th>
                    <th>Mã đơn hàng</th>
                    <th>Tên sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Tổng tiền</th>
                    <th>Ngày đặt</th> 
                    <th>Thanh toán</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
            <%
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
                // 1. Tạo bộ định dạng tiền tệ Việt Nam
                java.text.NumberFormat currencyFormat = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));

                for (Object[] entry : pagedEntries) {
                    Order order = (Order) entry[0];
                    OrderedProduct orderProduct = (OrderedProduct) entry[1];
                    
                    String formattedDate = "";
                    try {
                        formattedDate = dateFormat.format(order.getDate());
                    } catch (Exception e) {
                        String s = order.getDate().toString();
                        formattedDate = (s.length() >= 10) ? s.substring(0, 10) : s;
                    }
                    
                    // Tính tổng tiền
                    double totalPrice = orderProduct.getPrice() * orderProduct.getQuantity();
            %>
            <tr class="text-center">
                <td><img src="Images/<%=orderProduct.getImage()%>"
                         style="width: 100%; max-width: 40px; height: auto; object-fit: contain;"></td>
                
                <td class="text-start small-text-wrap"><%=order.getOrderId()%></td>
                
                <td class="text-start text-wrap-custom">
                    <%=orderProduct.getName()%>
                </td>
                
                <td><%=orderProduct.getQuantity()%></td>
                
                <td style="font-weight: 600; color: #d32f2f;">
                    <%= currencyFormat.format(totalPrice) %> VND
                </td>
                
                <td class="small-text-wrap"><%=formattedDate%></td>
                
                <td class="small-text-wrap"><%=order.getPayementType()%></td>
                <td class="fw-semibold small-text-wrap" style="color: green;"><%=order.getStatus()%></td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
        
        <%
            if (totalOrderPages > 1) {
        %>
        <nav class="d-flex justify-content-center mt-4">
            <ul class="pagination pagination-custom">
                <li class="page-item <%= currentOrderPage == 1 ? "disabled" : ""%>">
                    <a class="page-link" href="profile.jsp?section=order&orderPage=<%=currentOrderPage - 1%>#order">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
                <% for (int i = 1; i <= totalOrderPages; i++) { %>
                <li class="page-item <%= currentOrderPage == i ? "active" : ""%>">
                    <a class="page-link" href="profile.jsp?section=order&orderPage=<%=i%>#order"><%=i%></a>
                </li>
                <% } %>
                <li class="page-item <%= currentOrderPage == totalOrderPages ? "disabled" : ""%>">
                    <a class="page-link" href="profile.jsp?section=order&orderPage=<%=currentOrderPage + 1%>#order">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <% } %>
    </div>
    <%
        }
    %>
</div>
