package com.hipzi.service;

import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Material;
import java.util.List;

public class MaterialService {
    private final RepositoryMaterialDao repositoryMaterialDao = new RepositoryMaterialDao();

    public List<Material> getMaterials(String subject, String grade, String type, String searchQuery, String sort) {
        return repositoryMaterialDao.search(subject, grade, type, searchQuery, sort);
    }
}
