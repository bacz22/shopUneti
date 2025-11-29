<%@page import="java.text.SimpleDateFormat"%>
<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@page import="dao.UserDao"%>
<%@page errorPage="error_exception.jsp"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="entities.OrderedProduct"%>
<%@page import="entities.Order"%>
<%@page import="java.util.List"%>
<%@page import="dao.OrderedProductDao"%>
<%@page import="dao.OrderDao"%>
<%@page import="helper.ConnectionProvider"%>

<%
    // 1. Khởi tạo DAO & Lấy dữ liệu
    OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
    OrderedProductDao ordProdDao = new OrderedProductDao(ConnectionProvider.getConnection());
    UserDao userDao = new UserDao(ConnectionProvider.getConnection());
    
    // Lấy TOÀN BỘ danh sách đơn hàng để tính toán
    List<Order> fullList = orderDao.getAllOrder();

    // 2. Xử lý Phân trang (8 item/trang)
    int itemsPerPage = 8;
    int totalItems = (fullList != null) ? fullList.size() : 0;
    int totalPages = (int) Math.ceil((double) totalItems / itemsPerPage);
    
    // Lấy trang hiện tại
    int currentPage = 1;
    String pageParam = request.getParameter("p");
    if (pageParam != null) {
        try { currentPage = Integer.parseInt(pageParam); } catch (Exception e) { currentPage = 1; }
    }
    
    // Kiểm tra giới hạn trang (tránh lỗi khi nhập số trang bậy bạ)
    if (currentPage < 1) currentPage = 1;
    if (totalPages > 0 && currentPage > totalPages) currentPage = totalPages;

    // Cắt danh sách con (SubList) cho trang hiện tại
    List<Order> pagedList = null;
    if (totalItems > 0) {
        int startIdx = (currentPage - 1) * itemsPerPage;
        int endIdx = Math.min(startIdx + itemsPerPage, totalItems);
        
        // Đảm bảo index không vượt quá giới hạn
        if (startIdx < totalItems) {
            pagedList = fullList.subList(startIdx, endIdx);
        }
    }
    
    // Format
    java.text.NumberFormat currencyFormat = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<style>
    /* Custom Pagination */
    .pagination-custom .page-item { margin: 0 5px; }
    .pagination-custom .page-link {
        border-radius: 12px !important; border: 1px solid #e2e8f0;
        color: #6200ea; font-weight: 600; width: 40px; height: 40px;
        display: flex; align-items: center; justify-content: center;
        background-color: #fff; transition: all 0.3s ease;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
    }
    .pagination-custom .page-link:hover { background-color: #f3e5f5; color: #6200ea; }
    .pagination-custom .page-item.active .page-link { background-color: #6200ea; color: #fff; border-color: #6200ea; }
    .pagination-custom .page-item.disabled .page-link { background-color: #f1f5f9; color: #94a3b8; }

    /* Style Dropdown Trạng thái */
    .status-select {
        padding: 5px 10px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        border: 1px solid #e0e0e0;
        cursor: pointer;
        appearance: none; 
        background-color: #fff;
        text-align: center;
        transition: all 0.3s;
        width: 100%; /* Để dropdown full ô */
        min-width: 140px;
    }
    
    /* MÀU SẮC TRẠNG THÁI */
    .st-delivered { background-color: #dcfce7; color: #166534; border-color: #bbf7d0; } /* Xanh lá */
    .st-shipped { background-color: #dbeafe; color: #1e40af; border-color: #bfdbfe; }   /* Xanh dương */
    .st-confirmed { background-color: #f3e8ff; color: #6b21a8; border-color: #e9d5ff; } /* Tím */
    .st-processing { background-color: #fff7ed; color: #9a3412; border-color: #ffedd5; }/* Cam */
    .st-cancelled { background-color: #fee2e2; color: #991b1b; border-color: #fca5a5; }  /* Đỏ (Mới) */
</style>

<div class="container-fluid px-4">
    
   <div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-secondary"><i class="fas fa-file-invoice-dollar me-2"></i>Quản lý Đơn hàng</h3>
    
    <a href="ExportOrderServlet" class="btn btn-success rounded-pill px-4 shadow-sm">
        <i class="fas fa-file-excel me-2"></i> Xuất Excel
    </a>
</div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
            <div><i class="fas fa-list me-2 text-primary"></i> Danh sách đơn hàng</div>
            <span class="badge bg-light text-dark border"><%=totalItems%> đơn</span>
        </div>
        
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light text-secondary text-center small text-uppercase">
                        <tr>
                            <th>Mã Đơn</th>
                            <th>Sản phẩm</th>
                            <th style="width: 20%">Khách hàng</th>
                            <th>Tổng tiền</th>
                            <th>Ngày đặt</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th> 
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (pagedList != null && !pagedList.isEmpty()) {
                            for (Order order : pagedList) {
                                List<OrderedProduct> ordProdList = ordProdDao.getAllOrderedProduct(order.getId());
                                for (OrderedProduct orderProduct : ordProdList) {
                                    
                                    // === XỬ LÝ MÀU SẮC BAN ĐẦU ===
                                    String stClass = "bg-light";
                                    String st = order.getStatus();
                                    
                                    if(st.equalsIgnoreCase("Delivered")) stClass = "st-delivered";
                                    else if(st.equalsIgnoreCase("Shipped")) stClass = "st-shipped";
                                    else if(st.equalsIgnoreCase("Order Confirmed")) stClass = "st-confirmed";
                                    else if(st.equalsIgnoreCase("Out For Delivery")) stClass = "st-processing";
                                    else if(st.equalsIgnoreCase("Cancelled")) stClass = "st-cancelled";
                        %>
                        <tr ondblclick="viewOrderDetails(<%=order.getId()%>)" style="cursor: pointer;" title="Nhấn đúp để xem chi tiết">
                            <td class="text-center fw-bold text-primary"><%=order.getOrderId()%></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="Images/<%=orderProduct.getImage()%>" style="width: 40px; height: 40px; object-fit: contain; border: 1px solid #eee; border-radius: 6px;" class="me-2">
                                    <div>
                                        <div class="fw-semibold text-truncate" style="max-width: 150px;" title="<%=orderProduct.getName()%>">
                                            <%=orderProduct.getName()%>
                                        </div>
                                        <small class="text-muted">x<%=orderProduct.getQuantity()%></small>
                                    </div>
                                </div>
                            </td>
                            <td class="small">
                                <div class="fw-bold"><%=userDao.getUserName(order.getUserId())%></div>
                                <div class="text-muted text-truncate" style="max-width: 180px;" title="<%=userDao.getUserAddress(order.getUserId())%>">
                                    <%=userDao.getUserAddress(order.getUserId())%>
                                </div>
                            </td>
                            <td class="text-center fw-bold text-danger">
                                <%=currencyFormat.format(orderProduct.getPrice() * orderProduct.getQuantity())%> ₫
                            </td>
                            <td class="text-center small">
                                <% try { out.print(dateFormat.format(order.getDate())); } catch(Exception e){ out.print(order.getDate()); } %>
                            </td>
                            <td class="text-center">
                                <span class="badge bg-light text-dark border"><%=order.getPayementType()%></span>
                            </td>
                            
                            <td class="text-center">
                                <form action="UpdateOrderServlet" method="post" style="margin:0;">
                                    <input type="hidden" name="oid" value="<%=order.getId()%>">
                                    <input type="hidden" name="currentPage" value="<%=currentPage%>"> 

                                    <select name="status" class="status-select <%=stClass%>" onchange="this.form.submit()">
                                        <option value="Order Confirmed" <%=st.equalsIgnoreCase("Order Confirmed")?"selected":""%>>Đã xác nhận</option>
                                        <option value="Shipped" <%=st.equalsIgnoreCase("Shipped")?"selected":""%>>Đã gửi hàng</option>
                                        <option value="Out For Delivery" <%=st.equalsIgnoreCase("Out For Delivery")?"selected":""%>>Đang giao</option>
                                        <option value="Delivered" <%=st.equalsIgnoreCase("Delivered")?"selected":""%>>Giao thành công</option>
                                        <option value="Cancelled" <%=st.equalsIgnoreCase("Cancelled")?"selected":""%> style="color:red; font-weight:bold;">Đã hủy</option>
                                    </select>
                                </form>
                            </td>
                        </tr>
                        <% 
                                }
                            }
                        } else { 
                        %>
                            <tr><td colspan="7" class="text-center py-4 text-muted">Chưa có đơn hàng nào.</td></tr>
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
                        <a class="page-link" href="admin.jsp?page=orders&p=<%=currentPage - 1%>"><i class="fas fa-chevron-left fa-xs"></i></a>
                    </li>
                    <% for (int i = 1; i <= totalPages; i++) { %>
                    <li class="page-item <%= currentPage == i ? "active" : "" %>">
                        <a class="page-link" href="admin.jsp?page=orders&p=<%=i%>"><%=i%></a>
                    </li>
                    <% } %>
                    <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="admin.jsp?page=orders&p=<%=currentPage + 1%>"><i class="fas fa-chevron-right fa-xs"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
        <% } %>
    </div>
</div>

<div class="modal fade" id="orderDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title fw-bold">
                    <i class="fas fa-receipt me-2"></i>Chi tiết đơn hàng #<span id="modalOrderId"></span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-0">
                <div class="table-responsive">
                    <table class="table table-striped table-hover mb-0 align-middle">
                        <thead class="bg-light text-secondary">
                            <tr>
                                <th class="text-center">STT</th>
                                <th>Sản phẩm</th>
                                <th class="text-center">SL</th>
                                <th class="text-end">Đơn giá</th>
                                <th class="text-end">Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody id="orderDetailContent">
                            </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer bg-light">
                <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script>
    // Hàm xử lý khi click đúp
    function viewOrderDetails(orderId) {
        // 1. Cập nhật ID lên tiêu đề Modal
        document.getElementById('modalOrderId').innerText = orderId;
        
        // 2. Hiển thị loading trong lúc chờ
        const contentBody = document.getElementById('orderDetailContent');
        contentBody.innerHTML = `
            <tr>
                <td colspan="5" class="text-center p-4">
                    <div class="spinner-border text-primary" role="status"></div>
                    <div class="mt-2 text-muted small">Đang tải dữ liệu...</div>
                </td>
            </tr>`;

        // 3. Mở Modal
        var myModal = new bootstrap.Modal(document.getElementById('orderDetailModal'));
        myModal.show();

        // 4. Gọi AJAX lấy dữ liệu từ file load_order_details.jsp
        fetch('load_order_details.jsp?orderId=' + orderId)
            .then(response => {
                if (!response.ok) throw new Error('Lỗi mạng');
                return response.text();
            })
            .then(htmlData => {
                // 5. Đổ dữ liệu vào bảng
                contentBody.innerHTML = htmlData;
            })
            .catch(error => {
                console.error('Error:', error);
                contentBody.innerHTML = `
                    <tr>
                        <td colspan="5" class="text-center text-danger p-3">
                            <i class="fas fa-exclamation-triangle me-1"></i> Không thể tải chi tiết đơn hàng!
                        </td>
                    </tr>`;
            });
    }

    // (Giữ nguyên phần script xử lý màu sắc status của bạn ở đây)
    document.querySelectorAll('.status-select').forEach(select => {
        select.addEventListener('change', function() {
            this.classList.remove('st-delivered', 'st-shipped', 'st-confirmed', 'st-processing', 'st-cancelled');
            const val = this.value;
            if(val === 'Delivered') this.classList.add('st-delivered');
            else if(val === 'Shipped') this.classList.add('st-shipped');
            else if(val === 'Order Confirmed') this.classList.add('st-confirmed');
            else if(val === 'Out For Delivery') this.classList.add('st-processing');
            else if(val === 'Cancelled') this.classList.add('st-cancelled');
        });
    });
</script>