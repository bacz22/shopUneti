<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="entities.OrderedProduct"%>
<%@page import="java.util.List"%>
<%@page import="dao.OrderedProductDao"%>
<%@page import="helper.ConnectionProvider"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %> <%-- DÒNG MỚI: Xóa khoảng trắng thừa --%>

<%
    String orderIdStr = request.getParameter("orderId");
    if(orderIdStr != null){
        int oid = Integer.parseInt(orderIdStr);
        OrderedProductDao dao = new OrderedProductDao(ConnectionProvider.getConnection());
        List<OrderedProduct> list = dao.getAllOrderedProduct(oid);
        
        NumberFormat fmt = NumberFormat.getInstance(new Locale("vi", "VN"));
        long grandTotal = 0;
        int count = 1;

        for(OrderedProduct p : list){
            long total = (long)p.getPrice() * p.getQuantity();
            grandTotal += total;
%>
        <tr>
            <td class="text-center"><%= count++ %></td>
            <td>
                <div class="fw-bold"><%= p.getName() %></div>
            </td>
            <td class="text-center"><%= p.getQuantity() %></td>
            <td class="text-end"><%= fmt.format(p.getPrice()) %> ₫</td>
            <td class="text-end fw-bold text-primary"><%= fmt.format(total) %> ₫</td>
        </tr>
<%      } %>
        
        <tr class="table-light">
            <td colspan="4" class="text-end fw-bold text-uppercase">Tổng cộng:</td>
            <td class="text-end fw-bold text-danger fs-5"><%= fmt.format(grandTotal) %> ₫</td>
        </tr>

        <tr class="no-print border-0 bg-white">
            <td colspan="5" class="text-center pt-4 pb-2">
                <button type="button" class="btn btn-danger px-4 rounded-pill shadow-sm" 
                        onclick="confirmExport('<%= request.getParameter("orderId") %>')">
                    <i class="fas fa-file-pdf me-2"></i>Tải Hóa Đơn PDF
                </button>
            </td>
        </tr>
<%  } %>