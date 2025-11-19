package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import entities.User;

public class UserDao {

    private Connection con;

    public UserDao(Connection con) {
        super();
        this.con = con;
    }

    // 1. Đăng ký user mới - lưu mật khẩu dạng plain text (THEO YÊU CẦU)
    public boolean saveUser(User user) {
        // 1. Kiểm tra email trùng
        if (isEmailExist(user.getUserEmail())) {
            return false; // trả false → servlet sẽ báo lỗi
        }

        // 2. Kiểm tra số điện thoại trùng (nếu có nhập)
        if (user.getUserPhone() != null && !user.getUserPhone().trim().isEmpty()) {
            if (isPhoneExist(user.getUserPhone())) {
                return false;
            }
        }

        // 3. Nếu ok thì mới insert
        String query = "INSERT INTO user(name, email, password, phone, gender, address, city) " +
                       "VALUES(?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setString(1, user.getUserName());
            psmt.setString(2, user.getUserEmail());
            // LƯU THẲNG MẬT KHẨU KHÔNG MÃ HÓA
            psmt.setString(3, user.getUserPassword());
            psmt.setString(4, user.getUserPhone());
            psmt.setString(5, user.getUserGender());
            psmt.setString(6, user.getUserAddress());
            psmt.setString(7, user.getUserCity());

            int rows = psmt.executeUpdate();
            return rows > 0; // thành công nếu insert được ít nhất 1 dòng

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. Login
    // THÊM method mới
public User getUserByEmail(String email) {
    User user = null;
    String query = "SELECT * FROM user WHERE email = ?";

    try (PreparedStatement ps = con.prepareStatement(query)) {
        ps.setString(1, email);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("userid"));
                user.setUserName(rs.getString("name"));
                user.setUserEmail(rs.getString("email"));
                user.setUserPassword(rs.getString("password")); // đã hash
                user.setUserPhone(rs.getString("phone"));
                user.setUserGender(rs.getString("gender"));
                user.setUserAddress(rs.getString("address"));
                user.setUserCity(rs.getString("city"));
                user.setDateTime(rs.getTimestamp("registerdate"));
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return user;
}

    public List<User> getAllUser() {
        List<User> list = new ArrayList<User>();
        try {
            String query = "select * from user";
            Statement statement = this.con.createStatement();
            ResultSet set = statement.executeQuery(query);
            while (set.next()) {
                User user = new User();
                user.setUserId(set.getInt("userid"));
                user.setUserName(set.getString("name"));
                user.setUserEmail(set.getString("email"));
                user.setUserPassword(set.getString("password"));
                user.setUserPhone(set.getString("phone"));
                user.setUserGender(set.getString("gender"));
                user.setDateTime(set.getTimestamp("registerdate"));
                user.setUserAddress(set.getString("address"));
                user.setUserCity(set.getString("city"));

                list.add(user);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Cập nhật địa chỉ riêng (nếu cần)
    public void updateUserAddress(User user) {
        String query = "UPDATE user SET address = ?, city = ? WHERE userid = ?";

        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setString(1, user.getUserAddress());
            psmt.setString(2, user.getUserCity());
            psmt.setInt(3, user.getUserId());

            psmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateUserPasswordByEmail(String password, String mail) {
        try {
            String query = "update user set password = ? where email = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setString(1, password);
            psmt.setString(2, mail);

            psmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 3. Cập nhật thông tin (không có pincode, state)
    public void updateUser(User user) {
        String query = "UPDATE user SET name = ?, email = ?, phone = ?, gender = ?, address = ?, city = ? WHERE userid = ?";

        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setString(1, user.getUserName());
            psmt.setString(2, user.getUserEmail());
            psmt.setString(3, user.getUserPhone());
            psmt.setString(4, user.getUserGender());
            psmt.setString(5, user.getUserAddress());
            psmt.setString(6, user.getUserCity());
            psmt.setInt(7, user.getUserId());

            psmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int userCount() {
        int count = 0;
        try {
            String query = "select count(*) from user";
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery(query);
            rs.next();
            count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    // 5. Các hàm lấy thông tin khác (đã sửa)
    public String getUserAddress(int uid) {
        String query = "SELECT address, city FROM user WHERE userid = ?";
        try (PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, uid);
            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1) + ", " + rs.getString(2);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String getUserName(int uid) {
        String name = "";
        try {
            String query = "select name from user where userid = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setInt(1, uid);

            ResultSet rs = psmt.executeQuery();
            rs.next();
            name = rs.getString(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    public String getUserEmail(int uid) {
        String email = "";
        try {
            String query = "select email from user where userid = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setInt(1, uid);

            ResultSet rs = psmt.executeQuery();
            rs.next();
            email = rs.getString(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return email;
    }

    public String getUserPhone(int uid) {
        String phone = "";
        try {
            String query = "select phone from user where userid = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setInt(1, uid);

            ResultSet rs = psmt.executeQuery();
            rs.next();
            phone = rs.getString(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return phone;
    }

    public void deleteUser(int uid) {
        try {
            String query = "delete from user where userid = ?";
            PreparedStatement psmt = this.con.prepareStatement(query);
            psmt.setInt(1, uid);
            psmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<String> getAllEmail() {
        List<String> list = new ArrayList<>();
        try {
            String query = "select email from user";
            Statement statement = this.con.createStatement();
            ResultSet set = statement.executeQuery(query);
            while (set.next()) {
                list.add(set.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Kiểm tra email đã tồn tại chưa
public boolean isEmailExist(String email) {
    boolean exists = false;
    String query = "SELECT email FROM user WHERE email = ?";
    
    try (PreparedStatement ps = con.prepareStatement(query)) {
        ps.setString(1, email);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                exists = true;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return exists;
}

// Kiểm tra số điện thoại đã tồn tại chưa
public boolean isPhoneExist(String phone) {
    boolean exists = false;
    String query = "SELECT phone FROM user WHERE phone = ?";
    
    try (PreparedStatement ps = con.prepareStatement(query)) {
        ps.setString(1, phone);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                exists = true;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return exists;
}
}
