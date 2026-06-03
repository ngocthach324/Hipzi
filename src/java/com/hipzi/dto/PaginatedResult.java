package com.hipzi.dto;

import java.util.List;

public class PaginatedResult<T> {
    private List<T> data;
    private int totalItems;
    private int currentPage;
    private int pageSize;
    private int totalPages;

    public PaginatedResult(List<T> data, int totalItems, int currentPage, int pageSize) {
        this.data = data;
        this.totalItems = totalItems;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalPages = (int) Math.ceil((double) totalItems / pageSize);
    }

    public List<T> getData() {
        return data;
    }

    public int getTotalItems() {
        return totalItems;
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public int getTotalPages() {
        return totalPages;
    }
}
