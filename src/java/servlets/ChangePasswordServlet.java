package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Random;
import dao.UserDao;
import entities.Message;
import entities.User;
import helper.ConnectionProvider;
import helper.MailMessenger;

public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        User activeUser = (User) session.getAttribute("activeUser");
        System.out.println(activeUser);
        // Case 1: Người dùng đã đăng nhập và đổi mật khẩu từ Profile
if (activeUser != null) {
    String currentPassword = request.getParameter("current_password");
    String newPassword = request.getParameter("new_password");

    // Loại bỏ khoảng trắng đầu/cuối ở cả 2 chuỗi trước khi so sánh
    String inputPass = currentPassword != null ? currentPassword.trim() : "";
    String dbPass = activeUser.getUserPassword() != null ? activeUser.getUserPassword().trim() : "";

    if (!inputPass.equals(dbPass)) {
        Message msg = new Message("Mật khẩu hiện tại không đúng!", "error", "alert-danger");
        session.setAttribute("message", msg);
        response.sendRedirect("profile.jsp?section=profile");
        return;
    }

    // Cập nhật mật khẩu mới (cũng nên trim để tránh lỗi lần sau)
    String cleanNewPass = newPassword != null ? newPassword.trim() : "";

    UserDao userDao = new UserDao(ConnectionProvider.getConnection());
    userDao.updateUserPasswordByEmail(cleanNewPass, activeUser.getUserEmail());

    // Đăng xuất ngay lập tức
    session.removeAttribute("activeUser");
    session.invalidate();

    // Tạo session mới để hiển thị thông báo
    session = request.getSession(true);
    Message msg = new Message("Đổi mật khẩu thành công! Vui lòng đăng nhập lại.", "success", "alert-success");
    session.setAttribute("message", msg);
    response.sendRedirect("login.jsp");
    return;
}
        String referrer = request.getHeader("referer");
        UserDao userDao = new UserDao(ConnectionProvider.getConnection());
        if (referrer.contains("forgot_password")) {
            String email = request.getParameter("email").trim();
            List<String> list = userDao.getAllEmail();
            if (list.contains(email)) {
                Random rand = new Random();
                int max = 99999, min = 10000;
                int otp = rand.nextInt(max - min + 1) + min;
                //System.out.println(otp);
                session.setAttribute("otp", otp);
                session.setAttribute("email", email);
                MailMessenger.sendOtp(email, otp);

                Message message = new Message("We'ev sent a password reset code to " + email, "success", "alert-success");
                session.setAttribute("message", message);
                response.sendRedirect("otp_code.jsp");
            } else {
                Message message = new Message("Email not found! Try with another email!", "error", "alert-danger");
                session.setAttribute("message", message);
                response.sendRedirect("forgot_password.jsp");
                return;
            }
        } else if (referrer.contains("otp_code")) {
            int code = Integer.parseInt(request.getParameter("code"));
            int otp = (int) session.getAttribute("otp");
            if (code == otp) {
                session.removeAttribute("otp");
                response.sendRedirect("change_password.jsp");
            } else {
                Message message = new Message("Invalid verification code entered!", "error", "alert-danger");
                session.setAttribute("message", message);
                response.sendRedirect("otp_code.jsp");
                return;
            }
        } else if (referrer.contains("change_password")) {
            String password = request.getParameter("password");
            String email = (String) session.getAttribute("email");
            userDao.updateUserPasswordByEmail(password, email);
            session.removeAttribute("email");

            Message message = new Message("Password updated successfully!", "error", "alert-success");
            session.setAttribute("message", message);
            response.sendRedirect("login.jsp");
        }
    }

}
