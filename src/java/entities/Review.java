package entities;
import java.sql.Timestamp;

public class Review {
    private int reviewId;   // Map với review_id
    private int pid;        // Map với pid
    private int userId;     // Map với userid
    private int rating;
    private String comment;
    private boolean isVerified; // Map với is_verified (BOOLEAN)
    private Timestamp reviewDate; // Map với review_date
    
    // Biến phụ để hiển thị tên người dùng (khi Join bảng User)
    private String userName; 

    public Review() {}

    // Constructor dùng để lưu
    public Review(int pid, int userId, int rating, String comment, boolean isVerified) {
        this.pid = pid;
        this.userId = userId;
        this.rating = rating;
        this.comment = comment;
        this.isVerified = isVerified;
    }

    // Getter & Setter
    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public int getPid() { return pid; }
    public void setPid(int pid) { this.pid = pid; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public boolean isVerified() { return isVerified; }
    public void setVerified(boolean isVerified) { this.isVerified = isVerified; }

    public Timestamp getReviewDate() { return reviewDate; }
    public void setReviewDate(Timestamp reviewDate) { this.reviewDate = reviewDate; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}