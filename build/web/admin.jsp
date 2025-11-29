<%@page import="entities.Admin"%>
<%@page import="entities.Message"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page errorPage="error_exception.jsp"%>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
<%
    Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
    if (activeAdmin == null) {
        Message message = new Message("Bạn chưa đăng nhập! Vui lòng đăng nhập trước!!", "error", "alert-danger");
        session.setAttribute("message", message);
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    // Lấy tham số 'page' từ URL để biết cần hiện nội dung gì
    String pageParam = request.getParameter("page");
    if (pageParam == null) {
        pageParam = "dashboard"; // Mặc định là dashboard
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Admin Dashboard | UnetiShop</title>
        <%@include file="Components/common_css_js.jsp"%>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

        <style>
            :root {
                --sidebar-width: 260px;
                --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            }
            body {
                background-color: #f3f4f6;
                font-family: 'Segoe UI', sans-serif;
                overflow-x: hidden;
            }
            .admin-wrapper {
                display: flex;
                min-height: 100vh;
            }

            /* Sidebar Styles */
            .sidebar {
                width: var(--sidebar-width);
                background: var(--primary-gradient);
                color: white;
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                z-index: 1000;
                display: flex;
                flex-direction: column;
            }
            .sidebar-header {
                padding: 25px 20px;
                border-bottom: 1px solid rgba(255,255,255,0.1);
                font-size: 1.4rem;
                font-weight: 800;
            }
            .admin-profile {
                padding: 30px 20px;
                text-align: center;
                border-bottom: 1px solid rgba(255,255,255,0.1);
            }
            .admin-avatar {
                width: 80px;
                height: 80px;
                border-radius: 50%;
                background: white;
                padding: 3px;
                margin-bottom: 10px;
            }
            .sidebar-menu {
                padding: 20px 0;
                flex-grow: 1;
                overflow-y: auto;
            }
            .menu-item {
                display: flex;
                align-items: center;
                padding: 12px 25px;
                color: rgba(255,255,255,0.8);
                text-decoration: none;
                transition: all 0.3s;
                font-weight: 500;
            }
            .menu-item:hover, .menu-item.active {
                background: rgba(255,255,255,0.1);
                color: white;
                border-left: 4px solid #fff;
            }
            .menu-item i {
                width: 25px;
                margin-right: 10px;
            }

            /* Main Content */
            .main-content {
                margin-left: var(--sidebar-width);
                flex-grow: 1;
                padding: 30px;
            }

            /* Stats Cards Styles (Chỉ dùng cho Dashboard) */
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                gap: 20px;
            }
            .stat-card {
                background: white;
                border-radius: 16px;
                padding: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .stat-icon {
                width: 50px;
                height: 50px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
            }
            .bg-cat {
                background: rgba(17, 153, 142, 0.1);
                color: #11998e;
            }
        </style>
    </head>
    <body>

        <div class="admin-wrapper">

            <nav class="sidebar">
                <div class="sidebar-header"><i class="fas fa-store me-2"></i> UnetiShop</div>
                <div class="admin-profile">
                    <img src="Images/admin.png" class="admin-avatar" alt="Admin">
                    <h6 class="mb-0 mt-2"><%= activeAdmin.getName()%></h6>
                </div>

                <div class="sidebar-menu">
                    <a href="admin.jsp?page=dashboard" class="menu-item <%= pageParam.equals("dashboard") ? "active" : ""%>">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                    <a href="admin.jsp?page=category" class="menu-item <%= pageParam.equals("category") ? "active" : ""%>">
                        <i class="fas fa-th-large"></i> Quản lý Danh mục
                    </a>
                    <a href="admin.jsp?page=products" class="menu-item <%= pageParam.equals("products") ? "active" : ""%>">
                        <i class="fas fa-box-open"></i> Quản lý Sản phẩm
                    </a>
                    <a href="admin.jsp?page=orders" class="menu-item <%= pageParam.equals("orders") ? "active" : ""%>">
                        <i class="fas fa-shopping-cart"></i> Quản lý Đơn hàng
                    </a>
                    <a href="admin.jsp?page=users" class="menu-item <%= pageParam.equals("users") ? "active" : ""%>">
                        <i class="fas fa-users"></i> Quản lý Người dùng
                    </a>
                    <a href="admin.jsp?page=contacts" class="menu-item <%= pageParam.equals("contacts") ? "active" : ""%>">
                        <i class="fas fa-envelope"></i> Quản lý Liên hệ
                    </a>
                    <a href="admin.jsp?page=profile" class="menu-item <%= pageParam.equals("profile") ? "active" : ""%>">
                        <i class="fas fa-id-card"></i> Thông tin tài khoản
                    </a>    
                </div>
                <div class="p-3">
                    <a href="LogoutServlet?user=admin" class="btn btn-outline-light w-100">Đăng xuất</a>
                </div>
            </nav>

            <main class="main-content">
                <%@include file="Components/alert_message.jsp"%>

                <%            // LOGIC ĐIỀU HƯỚNG NỘI DUNG
                    if (pageParam.equals("dashboard")) {
                %>
                <jsp:include page="dashboard.jsp" />

                <% } else if (pageParam.equals("category")) { %>

                <jsp:include page="display_category.jsp" />

                <% } else if (pageParam.equals("products")) { %>

                <jsp:include page="display_products.jsp" />

                <% } else if (pageParam.equals("orders")) { %>
                <jsp:include page="display_orders.jsp" />

                <% } else if (pageParam.equals("users")) { %>
                <jsp:include page="display_users.jsp" />

                <% } else if (pageParam.equals("contacts")) { %>
                <jsp:include page="display_contacts.jsp" />

                <% } else if (pageParam.equals("profile")) { %>
                <jsp:include page="admin_profile.jsp" />
                <% }%>

            </main>
        </div>

        <script>
    // Show confirmation modal (Bootstrap) before exporting
    function confirmExport(orderId) {
        if (!orderId) { alert("Lỗi: Không xác định mã đơn hàng."); return; }
        var modalEl = document.getElementById('confirmExportModal');
        modalEl.querySelector('#confirmExportOrderId').innerText = orderId;
        modalEl.dataset.orderId = orderId;
        var modal = new bootstrap.Modal(modalEl);
        modal.show();
    }

    function exportPDF(orderId) {
    if (!orderId) {
        alert("Lỗi: Không có mã đơn hàng!");
        return;
    }

    // Tạo container ẨN NHƯNG VẪN TRONG VIEWPORT (quan trọng!)
    let container = document.createElement('div');
    container.id = 'pdf-export-container';
    container.style.position = 'absolute';
    container.style.left = '0';
    container.style.top = '-9999px';   // chỉ đẩy xuống dưới, không ra khỏi left
    container.style.width = '210mm';
    container.style.minHeight = '297mm';
    container.style.background = 'white';
    container.style.padding = '20mm';
    container.style.boxShadow = '0 0 20px rgba(0,0,0,0.1)';
    container.style.fontFamily = 'DejaVu Sans, Arial, sans-serif';
    document.body.appendChild(container);

    // Loading
    container.innerHTML = `<div style="text-align:center;padding:100px;font-size:18px;color:#666;">
        <div class="spinner-border text-primary" style="width:3rem;height:3rem;"></div>
        <div>Đang tạo hóa đơn PDF...</div>
    </div>`;

    // Gọi AJAX lấy chi tiết đơn hàng
    fetch('load_order_details.jsp?orderId=' + orderId + '&t=' + Date.now()) // chống cache
        .then(r => {
            if (!r.ok) throw new Error('Không tải được dữ liệu đơn hàng');
            return r.text();
        })
        .then(htmlData => {
            // Log để debug (mở F12 xem có dữ liệu không)
            console.log("Dữ liệu nhận được:", htmlData);

            // Tạo template
            container.innerHTML = getInvoiceTemplate(orderId, htmlData);

            // Đảm bảo DOM đã render xong
            setTimeout(() => {
                const opt = {
                    margin: [5, 5, 10, 5],
                    filename: `HoaDon_${orderId}.pdf`,
                    image: { type: 'jpeg', quality: 0.98 },
                    html2canvas: {
                        scale: 2,
                        useCORS: true,
                        letterRendering: true,
                        allowTaint: false,
                        backgroundColor: '#ffffff',
                        scrollX: 0,
                        scrollY: 0
                    },
                    jsPDF: {
                        unit: 'mm',
                        format: 'a4',
                        orientation: 'portrait'
                    }
                };

                html2pdf().set(opt).from(container).save()
                    .then(() => {
                        console.log("PDF đã xuất thành công!");
                    })
                    .catch(err => {
                        console.error("Lỗi html2pdf:", err);
                        alert("Lỗi tạo PDF: " + err.message);
                    })
                    .finally(() => {
                        container.remove();
                    });
            }, 300); // chờ 300ms để DOM render
        })
        .catch(err => {
            alert("Lỗi: " + err.message);
            console.error(err);
            container.remove();
        });
}

    // Export invoice as a Word (.doc) document
    function exportWord(orderId) {
        if (!orderId) {
            alert("Lỗi: Không có mã đơn hàng!");
            return Promise.reject(new Error('No orderId'));
        }

        // Fetch the same detail HTML used for PDF so content is consistent
        return fetch('load_order_details.jsp?orderId=' + orderId + '&t=' + Date.now())
            .then(function(r) {
                if (!r.ok) throw new Error('Không tải được dữ liệu đơn hàng');
                return r.text();
            })
            .then(function(htmlData) {
                // Build final HTML for Word
                var bodyHtml = getInvoiceTemplate(orderId, htmlData);
                var header = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Hóa đơn #' + orderId + '</title></head><body>';
                var footer = '</body></html>';
                var fullHtml = header + bodyHtml + footer;

                // Create a Blob and trigger download as .doc (Word can open HTML files saved with .doc)
                var blob = new Blob(['\ufeff', fullHtml], { type: 'application/msword' });
                var filename = 'HoaDon_UnetiShop_' + orderId + '.doc';
                var url = URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.href = url;
                a.download = filename;
                document.body.appendChild(a);
                a.click();
                setTimeout(function() {
                    document.body.removeChild(a);
                    URL.revokeObjectURL(url);
                }, 100);

                return Promise.resolve();
            })
            .catch(function(err) {
                console.error(err);
                alert('Lỗi khi tạo Word: ' + (err.message || err));
                return Promise.reject(err);
            });
    }

    function getInvoiceTemplate(orderId, htmlData) {
    const today = new Date();
    const dateStr = today.toLocaleDateString('vi-VN') + ' ' +
                    today.toLocaleTimeString('vi-VN', {hour:'2-digit', minute:'2-digit'});

    // LỌC CHỈ LẤY CÁC DÒNG <tr> CÓ SẢN PHẨM + TỔNG TIỀN
    // Dùng DOMParser để phân tích HTML trả về (ổn định hơn regex)
    let contentRows = '';
    try {
        var parser = new DOMParser();
        var doc = parser.parseFromString(htmlData, 'text/html');
        var trNodes = doc.querySelectorAll('tr');
        console.log('Found', trNodes.length, 'tr rows in fetched detail HTML');
        trNodes.forEach(function(tr){
            // loại bỏ các hàng chứa nút, hoặc có class no-print
            if (tr.closest('.no-print') || tr.classList.contains('no-print')) return;
            if (tr.querySelector('button')) return;
            // skip rows that are empty or only whitespace
            if (!tr.innerHTML || tr.innerHTML.trim() === '') return;
            contentRows += tr.outerHTML;
        });
    } catch (e) {
        console.warn('DOMParser failed, falling back to regex', e);
        const rows = htmlData.match(/<tr[\s\S]*?<\/tr>/gi) || [];
        for (let row of rows) {
            if (row.includes('no-print') || row.includes('button') || row.includes('onclick')) continue;
            contentRows += row;
        }
    }

    // Nếu không có dòng nào → báo lỗi
    if (!contentRows.trim()) {
        contentRows = `<tr><td colspan="5" style="text-align:center;color:red;padding:50px;">
                        Không tìm thấy dữ liệu sản phẩm!</td></tr>`;
    }

    return `
<div style="max-width:100%;margin:0 auto;font-size:14px;line-height:1.6;">
    <div style="text-align:center;border-bottom:4px double #333;padding-bottom:15px;margin-bottom:25px;">
        <h1 style="margin:0;font-size:32px;color:#1976d2;font-weight:bold;">UNETI SHOP</h1>
        <p style="margin:8px 0;font-size:16px;">218 Lĩnh Nam, Hoàng Mai, Hà Nội</p>
        <p style="margin:8px 0;font-size:16px;">Hotline: 0123 456 789</p>
        <h2 style="margin:20px 0 0;font-size:28px;color:#d32f2f;">HÓA ĐƠN BÁN HÀNG</h2>
    </div>

    <div style="display:flex;justify-content:space-between;margin:20px 0;font-size:16px;">
        <div><strong>Mã đơn hàng:</strong> #${orderId}</div>
        <div><strong>Ngày in:</strong> ${dateStr}</div>
    </div>

    <table style="width:100%;border-collapse:collapse;margin:20px 0;">
        <thead>
            <tr style="background:#e3f2fd;">
                <th style="border:1px solid #333;padding:12px;text-align:center;font-weight:bold;">STT</th>
                <th style="border:1px solid #333;padding:12px;text-align:left;font-weight:bold;">Sản phẩm</th>
                <th style="border:1px solid #333;padding:12px;text-align:center;font-weight:bold;">SL</th>
                <th style="border:1px solid #333;padding:12px;text-align:right;font-weight:bold;">Đơn giá</th>
                <th style="border:1px solid #333;padding:12px;text-align:right;font-weight:bold;">Thành tiền</th>
            </tr>
        </thead>
        <tbody style="font-size:15px;">
            ${contentRows}
        </tbody>
    </table>

    <div style="text-align:center;margin-top:60px;color:#555;font-size:15px;">
        <p style="font-size:18px;"><strong>Cảm ơn quý khách đã mua sắm!</strong></p>
        <p>Hóa đơn có giá trị trong ngày</p>
    </div>
</div>`;
}
</script>
    </body>
</html>

<!-- Confirm Export Modal -->
<div class="modal fade" id="confirmExportModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Xác nhận xuất Hóa Đơn</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Bạn có chắc muốn xuất Hóa Đơn Word cho đơn <strong>#<span id="confirmExportOrderId"></span></strong> không?</p>
                <p class="text-muted small">Hành động này sẽ tạo file Word (.doc) và kích hoạt tải về trên máy của bạn.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Hủy</button>
                <button id="confirmExportBtn" type="button" class="btn btn-primary rounded-pill">
                    <span id="confirmExportBtnText">Xuất Word</span>
                    <span id="confirmExportSpinner" class="spinner-border spinner-border-sm ms-2" role="status" aria-hidden="true" style="display:none"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    // Wire confirm button to call exportWord and manage UI state
    (function(){
        var btn = document.getElementById('confirmExportBtn');
        var modalEl = document.getElementById('confirmExportModal');
        var spinner = document.getElementById('confirmExportSpinner');
        var btnText = document.getElementById('confirmExportBtnText');

        if (btn && modalEl) {
            btn.addEventListener('click', function(){
                var orderId = modalEl.dataset.orderId;
                if (!orderId) return;
                btn.disabled = true;
                spinner.style.display = 'inline-block';
                btnText.innerText = 'Đang xuất...';

                // Call exportWord and re-enable on finish
                try {
                    var p = exportWord(orderId);
                    if (p && typeof p.then === 'function') {
                        p.then(function(){
                            // success
                        }).catch(function(){
                            // handled inside exportPDF already
                        }).finally(function(){
                            try { var modalInstance = bootstrap.Modal.getInstance(modalEl); if (modalInstance) modalInstance.hide(); } catch(e){}
                            btn.disabled = false;
                            spinner.style.display = 'none';
                            btnText.innerText = 'Xuất Word';
                        });
                    } else {
                        // If exportPDF didn't return a promise, just cleanup
                        try { var modalInstance = bootstrap.Modal.getInstance(modalEl); if (modalInstance) modalInstance.hide(); } catch(e){}
                        btn.disabled = false;
                        spinner.style.display = 'none';
                        btnText.innerText = 'Xuất Word';
                    }
                } catch(e) {
                    console.error(e);
                    btn.disabled = false;
                    spinner.style.display = 'none';
                    btnText.innerText = 'Xuất Word';
                }
            });
        }
    })();
</script>