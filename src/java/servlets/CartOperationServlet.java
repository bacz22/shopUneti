package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import dao.CartDao;
import dao.ProductDao;
import entities.Message;
import helper.ConnectionProvider;

public class CartOperationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		CartDao cartDao = new CartDao(ConnectionProvider.getConnection());
		ProductDao productDao = new ProductDao(ConnectionProvider.getConnection());
		int cid =Integer.parseInt(request.getParameter("cid"));
		int opt =Integer.parseInt(request.getParameter("opt"));
		
		int qty = cartDao.getQuantityById(cid);
		int pid = cartDao.getProductId(cid);
		int quantity = productDao.getProductQuantityById(pid);	
		
		if(opt == 1) {
			// Tăng số lượng trong giỏ (chỉ kiểm tra kho, không trừ)
			if(quantity > qty) {
				cartDao.updateQuantity(cid, qty+1);
				response.sendRedirect("cart.jsp");
			} else {
				HttpSession session = request.getSession();
				Message message = new Message("Sản phẩm đã hết hàng! Chỉ còn " + quantity + " sản phẩm có sẵn.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("cart.jsp");
			}
			
		}else if(opt == 2) {
			// Giảm số lượng trong giỏ (không cộng lại vào kho)
			if(qty > 1) {
				cartDao.updateQuantity(cid, qty-1);
			}
			response.sendRedirect("cart.jsp");
			
		}else if(opt == 3) {
			// Xóa sản phẩm khỏi giỏ (không cộng lại vào kho)
			cartDao.removeProduct(cid);
			HttpSession session = request.getSession();
			Message message = new Message("Sản phẩm đã được xóa khỏi giỏ hàng!", "success", "alert-success");
			session.setAttribute("message", message);
			response.sendRedirect("cart.jsp");
		}
		
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		doGet(request, response);
	}

}
