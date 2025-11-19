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
	
	// 1. Lưu admin mới → lưu mật khẩu PLAIN TEXT (theo yêu cầu)
    public boolean saveAdmin(Admin admin) {
        boolean flag = false;
        String query = "INSERT INTO admin(name, email, password, phone) VALUES(?, ?, ?, ?)";

        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setString(1, admin.getName());
            psmt.setString(2, admin.getEmail());

            // LƯU TRỰC TIẾP MẬT KHẨU (không mã hóa)
            psmt.setString(3, admin.getPassword());

            psmt.setString(4, admin.getPhone());

            psmt.executeUpdate();
            flag = true;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return flag;
    }
	// 2. Lấy admin theo email (dùng để đăng nhập)
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
                    admin.setPassword(rs.getString("password")); // đã được hash
                    admin.setPhone(rs.getString("phone"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return admin;
    }
    // Không còn dùng BCrypt: có thể bỏ method này nếu không cần
	public List<Admin> getAllAdmin(){
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
}
