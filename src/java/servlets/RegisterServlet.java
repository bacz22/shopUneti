package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.regex.Pattern;

import dao.UserDao;
import entities.Message;
import entities.User;
import helper.ConnectionProvider;
import helper.MailMessenger;

public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\d{9,11}$");

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        try {
            String userName = trimParam(request.getParameter("user_name"));
            String userEmail = trimParam(request.getParameter("user_email"));
            String userPassword = request.getParameter("user_password");
            String userPasswordConfirm = request.getParameter("user_password_confirm");
            String userPhone = trimParam(request.getParameter("user_mobile_no"));
            String userGender = trimParam(request.getParameter("gender"));
            String userAddress = trimParam(request.getParameter("user_address"));
            String userCity = trimParam(request.getParameter("city"));

            // Validate required fields
            if (isBlank(userName) || isBlank(userEmail) || isBlank(userPassword) || isBlank(userGender)
                    || isBlank(userAddress) || isBlank(userCity)) {

                sendMessageAndRedirect(session, response,
                        "Vui lòng điền đầy đủ các thông tin bắt buộc!",
                        "error", "alert-danger", "register.jsp");
                return;
            }

            if (!EMAIL_PATTERN.matcher(userEmail).matches()) {
                sendMessageAndRedirect(session, response,
                        "Địa chỉ email không hợp lệ!", "error", "alert-danger", "register.jsp");
                return;
            }

            if (userPassword.length() < 6) {
                sendMessageAndRedirect(session, response,
                        "Mật khẩu phải có ít nhất 6 ký tự!", "error", "alert-danger", "register.jsp");
                return;
            }

            if (userPasswordConfirm == null || !userPassword.equals(userPasswordConfirm)) {
                sendMessageAndRedirect(session, response,
                        "Mật khẩu nhập lại chưa khớp!", "error", "alert-danger", "register.jsp");
                return;
            }

            if (!isBlank(userPhone) && !PHONE_PATTERN.matcher(userPhone).matches()) {
                sendMessageAndRedirect(session, response,
                        "Số điện thoại phải từ 9-11 chữ số!", "error", "alert-danger", "register.jsp");
                return;
            }

            User user = new User(userName, userEmail, userPassword, userPhone, userGender, userAddress, userCity);
            UserDao userDao = new UserDao(ConnectionProvider.getConnection());
            boolean flag = userDao.saveUser(user);

            if (flag) {
                Message message = new Message("Đăng ký thành công! Vui lòng đăng nhập.", "success", "alert-success");
                session.setAttribute("message", message);
                MailMessenger.successfullyRegister(userName, userEmail);
                response.sendRedirect("login.jsp");
                return;
            }

            String errorMsg = "Có lỗi xảy ra! Hãy thử lại!!";

            if (userDao.isEmailExist(userEmail)) {
                errorMsg = "Email này đã được sử dụng! Vui lòng dùng email khác.";
            } else if (!isBlank(userPhone) && userDao.isPhoneExist(userPhone)) {
                errorMsg = "Số điện thoại này đã được đăng ký! Vui lòng dùng số khác.";
            }

            sendMessageAndRedirect(session, response, errorMsg, "error", "alert-danger", "register.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            sendMessageAndRedirect(session, response,
                    "Hệ thống đang bận, vui lòng thử lại sau!", "error", "alert-danger", "register.jsp");
        }

    }

    private static String trimParam(String value) {
        return value != null ? value.trim() : null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void sendMessageAndRedirect(HttpSession session, HttpServletResponse response,
                                        String text, String type, String cssClass, String redirect)
            throws IOException {
        session.setAttribute("message", new Message(text, type, cssClass));
        response.sendRedirect(redirect);
    }
}



