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

import dao.ContactDao;
import entities.Contact;
import helper.ConnectionProvider;

@WebServlet("/ExportContactServlet")
public class ExportContactServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. LẤY DỮ LIỆU TỪ DB
            ContactDao contactDao = new ContactDao(ConnectionProvider.getConnection());
            List<Contact> contactList = contactDao.getAllContacts();

            // 2. KHỞI TẠO EXCEL
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Danh sách Liên hệ");

            // --- STYLE ---
            // Header Style (Màu Xanh Ngọc - Teal cho hợp với giao diện)
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            
            // Set nền màu Teal
            headerStyle.setFillForegroundColor(IndexedColors.TEAL.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            // Date Style
            CellStyle dateStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            dateStyle.setDataFormat(format.getFormat("dd/mm/yyyy hh:mm"));

            // Text Wrap Style (Cho cột Nội dung tin nhắn nếu dài quá)
            CellStyle wrapStyle = workbook.createCellStyle();
            wrapStyle.setWrapText(true);
            wrapStyle.setVerticalAlignment(VerticalAlignment.TOP);

            // --- HEADER ---
            Row headerRow = sheet.createRow(0);
            String[] columns = {"ID", "Người Gửi", "Email", "Số Điện Thoại", "Nội Dung Tin Nhắn", "Ngày Gửi", "Trạng Thái"};
            
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- BODY ---
            int rowNum = 1;
            for (Contact c : contactList) {
                Row row = sheet.createRow(rowNum++);

                // Cột 0: ID
                row.createCell(0).setCellValue(c.getId());
                
                // Cột 1: Tên
                row.createCell(1).setCellValue(c.getName());
                
                // Cột 2: Email
                row.createCell(2).setCellValue(c.getEmail());
                
                // Cột 3: SĐT
                row.createCell(3).setCellValue(c.getPhone());
                
                // Cột 4: Nội dung (Dùng style tự xuống dòng)
                Cell msgCell = row.createCell(4);
                msgCell.setCellValue(c.getMessage());
                msgCell.setCellStyle(wrapStyle);
                
                // Cột 5: Ngày gửi
                Cell dateCell = row.createCell(5);
                try {
                    dateCell.setCellValue(c.getCreatedAt()); // Giả sử trả về Date/Timestamp
                    dateCell.setCellStyle(dateStyle);
                } catch (Exception e) {
                    dateCell.setCellValue("");
                }
                
                // Cột 6: Trạng thái
                row.createCell(6).setCellValue(c.getStatus());
            }

            // --- AUTO SIZE CỘT ---
            // Auto size các cột trừ cột Nội dung (cột 4) vì nó có thể rất dài
            for (int i = 0; i < columns.length; i++) {
                if (i != 4) {
                    sheet.autoSizeColumn(i);
                }
            }
            // Set độ rộng cố định cho cột Nội dung (khoảng 50 ký tự)
            sheet.setColumnWidth(4, 50 * 256);

            // 3. XUẤT FILE
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=DanhSachLienHe.xlsx");

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