package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import entities.Category;

public class CategoryDao {
	private Connection con;

	public CategoryDao(Connection con) {
		super();
		this.con = con;
	}

	public boolean saveCategory(Category category) {
		boolean flag = false;

		try {
			String query = "insert into category(name, image) values(?, ?)";
			PreparedStatement psmt = this.con.prepareStatement(query);
			psmt.setString(1, category.getCategoryName());
			psmt.setString(2, category.getCategoryImage());

			psmt.executeUpdate();
			flag = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return flag;
	}

	public List<Category> getAllCategories() {

		List<Category> list = new ArrayList<>();
		try {

			String query = "select * from category";
			Statement statement = this.con.createStatement();

			ResultSet rs = statement.executeQuery(query);
			while (rs.next()) {
				Category category = new Category();
				category.setCategoryId(rs.getInt("cid"));
				category.setCategoryName(rs.getString("name"));
				category.setCategoryImage(rs.getString("image"));

				list.add(category);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}
	public Category getCategoryById(int cid) {
		Category category = new Category();
		try {
			String query = "select * from category where cid = ?";
			PreparedStatement psmt = this.con.prepareStatement(query);
			psmt.setInt(1, cid);
			ResultSet rs = psmt.executeQuery();
			while (rs.next()) {
				category.setCategoryId(rs.getInt("cid"));
				category.setCategoryName(rs.getString("name"));
				category.setCategoryImage(rs.getString("image"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return category;
	}
	public String getCategoryName(int catId) {
		String category = "";
		try {
			String query = "select * from category where cid = ?";
			PreparedStatement psmt = this.con.prepareStatement(query);
			psmt.setInt(1, catId);
			ResultSet rs = psmt.executeQuery();
			while (rs.next()) {
				category = rs.getString("name");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return category;
	}
	
	public void updateCategory(Category cat) {
		try {
			String query = "update category set name=?, image=? where cid=?";
			PreparedStatement psmt = this.con.prepareStatement(query);
			psmt.setString(1, cat.getCategoryName());
			psmt.setString(2, cat.getCategoryImage());
			psmt.setInt(3, cat.getCategoryId());
			
			psmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public boolean deleteCategory(int cid) {
		boolean success = false;
		String cartQuery = "delete from cart where pid in (select pid from (select pid from product where cid = ?) as prod)";
		String wishlistQuery = "delete from wishlist where idproduct in (select pid from (select pid from product where cid = ?) as prod)";
		String productQuery = "delete from product where cid = ?";
		String categoryQuery = "delete from category where cid = ?";
		try {
			this.con.setAutoCommit(false);
			
			PreparedStatement cartStmt = this.con.prepareStatement(cartQuery);
			cartStmt.setInt(1, cid);
			cartStmt.executeUpdate();
			cartStmt.close();
			
			PreparedStatement wishlistStmt = this.con.prepareStatement(wishlistQuery);
			wishlistStmt.setInt(1, cid);
			wishlistStmt.executeUpdate();
			wishlistStmt.close();
			
			PreparedStatement productStmt = this.con.prepareStatement(productQuery);
			productStmt.setInt(1, cid);
			productStmt.executeUpdate();
			productStmt.close();
			
			PreparedStatement categoryStmt = this.con.prepareStatement(categoryQuery);
			categoryStmt.setInt(1, cid);
			categoryStmt.executeUpdate();
			categoryStmt.close();
			
			this.con.commit();
			success = true;
		} catch (Exception e) {
			try {
				this.con.rollback();
			} catch (SQLException ex) {
				ex.printStackTrace();
			}
			e.printStackTrace();
		} finally {
			try {
				this.con.setAutoCommit(true);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}
	public int categoryCount() {
		int count = 0;
		try {
			String query = "select count(*) from category";
			Statement stmt = con.createStatement();
			ResultSet rs = stmt.executeQuery(query);
			rs.next();
			count = rs.getInt(1);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return count;
	}
}
