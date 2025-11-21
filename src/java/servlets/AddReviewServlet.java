package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.ReviewDao;
import entities.Review;
import entities.Message;
import helper.ConnectionProvider;

@WebServlet("/AddReviewServlet")
public class AddReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        try {
            // Lấy dữ liệu từ form
            int uid = Integer.parseInt(request.getParameter("uid"));
            int pid = Integer.parseInt(request.getParameter("pid"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            // Tạo đối tượng Review
            // isVerified = true (Vì logic là phải mua hàng mới được đánh giá)
            Review review = new Review(pid, uid, rating, comment, true);
            
            // Lưu xuống DB
            ReviewDao dao = new ReviewDao(ConnectionProvider.getConnection());
            boolean f = dao.saveReview(review);

            HttpSession session = request.getSession();
            if (f) {
                session.setAttribute("message", new Message("Đánh giá thành công!", "success", "alert-success"));
            } else {
                session.setAttribute("message", new Message("Lỗi khi lưu đánh giá!", "error", "alert-danger"));
            }
            
            response.sendRedirect("viewProduct.jsp?pid=" + pid);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp");
        }
    }
}