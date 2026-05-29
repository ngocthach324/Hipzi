package com.hipzi.service;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class TesseractOcrService {

    private static final long OCR_TIMEOUT_SECONDS = 35;

    public String scan(File imageFile) throws Exception {
        if (imageFile == null || !imageFile.isFile()) {
            throw new IllegalArgumentException("Image file is missing.");
        }

        String tesseractCmd = System.getenv("HIPZI_TESSERACT_CMD");
        if (tesseractCmd == null || tesseractCmd.trim().isEmpty()) {
            tesseractCmd = "tesseract";
        }

        List<String> command = new ArrayList<>();
        command.add(tesseractCmd);
        command.add(imageFile.getAbsolutePath());
        command.add("stdout");
        command.add("-l");
        command.add("vie+eng");
        command.add("--oem");
        command.add("1");
        command.add("--psm");
        command.add("3");

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.redirectErrorStream(true);
        Process process = processBuilder.start();
        boolean finished = process.waitFor(OCR_TIMEOUT_SECONDS, TimeUnit.SECONDS);
        if (!finished) {
            process.destroyForcibly();
            throw new IllegalStateException("Tesseract OCR timeout.");
        }

        String output = new String(process.getInputStream().readAllBytes(), StandardCharsets.UTF_8).trim();
        if (process.exitValue() != 0 || output.isEmpty()) {
            throw new IllegalStateException("Tesseract OCR failed: " + output);
        }
        return normalizeOcrText(output);
    }

    private String normalizeOcrText(String text) {
        return text == null ? "" : text
                .replace("\r", "\n")
                .replaceAll("[ \\t]+", " ")
                .replaceAll("\\n{3,}", "\n\n")
                .trim();
    }
}
