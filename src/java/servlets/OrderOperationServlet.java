package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import dao.CartDao;
import dao.OrderDao;
import dao.OrderedProductDao;
import dao.ProductDao;
import entities.Cart;
import entities.Order;
import entities.OrderedProduct;
import entities.Product;
import entities.User;
import helper.ConnectionProvider;
import helper.MailMessenger;
import helper.OrderIdGenerator;

public class OrderOperationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String from = (String) session.getAttribute("from");
        String paymentType = request.getParameter("payementMode");
        User user = (User) session.getAttribute("activeUser");
        String orderId = OrderIdGenerator.getOrderId();
        String status = "Order Placed";

        if (from.trim().equals("cart")) {
            try {

                Order order = new Order(orderId, status, paymentType, user.getUserId());
                OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
                int id = orderDao.insertOrder(order);

                CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
                List<Cart> listOfCart = cartDao.getCartListByUserId(user.getUserId());
                OrderedProductDao orderedProductDao = new OrderedProductDao(ConnectionProvider.getConnection());
                ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
                
                for (Cart item : listOfCart) {

                    Product prod = productDao.getProductsByProductId(item.getProductId());
                    String prodName = prod.getProductName();
                    int prodQty = item.getQuantity();
                    // Lưu ý: Chuyển float sang String nếu Entity của bạn lưu Price là String
                    float price = prod.getProductPriceAfterDiscount();
                    String image = prod.getProductImages();
                    
                    // --- SỬA Ở ĐÂY: Thêm tham số cuối cùng là item.getProductId() ---
                    OrderedProduct orderedProduct = new OrderedProduct(0, prodName, prodQty, price, image, id, item.getProductId());
                    orderedProductDao.insertOrderedProduct(orderedProduct);
                    
                    // Trừ số lượng trong kho khi đặt hàng
                    int currentStock = productDao.getProductQuantityById(item.getProductId());
                    int newStock = currentStock - prodQty;
                    if (newStock < 0) newStock = 0;
                    productDao.updateQuantity(item.getProductId(), newStock);
                }
                session.removeAttribute("from");
                session.removeAttribute("totalPrice");
                
                //removing all product from cart after successful order
                cartDao.removeAllProduct();

            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (from.trim().equals("buy")) {

            try {

                int pid = (int) session.getAttribute("pid");
                // Đọc số lượng từ session (mặc định là 1 nếu không có)
                int prodQty = 1;
                if (session.getAttribute("buyQuantity") != null) {
                    prodQty = (int) session.getAttribute("buyQuantity");
                }
                
                Order order = new Order(orderId, status, paymentType, user.getUserId());
                OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
                int id = orderDao.insertOrder(order);
                OrderedProductDao orderedProductDao = new OrderedProductDao(ConnectionProvider.getConnection());
                ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());

                Product prod = productDao.getProductsByProductId(pid);
                String prodName = prod.getProductName();
                float price = prod.getProductPriceAfterDiscount();
                String image = prod.getProductImages();

                // --- SỬA Ở ĐÂY: Thêm tham số cuối cùng là pid ---
                OrderedProduct orderedProduct = new OrderedProduct(0, prodName, prodQty, price, image, id, pid);
                orderedProductDao.insertOrderedProduct(orderedProduct);
                
                // Trừ số lượng trong kho khi đặt hàng
                int currentStock = productDao.getProductQuantityById(pid);
                int newStock = currentStock - prodQty;
                if (newStock < 0) newStock = 0;
                productDao.updateQuantity(pid, newStock);
                
                session.removeAttribute("from");
                session.removeAttribute("pid");
                session.removeAttribute("buyQuantity");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        session.setAttribute("order", "success");
        // Gửi mail (nếu cấu hình mail chưa chuẩn thì có thể comment dòng dưới lại để tránh lỗi)
        try {
            MailMessenger.successfullyOrderPlaced(user.getUserName(), user.getUserEmail(), orderId, new Date().toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        response.sendRedirect("index.jsp");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

}