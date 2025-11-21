package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import entities.OrderedProduct;

public class OrderedProductDao {
	private Connection con;

	public OrderedProductDao(Connection con) {
		super();
		this.con = con;
	}
	
	public boolean insertOrderedProduct(OrderedProduct order) {
    boolean f = false;
    try {
        // THÊM CỘT pid VÀO CÂU LỆNH INSERT
        String sql = "INSERT INTO ordered_product(name, quantity, price, image, orderid, pid) VALUES(?,?,?,?,?,?)";
        PreparedStatement ps = this.con.prepareStatement(sql);
        ps.setString(1, order.getName());
        ps.setInt(2, order.getQuantity());
        ps.setDouble(3, order.getPrice());
        ps.setString(4, order.getImage());
        ps.setInt(5, order.getOrderId());
        ps.setInt(6, order.getProductId()); // Lưu PID vào đây

        ps.executeUpdate();
        f = true;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return f;
}
	public List<OrderedProduct> getAllOrderedProduct(int oid){
		List<OrderedProduct> list = new ArrayList<OrderedProduct>();
		try {
			String query = "select * from ordered_product where orderid = ?";
			PreparedStatement psmt = this.con.prepareStatement(query);
			psmt.setInt(1, oid);
			ResultSet rs = psmt.executeQuery();
			while (rs.next()) {
				OrderedProduct orderProd = new OrderedProduct();
				orderProd.setName(rs.getString("name"));
				orderProd.setQuantity(rs.getInt("quantity"));
				orderProd.setPrice(rs.getFloat("price"));
				orderProd.setImage(rs.getString("image"));
				orderProd.setOrderId(oid);

				list.add(orderProd);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
}
