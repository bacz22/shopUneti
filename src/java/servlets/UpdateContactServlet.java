package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.ContactDao;
import helper.ConnectionProvider;

@WebServlet("/UpdateContactServlet")
public class UpdateContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("cid"));
            String status = request.getParameter("status");
            
            ContactDao dao = new ContactDao(ConnectionProvider.getConnection());
            dao.updateContactStatus(id, status);
            
            // Quay lại trang quản lý liên hệ
            response.sendRedirect("admin.jsp?page=contacts");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?page=contacts");
        }
    }
}