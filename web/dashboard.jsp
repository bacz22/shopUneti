<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="entities.*"%>
<%@page import="dao.*"%>
<%@page import="helper.ConnectionProvider"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<%
    // 1. KHỞI TẠO & LẤY DỮ LIỆU
    OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
    OrderedProductDao ordProdDao = new OrderedProductDao(ConnectionProvider.getConnection());
    List<Order> allOrders = orderDao.getAllOrder();

    // 2. XỬ LÝ BỘ LỌC NGÀY (FILTER)
    String startDateStr = request.getParameter("startDate");
    String endDateStr = request.getParameter("endDate");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    Date startDate = null;
    Date endDate = null;
    
    // Mặc định: Lấy 30 ngày gần nhất nếu không chọn
    if(startDateStr == null || startDateStr.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -30);
        startDate = cal.getTime();
        startDateStr = sdf.format(startDate);
    } else {
        startDate = sdf.parse(startDateStr);
    }
    
    if(endDateStr == null || endDateStr.isEmpty()) {
        endDate = new Date(); // Hôm nay
        endDateStr = sdf.format(endDate);
    } else {
        endDate = sdf.parse(endDateStr);
    }

    // 3. TÍNH TOÁN THỐNG KÊ
    double totalRevenue = 0;
    int totalOrders = 0;
    int deliveredOrders = 0;
    int cancelledOrders = 0;
    
    // Map để lưu dữ liệu cho Biểu đồ (Ngày -> Doanh thu)
    Map<String, Double> chartData = new TreeMap<>(); // TreeMap để tự sắp xếp theo ngày

    for (Order order : allOrders) {
        // Chuyển ngày đặt hàng về dạng yyyy-MM-dd để so sánh
        String orderDateStr = sdf.format(order.getDate());
        Date orderDate = sdf.parse(orderDateStr);

        // Kiểm tra xem đơn hàng có nằm trong khoảng ngày lọc không
        if (orderDate.compareTo(startDate) >= 0 && orderDate.compareTo(endDate) <= 0) {
            totalOrders++;
            
            // Tính tổng tiền của đơn hàng này
            double orderTotal = 0;
            List<OrderedProduct> products = ordProdDao.getAllOrderedProduct(order.getId());
            for(OrderedProduct p : products) {
                orderTotal += p.getPrice() * p.getQuantity();
            }

            // Chỉ cộng doanh thu nếu đơn hàng thành công (Delivered)
            if ("Delivered".equalsIgnoreCase(order.getStatus())) {
                totalRevenue += orderTotal;
                deliveredOrders++;
                
                // Cộng dồn vào dữ liệu biểu đồ
                chartData.put(orderDateStr, chartData.getOrDefault(orderDateStr, 0.0) + orderTotal);
            } else if ("Cancelled".equalsIgnoreCase(order.getStatus())) {
                cancelledOrders++;
            }
        }
    }

    // 4. CHUẨN BỊ DỮ LIỆU JSON CHO CHART.JS
    StringBuilder labels = new StringBuilder("[");
    StringBuilder data = new StringBuilder("[");
    
    for (Map.Entry<String, Double> entry : chartData.entrySet()) {
        labels.append("'").append(entry.getKey()).append("',");
        data.append(entry.getValue()).append(",");
    }
    
    // Xóa dấu phẩy cuối
    if (labels.length() > 1) labels.setLength(labels.length() - 1);
    if (data.length() > 1) data.setLength(data.length() - 1);
    
    labels.append("]");
    data.append("]");
    
    // Format tiền tệ hiển thị
    java.text.NumberFormat currencyVN = java.text.NumberFormat.getInstance(new Locale("vi", "VN"));
%>

<style>
    .stats-card {
        background: white;
        border-radius: 15px;
        padding: 25px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        transition: transform 0.3s;
        height: 100%;
        border-left: 5px solid #ddd;
    }
    .stats-card:hover { transform: translateY(-5px); }
    .stats-icon {
        font-size: 2.5rem;
        opacity: 0.2;
        position: absolute;
        right: 20px;
        top: 20px;
    }
    .card-revenue { border-left-color: #1cc88a; }
    .card-revenue .text-value { color: #1cc88a; }
    
    .card-order { border-left-color: #4e73df; }
    .card-order .text-value { color: #4e73df; }
    
    .card-cancel { border-left-color: #e74a3b; }
    .card-cancel .text-value { color: #e74a3b; }

    .chart-container {
        background: white;
        border-radius: 15px;
        padding: 20px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        margin-top: 30px;
    }
    
    .filter-bar {
        background: white;
        padding: 15px 25px;
        border-radius: 15px;
        margin-bottom: 30px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.02);
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 15px;
    }
</style>

<div class="container-fluid px-4">
    
    <div class="filter-bar">
    <h4 class="mb-0 fw-bold text-secondary"><i class="fas fa-chart-line me-2"></i>Thống kê doanh thu</h4>
    
    <form action="admin.jsp" method="get" class="d-flex gap-2 align-items-center">
        <input type="hidden" name="page" value="dashboard">
        <div class="input-group">
            <span class="input-group-text bg-light">Từ</span>
            <input type="date" class="form-control" name="startDate" value="<%= startDateStr %>">
        </div>
        
        <div class="input-group">
            <span class="input-group-text bg-light">Đến</span>
            <input type="date" class="form-control" name="endDate" value="<%= endDateStr %>">
        </div>
        
        <button type="submit" class="btn btn-primary px-4"><i class="fas fa-filter"></i> Lọc</button>
        
        <a href="ExportRevenueServlet?startDate=<%= startDateStr %>&endDate=<%= endDateStr %>" 
           class="btn btn-success px-4">
           <i class="fas fa-file-excel"></i>Excel
        </a>
    </form>
</div>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="stats-card card-revenue position-relative">
                <h6 class="text-uppercase text-muted fw-bold mb-2">Doanh thu thực tế</h6>
                <h2 class="text-value fw-bold mb-0"><%= currencyVN.format(totalRevenue) %> ₫</h2>
                <i class="fas fa-dollar-sign stats-icon text-success"></i>
                <small class="text-muted">Chỉ tính đơn đã giao thành công</small>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stats-card card-order position-relative">
                <h6 class="text-uppercase text-muted fw-bold mb-2">Tổng đơn hàng</h6>
                <h2 class="text-value fw-bold mb-0"><%= totalOrders %></h2>
                <i class="fas fa-shopping-bag stats-icon text-primary"></i>
                <div class="mt-2 small">
                    <span class="text-success"><i class="fas fa-check-circle"></i> <%= deliveredOrders %> thành công</span>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stats-card card-cancel position-relative">
                <h6 class="text-uppercase text-muted fw-bold mb-2">Đơn hàng đã hủy</h6>
                <h2 class="text-value fw-bold mb-0"><%= cancelledOrders %></h2>
                <i class="fas fa-times-circle stats-icon text-danger"></i>
                <small class="text-danger">Cần kiểm tra lý do</small>
            </div>
        </div>
    </div>

    <div class="chart-container">
        <h5 class="fw-bold text-secondary mb-4">Biểu đồ tăng trưởng doanh thu</h5>
        <canvas id="revenueChart" style="max-height: 400px;"></canvas>
    </div>
</div>

<script>
    const ctx = document.getElementById('revenueChart').getContext('2d');
    
    // Dữ liệu từ JSP
    const labels = <%= labels.toString() %>;
    const data = <%= data.toString() %>;

    new Chart(ctx, {
        type: 'bar', // Có thể đổi thành 'line' nếu muốn biểu đồ đường
        data: {
            labels: labels,
            datasets: [{
                label: 'Doanh thu (VNĐ)',
                data: data,
                backgroundColor: 'rgba(102, 126, 234, 0.6)', // Màu tím nhạt
                borderColor: 'rgba(102, 126, 234, 1)',       // Màu tím đậm
                borderWidth: 1,
                borderRadius: 5,
                barThickness: 40 // Độ rộng cột
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: '#f0f0f0'
                    },
                    ticks: {
                        callback: function(value) {
                            return value.toLocaleString('vi-VN') + ' ₫'; // Format trục Y
                        }
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            },
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return context.parsed.y.toLocaleString('vi-VN') + ' ₫';
                        }
                    }
                },
                legend: {
                    display: false // Ẩn chú thích nếu chỉ có 1 cột
                }
            }
        }
    });
</script>