package com.hipzi.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Locale;

public class TesseractOcrProvider implements OcrProvider {
    private final TesseractOcrService tesseractOcrService;

    public TesseractOcrProvider(TesseractOcrService tesseractOcrService) {
        this.tesseractOcrService = tesseractOcrService;
    }

    @Override
    public OcrResult extract(byte[] fileBytes, String contentType, String fileName) throws Exception {
        if (fileBytes == null || fileBytes.length == 0) {
            throw new IllegalArgumentException("OCR source file is empty.");
        }
        if (isPdf(fileName, contentType)) {
            throw new IllegalArgumentException("Tesseract provider only supports image files.");
        }

        File tempFile = Files.createTempFile("hipzi-tesseract-ocr-", extensionOf(fileName)).toFile();
        try {
            Files.write(tempFile.toPath(), fileBytes);
            OcrResult result = new OcrResult();
            result.setProvider("tesseract");
            result.setPlainText(tesseractOcrService.scan(tempFile));
            return result;
        } finally {
            try {
                Files.deleteIfExists(tempFile.toPath());
            } catch (IOException ignored) {
            }
        }
    }

    private boolean isPdf(String fileName, String contentType) {
        String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        return lowerName.endsWith(".pdf") || "application/pdf".equalsIgnoreCase(contentType);
    }

    private String extensionOf(String fileName) {
        String lowerName = fileName == null ? "" : fileName.toLowerCase(Locale.ROOT);
        int dotIndex = lowerName.lastIndexOf('.');
        if (dotIndex >= 0) {
            String extension = lowerName.substring(dotIndex);
            if (extension.matches("\\.(png|jpg|jpeg|webp|tif|tiff|bmp)")) {
                return extension;
            }
        }
        return ".png";
    }
}
