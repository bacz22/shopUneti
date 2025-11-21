<%@page import="entities.User"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // LẤY THÔNG TIN USER TỪ SESSION (NẾU CÓ)
    User authUser = (User) session.getAttribute("activeUser");
    
    // Khởi tạo biến rỗng
    String fillName = "";
    String fillEmail = "";
    String fillPhone = "";
    
    // Nếu đã đăng nhập -> Lấy dữ liệu để điền vào form
    if(authUser != null) {
        fillName = authUser.getUserName();
        fillEmail = authUser.getUserEmail();
        fillPhone = authUser.getUserPhone();
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên hệ - UnetiShop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    
    <style>
        body { display: flex; flex-direction: column; min-height: 100vh; background-color: #f8f9fa; }
        main { flex: 1; }
        .contact-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 60px 0; margin-bottom: 40px; }
        .contact-card { border: none; border-radius: 15px; overflow: hidden; }
        .contact-info-box { background-color: #667eea; color: white; padding: 30px; height: 100%; border-radius: 15px 0 0 15px; }
        .contact-form-box { padding: 40px; background-color: white; }
        .form-control:focus { box-shadow: none; border-color: #667eea; }
        .btn-primary-custom { background-color: #667eea; border-color: #667eea; padding: 10px 25px; font-weight: bold; transition: all 0.3s; }
        .btn-primary-custom:hover { background-color: #764ba2; transform: translateY(-2px); }
        .info-item { display: flex; margin-bottom: 25px; }
        .info-icon { width: 40px; height: 40px; background-color: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px; font-size: 1.2rem; }
    </style>
</head>
<body>
    <%@include file="Components/navbar.jsp"%>
    
    <main>
        <div class="contact-header text-center">
            <div class="container">
                <h1 class="fw-bold">Liên hệ với chúng tôi</h1>
                <p class="lead">Chúng tôi luôn sẵn sàng lắng nghe và hỗ trợ bạn 24/7</p>
            </div>
        </div>

        <div class="container mb-5">
            <div class="card contact-card shadow-lg">
                <div class="row g-0">
                    <div class="col-lg-5 d-none d-lg-block">
                        <div class="contact-info-box">
                            <h3 class="fw-bold mb-4">Thông tin liên lạc</h3>
                            <p class="mb-4">Bạn có câu hỏi về sản phẩm, đơn hàng hoặc cần hỗ trợ kỹ thuật? Hãy liên hệ ngay với đội ngũ UnetiShop.</p>
                            
                            <div class="info-item">
                                <div class="info-icon"><i class="fas fa-map-marker-alt"></i></div>
                                <div><h6 class="fw-bold mb-1">Địa chỉ:</h6><p class="mb-0">218 Lĩnh Nam, Hoàng Mai, Hà Nội</p></div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon"><i class="fas fa-phone-alt"></i></div>
                                <div><h6 class="fw-bold mb-1">Hotline:</h6><p class="mb-0">0123 456 789</p></div>
                            </div>
                            <div class="info-item">
                                <div class="info-icon"><i class="fas fa-envelope"></i></div>
                                <div><h6 class="fw-bold mb-1">Email:</h6><p class="mb-0">support@unetishop.com</p></div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="contact-form-box">
                            <h3 class="fw-bold mb-4 text-secondary">Gửi tin nhắn cho chúng tôi</h3>
                            <%@include file="Components/alert_message.jsp"%>

                            <form action="ContactServlet" method="post">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Họ và tên <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fas fa-user text-muted"></i></span>
                                            <input type="text" name="name" class="form-control" placeholder="Nhập họ tên" 
                                                   value="<%=fillName%>" required>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Email <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fas fa-envelope text-muted"></i></span>
                                            <input type="email" name="email" class="form-control" placeholder="name@example.com" 
                                                   value="<%=fillEmail%>" required>
                                        </div>
                                    </div>
                                    
                                    <div class="col-12 mt-3">
                                        <label class="form-label fw-bold">Số điện thoại</label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fas fa-phone text-muted"></i></span>
                                            <input type="tel" name="phone" class="form-control" placeholder="Nhập số điện thoại" 
                                                   value="<%=fillPhone%>">
                                        </div>
                                    </div>

                                    <div class="col-12 mt-3">
                                        <label class="form-label fw-bold">Nội dung <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="fas fa-comment-alt text-muted"></i></span>
                                            <textarea name="message" class="form-control" rows="5" placeholder="Bạn cần hỗ trợ gì?" required></textarea>
                                        </div>
                                    </div>
                                    
                                    <div class="col-12 mt-4">
                                        <button type="submit" class="btn btn-primary-custom w-100 rounded-pill">
                                            <i class="fas fa-paper-plane me-2"></i>Gửi tin nhắn ngay
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer class="mt-auto">
        <%@include file="Components/footer.jsp"%>
    </footer>
    
    <script>
        // Active menu liên hệ
        document.addEventListener("DOMContentLoaded", function() {
            const navLinks = document.querySelectorAll('.nav-link');
            navLinks.forEach(link => {
                if(link.href.includes('contact.jsp')) {
                    link.classList.add('active');
                    // Thêm hiệu ứng đậm nếu muốn
                    link.style.fontWeight = "bold";
                }
            });
        });
    </script>
</body>
</html>