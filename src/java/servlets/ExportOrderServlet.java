/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlets;

import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import dao.OrderDao;
import dao.OrderedProductDao;
import dao.UserDao;
import entities.Order;
import entities.OrderedProduct;
import helper.ConnectionProvider;

@WebServlet("/ExportOrderServlet")
public class ExportOrderServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. KHỞI TẠO DAO & LẤY DỮ LIỆU
            OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
            OrderedProductDao ordProdDao = new OrderedProductDao(ConnectionProvider.getConnection());
            UserDao userDao = new UserDao(ConnectionProvider.getConnection());

            // Lấy toàn bộ đơn hàng (Không phân trang)
            List<Order> allOrders = orderDao.getAllOrder();

            // 2. TẠO FILE EXCEL
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Danh sách Đơn hàng");

            // --- STYLE ---
            // Header Style
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.ROYAL_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

            // Currency Style (Tiền tệ)
            CellStyle currencyStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            currencyStyle.setDataFormat(format.getFormat("#,##0 \"₫\""));

            // Date Style (Ngày tháng)
            CellStyle dateStyle = workbook.createCellStyle();
            dateStyle.setDataFormat(format.getFormat("dd/mm/yyyy hh:mm"));

            // --- HEADER ---
            Row headerRow = sheet.createRow(0);
            String[] columns = {
                "Mã Đơn", "Ngày Đặt", "Tên Khách Hàng", "Địa Chỉ / SĐT", 
                "Tên Sản Phẩm", "Số Lượng", "Đơn Giá", "Thành Tiền", 
                "PT Thanh Toán", "Trạng Thái"
            };

            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // --- BODY (Lặp qua từng đơn -> từng sản phẩm) ---
            int rowNum = 1;
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

            for (Order order : allOrders) {
                // Lấy danh sách sản phẩm của đơn này
                List<OrderedProduct> productList = ordProdDao.getAllOrderedProduct(order.getId());
                
                // Lấy thông tin User (Tận dụng hàm có sẵn trong DAO của bạn)
                String userName = userDao.getUserName(order.getUserId());
                String userAddress = userDao.getUserAddress(order.getUserId());

                for (OrderedProduct prod : productList) {
                    Row row = sheet.createRow(rowNum++);

                    // Cột 0: Mã Đơn
                    row.createCell(0).setCellValue(order.getOrderId());

                    // Cột 1: Ngày Đặt (Dùng style ngày tháng cho chuẩn Excel)
                    // Lưu ý: Nếu order.getDate() trả về String thì bạn setCellValue(string), 
                    // nếu trả về java.sql.Timestamp hoặc Date thì dùng cách dưới để sort được:
                    Cell dateCell = row.createCell(1);
                    try {
                         // Giả sử order.getDate() trả về Date hoặc Timestamp
                         dateCell.setCellValue(order.getDate()); 
                         dateCell.setCellStyle(dateStyle);
                    } catch (Exception e) {
                         // Fallback nếu là String
                         dateCell.setCellValue(String.valueOf(order.getDate()));
                    }

                    // Cột 2: Tên Khách
                    row.createCell(2).setCellValue(userName);

                    // Cột 3: Địa chỉ
                    row.createCell(3).setCellValue(userAddress);

                    // Cột 4: Tên Sản Phẩm
                    row.createCell(4).setCellValue(prod.getName());

                    // Cột 5: Số Lượng
                    row.createCell(5).setCellValue(prod.getQuantity());

                    // Cột 6: Đơn Giá
                    Cell priceCell = row.createCell(6);
                    priceCell.setCellValue(prod.getPrice());
                    priceCell.setCellStyle(currencyStyle);

                    // Cột 7: Thành Tiền (SL * Giá)
                    Cell totalCell = row.createCell(7);
                    totalCell.setCellValue(prod.getPrice() * prod.getQuantity());
                    totalCell.setCellStyle(currencyStyle);

                    // Cột 8: Thanh Toán
                    row.createCell(8).setCellValue(order.getPayementType());

                    // Cột 9: Trạng Thái
                    Cell statusCell = row.createCell(9);
                    statusCell.setCellValue(order.getStatus());
                    
                    // Tô màu chữ trạng thái nếu cần (Ví dụ Cancelled màu đỏ)
                    if("Cancelled".equalsIgnoreCase(order.getStatus())) {
                        CellStyle cancelStyle = workbook.createCellStyle();
                        Font cancelFont = workbook.createFont();
                        cancelFont.setColor(IndexedColors.RED.getIndex());
                        cancelStyle.setFont(cancelFont);
                        statusCell.setCellStyle(cancelStyle);
                    }
                }
            }

            // --- AUTO SIZE CỘT ---
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // 3. XUẤT FILE
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=DanhSachDonHang.xlsx");

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