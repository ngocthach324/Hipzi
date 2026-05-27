package com.hipzi.dao;

import com.hipzi.model.Role;
import com.hipzi.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RoleDao {

    public Role findRoleByName(String name) {
        String sql = "SELECT * FROM roles WHERE name = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setId(rs.getString("id"));
                    role.setName(rs.getString("name"));
                    role.setDescription(rs.getString("description"));
                    role.setCreatedAt(rs.getTimestamp("created_at"));
                    return role;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in RoleDao.findRoleByName: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
