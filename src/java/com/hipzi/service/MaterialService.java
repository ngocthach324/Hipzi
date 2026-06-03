package com.hipzi.service;

import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Material;
import java.util.List;

import com.hipzi.dto.PaginatedResult;

public class MaterialService {
    private final RepositoryMaterialDao repositoryMaterialDao = new RepositoryMaterialDao();

    public PaginatedResult<Material> getMaterials(String subject, String grade, String type, String searchQuery, String sort, int page, int pageSize) {
        int totalItems = repositoryMaterialDao.countSearch(subject, grade, type, searchQuery);
        List<Material> data = repositoryMaterialDao.search(subject, grade, type, searchQuery, sort, page, pageSize);
        return new PaginatedResult<>(data, totalItems, page, pageSize);
    }
}
