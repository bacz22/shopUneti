package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import entities.Admin;

public class AdminDao {

    private Connection con;

    public AdminDao(Connection con) {
        super();
        this.con = con;
    }

    // 1. ĐĂNG NHẬP (QUAN TRỌNG: Hàm này bạn đang thiếu)
    public Admin getAdminByEmailAndPassword(String email, String password) {
        Admin admin = null;
        try {
            String query = "select * from admin where email=? and password=?";
            PreparedStatement pstmt = con.prepareStatement(query);
            pstmt.setString(1, email);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                admin = new Admin();
                admin.setId(rs.getInt("id"));
                admin.setName(rs.getString("name"));
                admin.setEmail(rs.getString("email"));
                admin.setPhone(rs.getString("phone"));
                admin.setPassword(rs.getString("password")); // Lấy mật khẩu để lưu vào Session
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return admin;
    }

    // 2. Lưu admin mới (Mật khẩu thường)
    public boolean saveAdmin(Admin admin) {
        boolean flag = false;
        String query = "INSERT INTO admin(name, email, password, phone) VALUES(?, ?, ?, ?)";

        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setString(1, admin.getName());
            psmt.setString(2, admin.getEmail());
            psmt.setString(3, admin.getPassword());
            psmt.setString(4, admin.getPhone());

            psmt.executeUpdate();
            flag = true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return flag;
    }

    // 3. Lấy admin theo email (Kiểm tra tồn tại)
    public Admin getAdminByEmail(String email) {
        Admin admin = null;
        String query = "SELECT * FROM admin WHERE email = ?";

        try (PreparedStatement ps = con.prepareStatement(query)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    admin = new Admin();
                    admin.setId(rs.getInt("id"));
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setPassword(rs.getString("password"));
                    admin.setPhone(rs.getString("phone"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return admin;
    }

    // 4. Lấy danh sách Admin
    public List<Admin> getAllAdmin() {
        List<Admin> list = new ArrayList<Admin>();
        try {
            String query = "select * from admin";
            Statement statement = this.con.createStatement();
            ResultSet rs = statement.executeQuery(query);
            while (rs.next()) {
                Admin admin = new Admin();
                admin.setId(rs.getInt("id"));
                admin.setName(rs.getString("name"));
                admin.setEmail(rs.getString("email"));
                admin.setPhone(rs.getString("phone"));
                admin.setPassword(rs.getString("password"));

                list.add(admin);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Xóa Admin
    public boolean deleteAdmin(int id) {
        boolean flag = false;
        try {
            String query = "delete from admin where id = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setInt(1, id);
            psmt.executeUpdate();
            flag = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return flag;
    }

    // 6. Cập nhật thông tin Admin
    public boolean updateAdmin(Admin admin) {
        boolean f = false;
        try {
            String query = "update admin set name=?, email=?, password=?, phone=? where id=?";
            PreparedStatement p = this.con.prepareStatement(query);
            p.setString(1, admin.getName());
            p.setString(2, admin.getEmail());
            p.setString(3, admin.getPassword());
            p.setString(4, admin.getPhone());
            p.setInt(5, admin.getId());

            p.executeUpdate();
            f = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return f;
    }
}