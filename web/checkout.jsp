<%@page import="entities.User"%>
<%@page import="helper.ConnectionProvider"%>
<%@page import="entities.Message"%>
<%@page import="dao.ProductDao"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<meta charset="UTF-8">
<%@page import="dao.CartDao"%>
<%@page errorPage="error_exception.jsp"%>
<%
    User activeUser = (User) session.getAttribute("activeUser");
    if (activeUser == null) {
        Message message = new Message("Bạn chưa đăng nhập! Vui lòng đăng nhập trước!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("login.jsp");
        return;
    }
    User checkoutUser = activeUser;
    String from = (String) session.getAttribute("from");

// Lưu pid và quantity vào session nếu có từ request (khi mua ngay)
    if (request.getParameter("pid") != null) {
        session.setAttribute("pid", Integer.parseInt(request.getParameter("pid")));
        session.setAttribute("from", "buy");
        from = "buy"; // Cập nhật biến from
    }
    if (request.getParameter("quantity") != null) {
        session.setAttribute("buyQuantity", Integer.parseInt(request.getParameter("quantity")));
    } else if (session.getAttribute("buyQuantity") == null) {
        session.setAttribute("buyQuantity", 1); // Mặc định là 1 nếu chưa có
    }

// Đảm bảo from không null
    if (from == null) {
        from = "cart"; // Mặc định là cart nếu không có
    }
%>
<%!
    public String formatCurrency(double amount) {
        java.text.NumberFormat formatter = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
        return formatter.format(amount) + " ₫";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Thanh toán</title>
        <%@include file="Components/common_css_js.jsp"%>
        <style>
            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
                font-family: 'Segoe UI', sans-serif;
            }
            .checkout-page {
                padding: 32px 0 48px;
            }
            .checkout-wrapper {
                max-width: 1200px;
            }
            .glass-card {
                background: rgba(255,255,255,0.98);
                border-radius: 20px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.08);
                border: 1px solid rgba(255,255,255,0.6);
                padding: 24px 28px;
            }
            .card-heading {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 18px;
            }
            .card-heading h4 {
                font-weight: 700;
                font-size: 20px;
                color: #2d2d44;
                margin: 0;
            }
            .address-text {
                font-size: 15px;
                color: #5f6275;
                line-height: 1.6;
            }
            .action-link {
                color: #667eea;
                font-weight: 600;
                border: 1px solid rgba(102,126,234,0.4);
                border-radius: 999px;
                padding: 8px 18px;
                background: rgba(102,126,234,0.08);
            }
            .action-link:hover {
                color: #fff;
                background: linear-gradient(135deg, #667eea, #764ba2);
                border-color: transparent;
            }
            .payment-option {
                display: flex;
                flex-direction: column;
                gap: 14px;
                margin-top: 10px;
            }
            .option-card {
                border: 1px solid #e2e6ff;
                border-radius: 16px;
                padding: 16px 18px;
                background: #fdfdff;
                transition: all 0.2s ease;
                position: relative;
            }
            .option-card:hover {
                border-color: #667eea;
                box-shadow: 0 10px 25px rgba(102,126,234,0.15);
            }
            .form-check-input[type="radio"] {
                width: 18px;
                height: 18px;
                margin-top: 0;
                cursor: pointer;
            }
            .option-body {
                margin-left: 32px;
            }
            .option-title {
                font-weight: 600;
                color: #2d2d44;
            }
            .option-desc {
                font-size: 14px;
                color: #7a7a94;
                margin: 2px 0 0;
            }
            .card-details {
                margin-top: 18px;
                padding: 18px;
                border-radius: 16px;
                background: rgba(102,126,234,0.05);
                display: none;
                border: 1px dashed rgba(102,126,234,0.4);
            }
            .card-details.show {
                display: block;
            }
            .summary-card {
                background: #11111f;
                color: #fff;
                border-radius: 22px;
                padding: 28px;
                box-shadow: 0 20px 45px rgba(17,17,31,0.6);
            }
            .summary-card h4 {
                font-weight: 700;
            }
            .summary-line {
                display: flex;
                justify-content: space-between;
                margin-bottom: 12px;
                font-size: 15px;
            }
            .summary-line.total {
                font-size: 18px;
                font-weight: 700;
                margin-top: 18px;
            }
            .coupon-pill {
                background: rgba(255,255,255,0.1);
                border-radius: 12px;
                padding: 10px 14px;
                font-size: 14px;
                display: inline-flex;
                align-items: center;
                gap: 6px;
                margin-bottom: 18px;
            }
            .place-order-btn {
                width: 100%;
                border: none;
                border-radius: 999px;
                padding: 15px 0;
                font-weight: 700;
                font-size: 16px;
                background: linear-gradient(135deg, #00c6ff, #0072ff);
                color: #fff;
                box-shadow: 0 15px 35px rgba(0,114,255,0.35);
                transition: transform 0.2s ease;
            }
            .place-order-btn:hover {
                transform: translateY(-2px);
            }
            @media (max-width: 992px) {
                .glass-card {
                    padding: 20px;
                }
                .summary-card {
                    margin-top: 12px;
                }
            }
        </style>
    </head>
    <body>
        <%@include file="Components/navbar.jsp"%>

        <main class="checkout-page">
            <div class="container checkout-wrapper">
                <%@include file="Components/alert_message.jsp"%>

                <div class="row g-4">
                    <%                                    StringBuilder addressBuilder = new StringBuilder();
                        if (checkoutUser.getUserAddress() != null && !checkoutUser.getUserAddress().trim().isEmpty()) {
                            addressBuilder.append(checkoutUser.getUserAddress().trim());
                        }
                        if (checkoutUser.getUserCity() != null && !checkoutUser.getUserCity().trim().isEmpty()) {
                            if (addressBuilder.length() > 0) {
                                addressBuilder.append(", ");
                            }
                            addressBuilder.append(checkoutUser.getUserCity().trim());
                        }
                        String fullAddress = addressBuilder.toString();
                    %>
                    <div class="col-lg-8">
                        <div class="glass-card mb-4">
                            <div class="card-heading">
                                <h4>1. Địa chỉ giao hàng</h4>
                                <button type="button" class="action-link" data-bs-toggle="modal" data-bs-target="#exampleModal">
                                    <i class="fas fa-map-marker-alt me-2"></i>Thay đổi
                                </button>
                            </div>
                            <p class="mb-1 fw-semibold">
                                <%=checkoutUser.getUserName()%> · <span class="text-muted"><%=checkoutUser.getUserPhone()%></span>
                            </p>
                            <p class="address-text mb-0">
                                <%=fullAddress.isEmpty() ? "Chưa có địa chỉ. Vui lòng cập nhật để tiếp tục." : fullAddress%>
                            </p>
                        </div>

                        <div class="glass-card">
                            <div class="card-heading">
                                <h4>2. Phương thức thanh toán</h4>
                                <small class="text-muted">Chọn phương thức bạn muốn</small>
                            </div>

                            <form action="OrderOperationServlet" method="post" id="paymentForm">
                                <div class="payment-option">
                                    <div class="option-card">
                                        <div class="form-check d-flex">
                                            <input class="form-check-input mt-1" type="radio" name="payementMode"
                                                   value="Cash on Delivery" id="codOption" data-target="cod">
                                            <div class="option-body">
                                                <label class="option-title" for="codOption">Thanh toán khi nhận hàng</label>
                                                <p class="option-desc">Thanh toán tiền mặt cho nhân viên giao hàng</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="option-card">
                                        <div class="form-check d-flex">
                                            <input class="form-check-input mt-1" type="radio" name="payementMode"
                                                   value="Card Payment" id="cardOption" required data-target="card">
                                            <div class="option-body">
                                                <label class="option-title" for="cardOption">Thanh toán bằng thẻ</label>
                                                <p class="option-desc">Hỗ trợ Visa, MasterCard, ATM nội địa</p>
                                            </div>
                                        </div>
                                    </div>


                                </div>

                                <div class="card-details mt-4" id="cardDetails">
                                    <div class="row g-3">
                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Số thẻ</label>
                                            <input class="form-control" type="text" name="cardno" placeholder="XXXX XXXX XXXX XXXX">
                                        </div>
                                        <div class="col-sm-6">
                                            <label class="form-label fw-semibold">CVV</label>
                                            <input class="form-control" type="text" name="cvv" maxlength="4" placeholder="3-4 số mặt sau">
                                        </div>
                                        <div class="col-sm-6">
                                            <label class="form-label fw-semibold">Ngày hết hạn</label>
                                            <input class="form-control" type="text" name="expiry" placeholder="MM/YY">
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label fw-semibold">Tên chủ thẻ</label>
                                            <input class="form-control" type="text" name="name" placeholder="Nguyễn Văn A">
                                        </div>
                                    </div>
                                </div>

                                <div class="mt-4">
                                    <button type="submit" class="place-order-btn">
                                        Đặt hàng ngay
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <%
                            double deliveryFee = 40000;
                            double packagingFee = 29000;
                            int totalItems = 0;
                            double merchandiseTotal = 0;

                            if ("cart".equalsIgnoreCase(from.trim())) {
                                CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
                                totalItems = cartDao.getCartCountByUserId(checkoutUser.getUserId());
                                Object totalObj = session.getAttribute("totalPrice");
                                if (totalObj instanceof Double) {
                                    merchandiseTotal = (Double) totalObj;
                                } else if (totalObj instanceof Float) {
                                    merchandiseTotal = ((Float) totalObj).doubleValue();
                                } else if (totalObj != null) {
                                    try {
                                        merchandiseTotal = Double.parseDouble(totalObj.toString());
                                    } catch (Exception e) {
                                        merchandiseTotal = 0;
                                    }
                                }
                            } else {
                                ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
                                int pid = session.getAttribute("pid") != null ? (int) session.getAttribute("pid") : 0;
                                int buyQty = session.getAttribute("buyQuantity") != null ? (int) session.getAttribute("buyQuantity") : 1;
                                totalItems = buyQty;
                                if (pid != 0) {
                                    float unitPrice = productDao.getProductPriceById(pid);
                                    merchandiseTotal = unitPrice * buyQty;
                                }
                            }

                            double grandTotal = merchandiseTotal + deliveryFee + packagingFee;
                        %>
                        <div class="summary-card">
                            <h4 class="mb-3">Tóm tắt đơn hàng</h4>
                            <div class="coupon-pill">
                                <i class="fas fa-ticket-alt"></i> Miễn phí đổi trả trong 7 ngày
                            </div>
                            <div class="summary-line">
                                <span>Số lượng sản phẩm</span>
                                <span><%=totalItems%></span>
                            </div>
                            <div class="summary-line">
                                <span>Tạm tính</span>
                                <span><%=formatCurrency(merchandiseTotal)%></span>
                            </div>
                            <div class="summary-line">
                                <span>Phí giao hàng</span>
                                <span><%=deliveryFee == 0 ? "Miễn phí" : formatCurrency(deliveryFee)%></span>
                            </div>
                            <div class="summary-line">
                                <span>Phí đóng gói</span>
                                <span><%=packagingFee == 0 ? "Miễn phí" : formatCurrency(packagingFee)%></span>
                            </div>
                            <div class="summary-line total">
                                <span>Tổng cộng</span>
                                <span><%=formatCurrency(grandTotal)%></span>
                            </div>
                            <p class="mt-3 small opacity-75">
                                Bằng việc tiếp tục, bạn đồng ý với chính sách giao hàng & hoàn trả của UnetiShop.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <script>
            (() => {
                const form = document.getElementById("paymentForm");
                const cardDetails = document.getElementById("cardDetails");
                if (!form || !cardDetails)
                    return;

                const radios = form.querySelectorAll('input[name="payementMode"]');
                const cardInputs = cardDetails.querySelectorAll("input");

                const toggleCardFields = (show) => {
                    cardDetails.classList.toggle("show", show);
                    cardInputs.forEach(input => {
                        input.required = show;
                        input.disabled = !show;
                        if (!show) {
                            input.value = "";
                        }
                    });
                };

                radios.forEach(radio => {
                    radio.addEventListener("change", () => {
                        toggleCardFields(radio.value === "Card Payment");
                    });
                });
            })();
        </script>


        <!--Change Address Modal -->
        <div class="modal fade" id="exampleModal" tabindex="-1"
             aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="exampleModalLabel">Change
                            Address</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <form action="UpdateUserServlet" method="post">
                        <input type="hidden" name="operation" value="changeAddress">
                        <div class="modal-body mx-3">
                            <div class="mt-2">
                                <label class="form-label fw-bold">Address</label>
                                <textarea name="user_address" rows="3"
                                          placeholder="Enter Address(Area and Street))"
                                          class="form-control" required></textarea>
                            </div>
                            <div class="mt-2">
                                <label class="form-label fw-bold">City</label> <input
                                    class="form-control" type="text" name="city"
                                    placeholder="City/District/Town" required>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary"
                                    data-bs-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-primary">Save</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <!-- end modal -->

        <%@include file="Components/footer.jsp"%>

    </body>
</html>