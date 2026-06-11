package com.hipzi.service;

public interface OcrProvider {
    OcrResult extract(byte[] fileBytes, String contentType, String fileName) throws Exception;
}
