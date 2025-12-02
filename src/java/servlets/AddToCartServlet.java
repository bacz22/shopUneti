package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import dao.CartDao;
import dao.ProductDao;
import entities.Cart;
import entities.Message;
import helper.ConnectionProvider;

public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // TODO Auto-generated method stub
        int uid = Integer.parseInt(req.getParameter("uid"));
        int pid = Integer.parseInt(req.getParameter("pid"));
        // Đọc số lượng từ request (số lượng người dùng chọn)
        int requestedQty = 1;
        try {
            String qtyParam = req.getParameter("quantity");
            if (qtyParam != null && !qtyParam.trim().isEmpty()) {
                requestedQty = Integer.parseInt(qtyParam);
                if (requestedQty < 1) {
                    requestedQty = 1;
                }
            }
        } catch (NumberFormatException e) {
            requestedQty = 1;
        }

        CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
        ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());

        // Kiểm tra số lượng trong kho (chỉ kiểm tra, không trừ)
        int stockQty = productDao.getProductQuantityById(pid);
        int currentCartQty = cartDao.getQuantity(uid, pid);
        HttpSession session = req.getSession();
        Message message = null;

        // Kiểm tra số lượng có đủ không
        if (requestedQty > stockQty) {
            message = new Message("Số lượng sản phẩm trong kho không đủ! Còn " + stockQty + " sản phẩm.", "error", "alert-danger");
        } else {
            // Kiểm tra tổng số lượng trong giỏ + số lượng mới có vượt quá kho không
            int totalQtyInCart = currentCartQty + requestedQty;
            if (totalQtyInCart > stockQty) {
                message = new Message("Số lượng trong giỏ đã đạt tối đa! Còn " + stockQty + " sản phẩm trong kho.", "error", "alert-danger");
            } else {
                if (currentCartQty == 0) {
                    // Sản phẩm chưa có trong giỏ, thêm mới với số lượng đã chọn
                    Cart cart = new Cart(uid, pid, requestedQty);
                    cartDao.addToCart(cart);
                    message = new Message("Sản phẩm đã được thêm vào giỏ hàng thành công!", "success", "alert-success");

                } else {
                    // Sản phẩm đã có trong giỏ, cập nhật số lượng (cộng thêm số lượng mới)
                    int cid = cartDao.getIdByUserIdAndProductId(uid, pid);
                    cartDao.updateQuantity(cid, totalQtyInCart);
                    message = new Message("Số lượng sản phẩm đã tăng lên!", "success", "alert-success");
                }
            }
        }

        session.setAttribute("message", message);
        String page = req.getParameter("page");

        if (page != null && page.equals("products")) {
            // Nếu từ trang danh sách sản phẩm -> Quay lại danh sách
            resp.sendRedirect("products.jsp");
        } else if (page != null && page.equals("index")) {
            // Nếu từ trang chủ -> Quay lại trang chủ
            resp.sendRedirect("index.jsp");
        } else {
            // Mặc định (hoặc từ trang chi tiết) -> Quay lại trang chi tiết sản phẩm
            resp.sendRedirect("viewProduct.jsp?pid=" + pid);
        }
    }

}
