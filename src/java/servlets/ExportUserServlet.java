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

import dao.UserDao;
import entities.User;
import helper.ConnectionProvider;

@WebServlet("/ExportUserServlet")
public class ExportUserServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. LẤY DỮ LIỆU
            UserDao userDao = new UserDao(ConnectionProvider.getConnection());
            List<User> userList = userDao.getAllUser();

            // 2. KHỞI TẠO EXCEL
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Danh sách Khách hàng");

            // --- STYLE ---
            // Header Style (Màu Tím cho hợp với giao diện JSP của bạn)
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            
            // Set màu nền tím
            headerStyle.setFillForegroundColor(IndexedColors.VIOLET.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            // Date Style (Định dạng ngày tháng)
            CellStyle dateStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            dateStyle.setDataFormat(format.getFormat("dd/mm/yyyy"));

            // --- HEADER ---
            Row headerRow = sheet.createRow(0);
            String[] columns = {"ID", "Họ và Tên", "Email", "Số điện thoại", "Giới tính", "Địa chỉ", "Ngày đăng ký"};
            
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- BODY ---
            int rowNum = 1;
            for (User u : userList) {
                Row row = sheet.createRow(rowNum++);

                // Cột 0: ID
                row.createCell(0).setCellValue(u.getUserId());
                
                // Cột 1: Tên
                row.createCell(1).setCellValue(u.getUserName());
                
                // Cột 2: Email
                row.createCell(2).setCellValue(u.getUserEmail());
                
                // Cột 3: SĐT
                row.createCell(3).setCellValue(u.getUserPhone());
                
                // Cột 4: Giới tính (Chuẩn hóa Tiếng Việt)
                String gender = u.getUserGender();
                if(gender != null) {
                    if(gender.equalsIgnoreCase("Male")) gender = "Nam";
                    else if(gender.equalsIgnoreCase("Female")) gender = "Nữ";
                } else {
                    gender = "Khác";
                }
                row.createCell(4).setCellValue(gender);
                
                // Cột 5: Địa chỉ (Xử lý null)
                String address = u.getUserAddress();
                row.createCell(5).setCellValue((address == null || address.isEmpty()) ? "Chưa cập nhật" : address);
                
                // Cột 6: Ngày đăng ký
                Cell dateCell = row.createCell(6);
                try {
                    // Nếu entity trả về Timestamp/Date
                    dateCell.setCellValue(u.getDateTime());
                    dateCell.setCellStyle(dateStyle);
                } catch (Exception e) {
                    // Fallback nếu trả về String hoặc null
                    dateCell.setCellValue("");
                }
            }

            // --- AUTO SIZE CỘT ---
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // 3. XUẤT FILE
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=DanhSachKhachHang.xlsx");

            OutputStream out = response.getOutputStream();
            workbook.write(out);
            workbook.close();
            out.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi xuất Excel: " + e.getMessage());
        }
    }
}