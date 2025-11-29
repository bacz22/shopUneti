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

    // 2. XỬ LÝ BỘ LỌC NGÀY
    String startDateStr = request.getParameter("startDate");
    String endDateStr = request.getParameter("endDate");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    Date startDate = null;
    Date endDate = null;
    
    if(startDateStr == null || startDateStr.isEmpty()) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, -30);
        startDate = cal.getTime();
        startDateStr = sdf.format(startDate);
    } else {
        startDate = sdf.parse(startDateStr);
    }
    
    if(endDateStr == null || endDateStr.isEmpty()) {
        endDate = new Date();
        endDateStr = sdf.format(endDate);
    } else {
        endDate = sdf.parse(endDateStr);
    }

    // 3. TÍNH TOÁN THỐNG KÊ
    double totalRevenue = 0;
    int totalOrders = 0;
    int deliveredOrders = 0;
    int cancelledOrders = 0;
    
    Map<String, Double> chartData = new TreeMap<>();
    
    // --- [MỚI THÊM] Map lưu Tên Sản Phẩm -> Số lượng bán ---
    Map<String, Integer> productSalesMap = new HashMap<>();

    for (Order order : allOrders) {
        String orderDateStr = sdf.format(order.getDate());
        Date orderDate = sdf.parse(orderDateStr);

        if (orderDate.compareTo(startDate) >= 0 && orderDate.compareTo(endDate) <= 0) {
            totalOrders++;
            
            double orderTotal = 0;
            List<OrderedProduct> products = ordProdDao.getAllOrderedProduct(order.getId());
            
            // Tính tổng tiền đơn hàng trước
            for(OrderedProduct p : products) {
                orderTotal += p.getPrice() * p.getQuantity();
            }

            if ("Delivered".equalsIgnoreCase(order.getStatus())) {
                totalRevenue += orderTotal;
                deliveredOrders++;
                chartData.put(orderDateStr, chartData.getOrDefault(orderDateStr, 0.0) + orderTotal);

                // --- [MỚI THÊM] Cộng dồn số lượng bán cho từng sản phẩm ---
                for(OrderedProduct p : products) {
                    String pName = p.getName(); // Giả sử OrderedProduct có hàm getName()
                    int qty = p.getQuantity();
                    productSalesMap.put(pName, productSalesMap.getOrDefault(pName, 0) + qty);
                }

            } else if ("Cancelled".equalsIgnoreCase(order.getStatus())) {
                cancelledOrders++;
            }
        }
    }

    // --- [MỚI THÊM] Xử lý sắp xếp Top 5 ---
    List<Map.Entry<String, Integer>> sortedProducts = new ArrayList<>(productSalesMap.entrySet());
    
    // Sắp xếp giảm dần theo số lượng (cho Best Seller)
    Collections.sort(sortedProducts, (a, b) -> b.getValue().compareTo(a.getValue()));

    // Lấy Top 5 bán chạy
    List<Map.Entry<String, Integer>> top5Best = new ArrayList<>();
    for(int i = 0; i < Math.min(5, sortedProducts.size()); i++) {
        top5Best.add(sortedProducts.get(i));
    }

    // Lấy Top 5 bán ế (Lấy từ cuối danh sách lên)
    List<Map.Entry<String, Integer>> top5Worst = new ArrayList<>();
    if (!sortedProducts.isEmpty()) {
        int size = sortedProducts.size();
        // Lấy tối đa 5 phần tử cuối cùng
        for(int i = size - 1; i >= Math.max(0, size - 5); i--) {
            top5Worst.add(sortedProducts.get(i));
        }
    }

    // 4. CHUẨN BỊ DỮ LIỆU BIỂU ĐỒ (Giữ nguyên)
    StringBuilder labels = new StringBuilder("[");
    StringBuilder data = new StringBuilder("[");
    for (Map.Entry<String, Double> entry : chartData.entrySet()) {
        labels.append("'").append(entry.getKey()).append("',");
        data.append(entry.getValue()).append(",");
    }
    if (labels.length() > 1) labels.setLength(labels.length() - 1);
    if (data.length() > 1) data.setLength(data.length() - 1);
    labels.append("]");
    data.append("]");
    
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
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white border-0 py-3">
                    <h5 class="mb-0 fw-bold text-success">
                        <i class="fas fa-crown me-2"></i>Top 5 Sản phẩm bán chạy
                    </h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="bg-light">
                                <tr>
                                    <th class="ps-4">#</th>
                                    <th>Sản phẩm</th>
                                    <th class="text-end pe-4">Đã bán</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                int rank = 1;
                                if(top5Best.isEmpty()) { %>
                                    <tr><td colspan="3" class="text-center py-3">Chưa có dữ liệu</td></tr>
                                <% } else {
                                    for(Map.Entry<String, Integer> entry : top5Best) { 
                                %>
                                <tr>
                                    <td class="ps-4 fw-bold text-secondary"><%= rank++ %></td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="fw-bold"><%= entry.getKey() %></div>
                                        </div>
                                        <div class="progress mt-1" style="height: 4px; width: 80%;">
                                            <div class="progress-bar bg-success" role="progressbar" 
                                                 style="width: <%= (entry.getValue() * 100) / top5Best.get(0).getValue() %>%"></div>
                                        </div>
                                    </td>
                                    <td class="text-end pe-4">
                                        <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill">
                                            <%= entry.getValue() %> cái
                                        </span>
                                    </td>
                                </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card shadow-sm border-0 h-100">
                <div class="card-header bg-white border-0 py-3">
                    <h5 class="mb-0 fw-bold text-danger">
                        <i class="fas fa-box-open me-2"></i>Top 5 Ít người mua
                    </h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="bg-light">
                                <tr>
                                    <th class="ps-4">#</th>
                                    <th>Sản phẩm</th>
                                    <th class="text-end pe-4">Đã bán</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                int rankWorst = 1;
                                if(top5Worst.isEmpty()) { %>
                                    <tr><td colspan="3" class="text-center py-3">Chưa có dữ liệu</td></tr>
                                <% } else {
                                    for(Map.Entry<String, Integer> entry : top5Worst) { 
                                %>
                                <tr>
                                    <td class="ps-4 fw-bold text-secondary"><%= rankWorst++ %></td>
                                    <td><%= entry.getKey() %></td>
                                    <td class="text-end pe-4">
                                        <span class="badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill">
                                            <%= entry.getValue() %> cái
                                        </span>
                                    </td>
                                </tr>
                                <% }} %>
                            </tbody>
                        </table>
                    </div>
                </div>
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