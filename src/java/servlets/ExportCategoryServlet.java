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
import entities.Category;
import helper.ConnectionProvider;

@WebServlet("/ExportCategoryServlet")
public class ExportCategoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. LẤY DỮ LIỆU TỪ DB
            CategoryDao catDao = new CategoryDao(ConnectionProvider.getConnection());
            List<Category> list = catDao.getAllCategories();

            // 2. KHỞI TẠO WORKBOOK EXCEL
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Danh sách danh mục");

            // --- TẠO HEADER (DÒNG TIÊU ĐỀ) ---
            Row headerRow = sheet.createRow(0);
            String[] columns = {"ID", "Tên Danh Mục", "Tên File Ảnh", "Mô tả (nếu có)"};

            // Style cho Header (In đậm, nền xanh nhạt)
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            
            // Set màu nền cho header
            headerStyle.setFillForegroundColor(IndexedColors.ROYAL_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            
            // Căn giữa
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- ĐỔ DỮ LIỆU VÀO CÁC DÒNG ---
            int rowNum = 1;
            for (Category c : list) {
                Row row = sheet.createRow(rowNum++);
                
                // Cột ID
                row.createCell(0).setCellValue(c.getCategoryId());
                
                // Cột Tên
                row.createCell(1).setCellValue(c.getCategoryName());
                
                // Cột Ảnh (Chỉ xuất tên file, vì chèn ảnh vào Excel rất phức tạp và làm nặng file)
                row.createCell(2).setCellValue(c.getCategoryImage());
                
                // Cột Mô tả (Giả sử bạn có trường description, nếu không có thì bỏ dòng này)
                // row.createCell(3).setCellValue(c.getCategoryDescription()); 
                row.createCell(3).setCellValue(""); // Để trống nếu chưa có
            }

            // --- AUTO SIZE CỘT CHO ĐẸP ---
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // 3. THIẾT LẬP RESPONSE ĐỂ TẢI VỀ
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=DanhSachDanhMuc.xlsx");

            // 4. GHI RA OUTPUT STREAM
            OutputStream out = response.getOutputStream();
            workbook.write(out);
            workbook.close();
            out.close();

        } catch (Exception e) {
            e.printStackTrace();
            // Nếu lỗi thì báo ra màn hình (hoặc redirect về trang lỗi)
            response.getWriter().println("Lỗi xuất file Excel: " + e.getMessage());
        }
    }
}