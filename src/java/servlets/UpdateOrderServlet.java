package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.OrderDao;
import helper.ConnectionProvider;


public class UpdateOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        try {
            // 1. Lấy dữ liệu từ form (bên display_orders.jsp gửi sang)
            int oid = Integer.parseInt(request.getParameter("oid"));
            String status = request.getParameter("status");
            
            // Lấy trang hiện tại để lát nữa quay về đúng chỗ
            String currentPage = request.getParameter("currentPage");
            if(currentPage == null || currentPage.isEmpty()){
                currentPage = "1";
            }

            // 2. Cập nhật trạng thái vào Database
            OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
            // Giả sử trong OrderDao bạn đã có hàm này:
            // public void updateOrderStatus(int orderId, String status) { ... }
            orderDao.updateOrderStatus(oid, status); 

            // 3. CHUYỂN HƯỚNG VỀ TRANG ADMIN (QUAN TRỌNG)
            // ?page=orders : Để admin.jsp biết load file display_orders.jsp
            // &p=...       : Để giữ nguyên vị trí phân trang
            response.sendRedirect("admin.jsp?page=orders&p=" + currentPage);

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu lỗi thì quay về trang 1
            response.sendRedirect("admin.jsp?page=orders");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
}