package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import entities.Contact;

public class ContactDao {
    private Connection con;

    public ContactDao(Connection con) {
        this.con = con;
    }

    public boolean saveContact(Contact contact) {
        boolean f = false;
        try {
            String query = "INSERT INTO contact(name, email, phone, message, status) VALUES(?,?,?,?,?)";
            PreparedStatement p = this.con.prepareStatement(query);
            p.setString(1, contact.getName());
            p.setString(2, contact.getEmail());
            p.setString(3, contact.getPhone());
            p.setString(4, contact.getMessage());
            p.setString(5, "Chưa xử lý");

            p.executeUpdate();
            f = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }
    // Lấy tất cả liên hệ (Sắp xếp mới nhất lên đầu)
    public java.util.List<entities.Contact> getAllContacts() {
        java.util.List<entities.Contact> list = new java.util.ArrayList<>();
        try {
            String query = "SELECT * FROM contact ORDER BY id DESC";
            java.sql.Statement stmt = this.con.createStatement();
            java.sql.ResultSet rs = stmt.executeQuery(query);
            
            while (rs.next()) {
                entities.Contact contact = new entities.Contact();
                contact.setId(rs.getInt("id"));
                contact.setName(rs.getString("name"));
                contact.setEmail(rs.getString("email"));
                contact.setPhone(rs.getString("phone"));
                contact.setMessage(rs.getString("message"));
                contact.setStatus(rs.getString("status"));
                contact.setCreatedAt(rs.getTimestamp("created_at"));
                
                list.add(contact);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // Cập nhật trạng thái liên hệ
    public boolean updateContactStatus(int id, String status) {
        boolean f = false;
        try {
            String query = "UPDATE contact SET status = ? WHERE id = ?";
            java.sql.PreparedStatement p = this.con.prepareStatement(query);
            p.setString(1, status);
            p.setInt(2, id);
            
            p.executeUpdate();
            f = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }
}