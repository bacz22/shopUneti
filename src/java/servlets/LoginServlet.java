package servlets;

import jakarta.servlet.ServletException;
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

                // Kiểm tra dữ liệu đầu vào cơ bản
                if (isBlank(userEmail) || userPassword == null || userPassword.isEmpty()) {

                    sendMessageAndRedirect(session, response,
                            "Vui lòng nhập đầy đủ email và mật khẩu!", "error", "alert-danger", "login.jsp");
                    return;
                }

                UserDao userDao = new UserDao(ConnectionProvider.getConnection());

                // Lấy user theo email
                User user = userDao.getUserByEmail(userEmail);

                // Kiểm tra user tồn tại + mật khẩu đúng (SO SÁNH PLAIN TEXT)
                if (user != null && userPassword.equals(user.getUserPassword())) {
                    user.setUserPassword(null); // tránh để mật khẩu trong session
                    session.setAttribute("activeUser", user);
                    session.removeAttribute("message"); // xóa thông báo lỗi cũ
                    response.sendRedirect("index.jsp");

                } else {
                    sendMessageAndRedirect(session, response,
                            "Email hoặc mật khẩu không đúng!", "error", "alert-danger", "login.jsp");
                }

                return;
            }

            // ====================== ĐĂNG NHẬP ADMIN ======================
            if ("admin".equalsIgnoreCase(loginType)) {

                String adminEmail = trim(request.getParameter("email"));
                String adminPassword = request.getParameter("password");

                if (isBlank(adminEmail) || adminPassword == null || adminPassword.isEmpty()) {

                    sendMessageAndRedirect(session, response,
                            "Vui lòng nhập đầy đủ thông tin!", "error", "alert-danger", "adminlogin.jsp");
                    return;
                }

                AdminDao adminDao = new AdminDao(ConnectionProvider.getConnection());
                Admin admin = adminDao.getAdminByEmail(adminEmail);

                // Đăng nhập admin với mật khẩu plain text
                if (admin != null && adminPassword.equals(admin.getPassword())) {
                    admin.setPassword(null);
                    session.setAttribute("activeAdmin", admin);
                    session.removeAttribute("message");
                    response.sendRedirect("admin.jsp");

                } else {
                    sendMessageAndRedirect(session, response,
                            "Tài khoản hoặc mật khẩu admin không đúng!", "error", "alert-danger", "adminlogin.jsp");
                }
                return;
            }

            // Nếu loginType không hợp lệ
            sendMessageAndRedirect(session, response,
                    "Yêu cầu không hợp lệ!", "error", "alert-danger", "login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            sendMessageAndRedirect(session, response,
                    "Đăng nhập thất bại, vui lòng thử lại sau!", "error", "alert-danger", "login.jsp");
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