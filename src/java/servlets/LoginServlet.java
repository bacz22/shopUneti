package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

import dao.UserDao;
import dao.AdminDao;
import entities.Message;
import entities.User;
import entities.Admin;
import helper.ConnectionProvider;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        try {
            String loginType = request.getParameter("login"); // "user" hoặc "admin"
            if (loginType == null) {
                loginType = "user";
            }

            // ====================== ĐĂNG NHẬP NGƯỜI DÙNG ======================
            if ("user".equalsIgnoreCase(loginType)) {

                String userEmail = trim(request.getParameter("user_email"));
                String userPassword = request.getParameter("user_password");

                if (isBlank(userEmail) || userPassword == null || userPassword.isEmpty()) {
                    sendMessageAndRedirect(session, response, "Vui lòng nhập đầy đủ email và mật khẩu!", "error", "alert-danger", "login.jsp");
                    return;
                }

                UserDao userDao = new UserDao(ConnectionProvider.getConnection());
                
                // Sửa lại: Nên dùng hàm check cả email và pass trong DAO nếu có
                // Nhưng tạm thời giữ logic cũ của bạn cho User
                User user = userDao.getUserByEmailAndPassword(userEmail, userPassword);

                if (user != null) {
                    session.setAttribute("activeUser", user);
                    session.removeAttribute("message");
                    response.sendRedirect("index.jsp");
                } else {
                    sendMessageAndRedirect(session, response, "Email hoặc mật khẩu không đúng!", "error", "alert-danger", "login.jsp");
                }
                return;
            }

            // ====================== ĐĂNG NHẬP ADMIN (ĐÃ SỬA) ======================
            if ("admin".equalsIgnoreCase(loginType)) {

                String adminEmail = trim(request.getParameter("email")); // Form admin dùng name="email"
                String adminPassword = request.getParameter("password");

                if (isBlank(adminEmail) || adminPassword == null || adminPassword.isEmpty()) {
                    sendMessageAndRedirect(session, response, "Vui lòng nhập đầy đủ thông tin!", "error", "alert-danger", "adminlogin.jsp");
                    return;
                }

                AdminDao adminDao = new AdminDao(ConnectionProvider.getConnection());
                
                // 1. Dùng hàm kiểm tra cả Email & Password (Hàm mới thêm trong AdminDao)
                Admin admin = adminDao.getAdminByEmailAndPassword(adminEmail, adminPassword);

                if (admin != null) {
                    // 2. Lưu vào Session (Không set null password để còn hiện thị ở Profile)
                    session.setAttribute("activeAdmin", admin);
                    
                    session.removeAttribute("message");
                    response.sendRedirect("admin.jsp");
                } else {
                    sendMessageAndRedirect(session, response, "Tài khoản hoặc mật khẩu admin không đúng!", "error", "alert-danger", "adminlogin.jsp");
                }
                return;
            }

            // Nếu loginType không hợp lệ
            sendMessageAndRedirect(session, response, "Yêu cầu không hợp lệ!", "error", "alert-danger", "login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            sendMessageAndRedirect(session, response, "Đăng nhập thất bại, vui lòng thử lại sau!", "error", "alert-danger", "login.jsp");
        }
    }

    private static String trim(String value) {
        return value != null ? value.trim() : null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isEmpty();
    }

    private void sendMessageAndRedirect(HttpSession session, HttpServletResponse response,
                                        String text, String type, String cssClass, String redirect)
            throws IOException {
        session.setAttribute("message", new Message(text, type, cssClass));
        response.sendRedirect(redirect);
    }
}