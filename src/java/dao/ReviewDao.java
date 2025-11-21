package dao;
import java.sql.*;
import java.util.*;
import entities.Review;

public class ReviewDao {
    private Connection con;
    public ReviewDao(Connection con) { this.con = con; }

    // 1. Lưu đánh giá
    public boolean saveReview(Review r) {
        boolean f = false;
        try {
            // Tên cột khớp với bảng Reviews bạn gửi
            String q = "INSERT INTO Reviews(pid, userid, rating, comment, is_verified, review_date) VALUES(?,?,?,?,?,?)";
            
            PreparedStatement ps = con.prepareStatement(q);
            ps.setInt(1, r.getPid());
            ps.setInt(2, r.getUserId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getComment());
            ps.setBoolean(5, r.isVerified());
            // Lấy thời gian hiện tại
            ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));

            ps.executeUpdate();
            f = true;
        } catch (Exception e) { e.printStackTrace(); }
        return f;
    }

    // 2. Lấy danh sách đánh giá theo PID
    public List<Review> getReviewsByProductId(int pid) {
        List<Review> list = new ArrayList<>();
        try {
            // Join bảng user để lấy tên người hiển thị
            // Lưu ý: Bảng User của bạn tên là 'user' hay 'users'? Tôi đang để là 'user' theo code cũ
            String q = "SELECT r.*, u.name FROM Reviews r " +
                       "JOIN user u ON r.userid = u.userid " +
                       "WHERE r.pid = ? ORDER BY r.review_date DESC";
            
            PreparedStatement ps = con.prepareStatement(q);
            ps.setInt(1, pid);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Review r = new Review();
                r.setReviewId(rs.getInt("review_id"));
                r.setPid(rs.getInt("pid"));
                r.setUserId(rs.getInt("userid"));
                r.setRating(rs.getInt("rating"));
                r.setComment(rs.getString("comment"));
                r.setVerified(rs.getBoolean("is_verified"));
                r.setReviewDate(rs.getTimestamp("review_date"));
                r.setUserName(rs.getString("name")); // Tên từ bảng user
                
                list.add(r);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    // 3. Kiểm tra đã mua hàng (Logic cũ vẫn dùng được nếu bảng orders chuẩn)
    public boolean hasUserBoughtProduct(int uid, int pid) {
        boolean result = false;
        try {
            // Kiểm tra trong bảng ordered_product và order
            String q = "SELECT o.status FROM ordered_product op " +
                       "JOIN `order` o ON op.orderid = o.id " + 
                       "WHERE o.userId = ? AND op.pid = ?";

            PreparedStatement ps = con.prepareStatement(q);
            ps.setInt(1, uid);
            ps.setInt(2, pid);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                String status = rs.getString("status");
                if (status != null && (status.trim().equalsIgnoreCase("Delivered") || status.trim().equalsIgnoreCase("Giao hàng thành công"))) {
                    result = true;
                    break;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }
}