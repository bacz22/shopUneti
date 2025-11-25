/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlets;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import dao.CategoryDao;
import dao.ProductDao;
import entities.Category;
import entities.Product;
import helper.ConnectionProvider;

@WebServlet("/ExportProductServlet")
public class ExportProductServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. LẤY DỮ LIỆU TỪ DB
            ProductDao pDao = new ProductDao(ConnectionProvider.getConnection());
            CategoryDao cDao = new CategoryDao(ConnectionProvider.getConnection());
            
            List<Product> productList = pDao.getAllProducts();
            List<Category> categoryList = cDao.getAllCategories();

            // 2. KHỞI TẠO EXCEL
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Danh sách sản phẩm");

            // --- STYLE ---
            // Style cho Header
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_GREEN.getIndex()); // Màu xanh lá đậm
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            // Style cho Tiền tệ (Để hiển thị dạng 100,000 ₫ nhưng vẫn tính toán được)
            CellStyle currencyStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            currencyStyle.setDataFormat(format.getFormat("#,##0 \"₫\"")); // Format số kèm chữ đ

            // --- HEADER ---
            Row headerRow = sheet.createRow(0);
            String[] columns = {"ID", "Tên Sản Phẩm", "Danh Mục", "Giá Gốc", "Giảm Giá (%)", "Giá Sau Giảm", "Số Lượng", "Tên Ảnh"};
            
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- BODY ---
            int rowNum = 1;
            for (Product p : productList) {
                Row row = sheet.createRow(rowNum++);

                // Tìm tên danh mục từ List Category
                String categoryName = "Khác";
                for (Category c : categoryList) {
                    if (c.getCategoryId() == p.getCategoryId()) {
                        categoryName = c.getCategoryName();
                        break;
                    }
                }

                // Cột 0: ID
                row.createCell(0).setCellValue(p.getProductId());
                
                // Cột 1: Tên
                row.createCell(1).setCellValue(p.getProductName());
                
                // Cột 2: Danh mục
                row.createCell(2).setCellValue(categoryName);
                
                // Cột 3: Giá gốc (Dùng style tiền tệ)
                Cell priceCell = row.createCell(3);
                priceCell.setCellValue(p.getProductPrice());
                priceCell.setCellStyle(currencyStyle);
                
                // Cột 4: Giảm giá
                row.createCell(4).setCellValue(p.getProductDiscount());
                
                // Cột 5: Giá sau giảm (Công thức hoặc tính sẵn)
                Cell finalPriceCell = row.createCell(5);
                finalPriceCell.setCellValue(p.getProductPriceAfterDiscount());
                finalPriceCell.setCellStyle(currencyStyle);
                
                // Cột 6: Số lượng
                row.createCell(6).setCellValue(p.getProductQunatity());
                
                // Cột 7: Tên ảnh
                row.createCell(7).setCellValue(p.getProductImages());
            }

            // --- AUTO SIZE CỘT ---
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // 3. XUẤT FILE
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=DanhSachSanPham.xlsx");

            OutputStream out = response.getOutputStream();
            workbook.write(out);
            workbook.close();
            out.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi: " + e.getMessage());
        }
    }
}