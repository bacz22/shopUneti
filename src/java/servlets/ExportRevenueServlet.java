/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlets;

import java.io.IOException;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import dao.OrderDao;
import dao.OrderedProductDao;
import entities.Order;
import entities.OrderedProduct;
import helper.ConnectionProvider;

@WebServlet("/ExportRevenueServlet")
public class ExportRevenueServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // 1. LẤY DỮ LIỆU (Tương tự như trong JSP)
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date startDate = (startDateStr == null || startDateStr.isEmpty()) ? new Date() : sdf.parse(startDateStr);
            Date endDate = (endDateStr == null || endDateStr.isEmpty()) ? new Date() : sdf.parse(endDateStr);

            // Gọi DAO
            OrderDao orderDao = new OrderDao(ConnectionProvider.getConnection());
            OrderedProductDao ordProdDao = new OrderedProductDao(ConnectionProvider.getConnection());
            List<Order> allOrders = orderDao.getAllOrder();

            // 2. TẠO FILE EXCEL (WORKBOOK)
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Báo cáo doanh thu");

            // Tạo Header (Dòng tiêu đề)
            Row headerRow = sheet.createRow(0);
            String[] columns = {"Mã ĐH", "Ngày đặt", "Trạng thái", "Số lượng SP", "Tổng tiền (VNĐ)"};
            
            // Style cho Header (In đậm)
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // 3. ĐỔ DỮ LIỆU VÀO CÁC DÒNG
            int rowNum = 1;
            double totalRevenue = 0;

            for (Order order : allOrders) {
                // Logic lọc ngày (Copy logic từ JSP)
                String orderDateStr = sdf.format(order.getDate());
                Date orderDate = sdf.parse(orderDateStr);

                if (orderDate.compareTo(startDate) >= 0 && orderDate.compareTo(endDate) <= 0) {
                    
                    // Tính tổng tiền đơn hàng
                    double orderTotal = 0;
                    List<OrderedProduct> products = ordProdDao.getAllOrderedProduct(order.getId());
                    for(OrderedProduct p : products) {
                        orderTotal += p.getPrice() * p.getQuantity();
                    }

                    // Ghi vào dòng Excel
                    Row row = sheet.createRow(rowNum++);
                    row.createCell(0).setCellValue(order.getOrderId()); // Hoặc order.getId() tùy DB của bạn
                    row.createCell(1).setCellValue(orderDateStr);
                    row.createCell(2).setCellValue(order.getStatus());
                    row.createCell(3).setCellValue(products.size());
                    row.createCell(4).setCellValue(orderTotal);

                    // Nếu đơn thành công thì cộng tổng doanh thu
                    if ("Delivered".equalsIgnoreCase(order.getStatus())) {
                        totalRevenue += orderTotal;
                    }
                }
            }

            // Thêm 1 dòng Tổng cộng ở cuối
            Row totalRow = sheet.createRow(rowNum + 1);
            totalRow.createCell(3).setCellValue("TỔNG DOANH THU THỰC TẾ:");
            Cell totalCell = totalRow.createCell(4);
            totalCell.setCellValue(totalRevenue);
            
            // Style cho dòng tổng (Màu đỏ, in đậm)
            CellStyle totalStyle = workbook.createCellStyle();
            Font totalFont = workbook.createFont();
            totalFont.setColor(IndexedColors.RED.getIndex());
            totalFont.setBold(true);
            totalStyle.setFont(totalFont);
            totalCell.setCellStyle(totalStyle);

            // Tự động giãn cột cho đẹp
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // 4. THIẾT LẬP RESPONSE ĐỂ TRÌNH DUYỆT TẢI VỀ
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=BaoCaoDoanhThu_" + startDateStr + "_to_" + endDateStr + ".xlsx");

            // Ghi dữ liệu ra luồng output
            OutputStream out = response.getOutputStream();
            workbook.write(out);
            workbook.close();
            out.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Lỗi xuất file Excel: " + e.getMessage());
        }
    }
}