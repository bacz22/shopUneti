package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.ContactDao;
import entities.Contact;
import entities.Message;
import helper.ConnectionProvider;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Lấy dữ liệu từ form (nhớ xử lý tiếng Việt)
        request.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String content = request.getParameter("message");

        Contact contact = new Contact(name, email, phone, content);
        ContactDao dao = new ContactDao(ConnectionProvider.getConnection());
        
        boolean ans = dao.saveContact(contact);

        HttpSession session = request.getSession();
        if (ans) {
            // Gửi thông báo thành công
            Message msg = new Message("Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi sớm nhất.", "success", "alert-success");
            session.setAttribute("message", msg);
        } else {
            Message msg = new Message("Có lỗi xảy ra! Vui lòng thử lại.", "error", "alert-danger");
            session.setAttribute("message", msg);
        }
        
        response.sendRedirect("contact.jsp");
    }
}