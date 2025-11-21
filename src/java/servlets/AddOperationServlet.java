package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import dao.CategoryDao;
import dao.ProductDao;
import entities.Category;
import entities.Message;
import entities.Product;
import helper.ConnectionProvider;

@MultipartConfig
public class AddOperationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đặt encoding để xử lý tiếng Việt
        request.setCharacterEncoding("UTF-8");

        String operation = request.getParameter("operation");
        CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
        ProductDao pdao = new ProductDao(ConnectionProvider.getConnection());
        HttpSession session = request.getSession();
        Message message = null;

        try {
            // ==========================================
            // 1. ADD CATEGORY
            // ==========================================
            if (operation.trim().equals("addCategory")) {

                String categoryName = request.getParameter("category_name");
                Part part = request.getPart("category_img");
                
                String imgName = "default.png";
                if(part != null && part.getSize() > 0) {
                    imgName = part.getSubmittedFileName();
                }

                Category category = new Category(categoryName, imgName);
                boolean flag = catDao.saveCategory(category);

                if(part != null && part.getSize() > 0) {
                    String path = request.getServletContext().getRealPath("/") + "Images" + File.separator + imgName;
                    saveFile(part.getInputStream(), path);
                }

                if (flag) {
                    message = new Message("Thêm danh mục thành công!", "success", "alert-success");
                } else {
                    message = new Message("Lỗi! Không thể thêm danh mục.", "error", "alert-danger");
                }
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=category");

            // ==========================================
            // 2. ADD PRODUCT
            // ==========================================
            } else if (operation.trim().equals("addProduct")) {

                // Lấy dữ liệu từ form (Chú ý: name phải khớp với file add_product_modal.jsp)
                // Nếu bạn dùng form cũ thì là "name", form mới mình gửi là "pName"
                // Code này hỗ trợ cả 2 trường hợp (ưu tiên form mới)
                String pName = request.getParameter("pName") != null ? request.getParameter("pName") : request.getParameter("name");
                String pDesc = request.getParameter("pDesc") != null ? request.getParameter("pDesc") : request.getParameter("description");
                
                // Xử lý giá (tránh lỗi null)
                int pPrice = 0;
                String priceStr = request.getParameter("pPrice") != null ? request.getParameter("pPrice") : request.getParameter("price");
                if(priceStr != null && !priceStr.isEmpty()) pPrice = Integer.parseInt(priceStr);

                int pDiscount = 0;
                String discStr = request.getParameter("pDiscount") != null ? request.getParameter("pDiscount") : request.getParameter("discount");
                if(discStr != null && !discStr.isEmpty()) pDiscount = Integer.parseInt(discStr);
                
                int pQuantity = 0;
                String qtyStr = request.getParameter("pQuantity") != null ? request.getParameter("pQuantity") : request.getParameter("quantity");
                if(qtyStr != null && !qtyStr.isEmpty()) pQuantity = Integer.parseInt(qtyStr);

                int catId = 0;
                String catStr = request.getParameter("catId") != null ? request.getParameter("catId") : request.getParameter("categoryType");
                if(catStr != null && !catStr.isEmpty()) catId = Integer.parseInt(catStr);
                
                Part part = request.getPart("pPic");
                if(part == null) part = request.getPart("photo");

                String imgName = "default.png";
                if(part != null) imgName = part.getSubmittedFileName();

                Product product = new Product(pName, pDesc, pPrice, pDiscount, pQuantity, imgName, catId);
                boolean flag = pdao.saveProduct(product);

                if(part != null && part.getSize() > 0) {
                    String path = request.getServletContext().getRealPath("/") + "Images" + File.separator + imgName;
                    saveFile(part.getInputStream(), path);
                }

                if (flag) {
                    message = new Message("Thêm sản phẩm thành công!", "success", "alert-success");
                } else {
                    message = new Message("Lỗi hệ thống!", "error", "alert-danger");
                }
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=products");

            // ==========================================
            // 3. UPDATE CATEGORY
            // ==========================================
            } else if (operation.trim().equals("updateCategory")) {

                int cid = Integer.parseInt(request.getParameter("cid"));
                String name = request.getParameter("category_name"); // Hoặc "catTitle" tùy form
                if(name == null) name = request.getParameter("catTitle");
                
                Part part = request.getPart("category_img"); // Hoặc "catImage"
                if(part == null) part = request.getPart("catImage");
                
                String imageName;
                if (part != null && part.getSize() > 0) {
                    imageName = part.getSubmittedFileName();
                    String path = request.getServletContext().getRealPath("/") + "Images" + File.separator + imageName;
                    saveFile(part.getInputStream(), path);
                } else {
                    imageName = request.getParameter("image");
                    if(imageName == null) imageName = request.getParameter("oldImage");
                }
                
                Category category = new Category(cid, name, imageName);
                catDao.updateCategory(category);

                message = new Message("Cập nhật danh mục thành công!", "success", "alert-success");
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=category");

            // ==========================================
            // 4. DELETE CATEGORY
            // ==========================================
            } else if (operation.trim().equals("deleteCategory")) {

                int cid = Integer.parseInt(request.getParameter("cid"));
                boolean deleted = catDao.deleteCategory(cid);
                if (deleted) {
                    message = new Message("Xóa danh mục thành công!", "success", "alert-success");
                } else {
                    message = new Message("Không thể xóa! Hãy xóa sản phẩm liên quan trước.", "error", "alert-danger");
                }
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=category");

            // ==========================================
            // 5. UPDATE PRODUCT (FIXED NULL POINTER)
            // ==========================================
            } else if (operation.trim().equals("updateProduct")) {

                // Lấy ID (Bắt buộc)
                String pidStr = request.getParameter("pid");
                if(pidStr == null) throw new Exception("Product ID is missing");
                int pid = Integer.parseInt(pidStr);

                // Lấy các thông tin khác (Form Modal mới dùng pName, pPrice...)
                String name = request.getParameter("pName");
                
                // Xử lý giá (float)
                float price = 0;
                String pStr = request.getParameter("pPrice");
                if (pStr != null && !pStr.trim().isEmpty()) {
                    price = Float.parseFloat(pStr.trim());
                }

                String description = request.getParameter("pDesc");
                String specifications = request.getParameter("specifications");
                
                // Xử lý số lượng
                int quantity = 0;
                String qStr = request.getParameter("pQuantity");
                if (qStr != null && !qStr.trim().isEmpty()) quantity = Integer.parseInt(qStr.trim());

                // Xử lý giảm giá
                int discount = 0;
                String dStr = request.getParameter("pDiscount");
                if (dStr != null && !dStr.trim().isEmpty()) discount = Integer.parseInt(dStr.trim());

                // Xử lý danh mục
                int cid = 0;
                String cStr = request.getParameter("catId");
                if (cStr != null && !cStr.trim().isEmpty()) cid = Integer.parseInt(cStr.trim());
                
                // Xử lý ảnh
                Part part = request.getPart("pPic");
                String imageName = "";
                
                if (part != null && part.getSize() > 0) {
                    imageName = part.getSubmittedFileName();
                    String path = request.getServletContext().getRealPath("/") + "Images" + File.separator + imageName;
                    saveFile(part.getInputStream(), path);
                } else {
                    imageName = request.getParameter("oldImage");
                }

                // Tạo đối tượng và update
                Product product = new Product(pid, name, description, price, discount, quantity, imageName, cid, specifications);
                pdao.updateProduct(product);

                message = new Message("Cập nhật sản phẩm thành công!", "success", "alert-success");
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=products");

            // ==========================================
            // 6. DELETE PRODUCT
            // ==========================================
            } else if (operation.trim().equals("deleteProduct")) {

                int pid = Integer.parseInt(request.getParameter("pid"));
                pdao.deleteProduct(pid);
                
                message = new Message("Xóa sản phẩm thành công!", "success", "alert-success");
                session.setAttribute("message", message);
                response.sendRedirect("admin.jsp?page=products");
            // ==========================================
        // 7. CẬP NHẬT PROFILE ADMIN (UPDATE ADMIN)
        // ==========================================
        } else if (operation.trim().equals("updateAdmin")) {
            
            try {
                int id = Integer.parseInt(request.getParameter("aid"));
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String password = request.getParameter("password");

                // Tạo đối tượng Admin mới với thông tin cập nhật
                // (Lưu ý: Bạn cần kiểm tra Constructor của class Admin xem thứ tự tham số đúng chưa)
                entities.Admin admin = new entities.Admin(id, name, email, password, phone);
                
                // Gọi DAO update
                dao.AdminDao adminDao = new dao.AdminDao(ConnectionProvider.getConnection());
                boolean ans = adminDao.updateAdmin(admin);

                if (ans) {
                    message = new Message("Cập nhật hồ sơ thành công!", "success", "alert-success");
                    // QUAN TRỌNG: Cập nhật lại session để hiển thị thông tin mới ngay lập tức
                    session.setAttribute("activeAdmin", admin);
                } else {
                    message = new Message("Lỗi cập nhật! Vui lòng thử lại.", "error", "alert-danger");
                }
            } catch (Exception e) {
                e.printStackTrace();
                message = new Message("Lỗi hệ thống: " + e.getMessage(), "error", "alert-danger");
            }
            
            session.setAttribute("message", message);
            response.sendRedirect("admin.jsp?page=profile");
        }

        } catch (Exception e) {
            e.printStackTrace();
            message = new Message("Lỗi hệ thống: " + e.getMessage(), "error", "alert-danger");
            session.setAttribute("message", message);
            // Quay về trang chủ admin nếu lỗi nặng
            response.sendRedirect("admin.jsp");
        }
    }

    // Hàm lưu file gọn gàng
    private void saveFile(InputStream is, String path) throws IOException {
        byte[] data = new byte[is.available()];
        is.read(data);
        try (FileOutputStream fos = new FileOutputStream(path)) {
            fos.write(data);
            fos.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }
}