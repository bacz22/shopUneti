<%@page import="java.text.SimpleDateFormat"%>
<%@page import="entities.Contact"%>
<%@page import="java.util.List"%>
<%@page import="dao.ContactDao"%>
<%@page import="helper.ConnectionProvider"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    ContactDao contactDao = new ContactDao(ConnectionProvider.getConnection());
    List<Contact> contactList = contactDao.getAllContacts();
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<style>
    .card-header-contact {
        background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        color: white; padding: 15px 20px; border-radius: 12px 12px 0 0 !important;
    }
    .message-content {
        max-width: 300px;
        white-space: normal; /* Cho phép xuống dòng nếu dài */
        font-size: 0.95rem;
        color: #555;
    }
    
    /* Style cho Dropdown trạng thái */
    .status-select {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: 600;
        border: 1px solid #eee;
        cursor: pointer;
        text-align: center;
        width: 100%;
        min-width: 130px;
        appearance: none;
    }
    
    .st-new { background-color: #ffecd1; color: #d35400; border-color: #e67e22; }
    .st-done { background-color: #d1e7dd; color: #0f5132; border-color: #198754; }
</style>

<div class="container-fluid px-4 mt-4">
    
    <div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold text-secondary"><i class="fas fa-envelope me-2"></i>Quản lý Liên hệ</h3>
    
    <a href="ExportContactServlet" class="btn btn-success rounded-pill px-4 shadow-sm">
        <i class="fas fa-file-excel me-2"></i> Xuất Excel
    </a>
</div>

    <div class="card border-0 shadow-sm rounded-3">
        <div class="card-header card-header-contact d-flex justify-content-between align-items-center">
            <div><i class="fas fa-list me-2"></i> Hộp thư khách hàng</div>
            <span class="badge bg-white text-success"><%= contactList.size() %> tin nhắn</span>
        </div>
        
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light text-secondary text-center small text-uppercase">
                        <tr>
                            <th style="width: 5%">ID</th>
                            <th style="width: 15%">Người gửi</th>
                            <th style="width: 20%">Thông tin</th>
                            <th style="width: 35%">Nội dung</th>
                            <th style="width: 10%">Ngày gửi</th>
                            <th style="width: 15%">Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (contactList != null && !contactList.isEmpty()) {
                            for (Contact c : contactList) {
                                boolean isNew = c.getStatus().equalsIgnoreCase("Chưa xử lý");
                                String statusClass = isNew ? "st-new" : "st-done";
                        %>
                        <tr>
                            <td class="text-center fw-bold text-muted">#<%=c.getId()%></td>
                            
                            <td>
                                <div class="fw-bold text-dark"><%=c.getName()%></div>
                            </td>
                            
                            <td class="small">
                                <div><i class="fas fa-envelope text-muted me-1"></i> <%=c.getEmail()%></div>
                                <div><i class="fas fa-phone text-muted me-1"></i> <%=c.getPhone()%></div>
                            </td>
                            
                            <td>
                                <div class="message-content">
                                    <%=c.getMessage()%>
                                </div>
                            </td>
                            
                            <td class="text-center small">
                                <%= sdf.format(c.getCreatedAt()) %>
                            </td>
                            
                            <td class="text-center">
                                <form action="UpdateContactServlet" method="post" style="margin:0;">
                                    <input type="hidden" name="cid" value="<%=c.getId()%>">
                                    
                                    <select name="status" class="status-select <%=statusClass%>" onchange="this.form.submit()">
                                        <option value="Chưa xử lý" <%= isNew ? "selected" : "" %>>Chưa xử lý</option>
                                        <option value="Đã xử lý" <%= !isNew ? "selected" : "" %>>Đã xử lý</option>
                                    </select>
                                </form>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                            <tr><td colspan="6" class="text-center py-5 text-muted">Hộp thư trống!</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>