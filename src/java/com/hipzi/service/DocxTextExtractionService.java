package com.hipzi.service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class DocxTextExtractionService {

    public OcrResult extract(byte[] fileBytes, String fileName) throws Exception {
        if (fileBytes == null || fileBytes.length == 0) {
            throw new IllegalArgumentException("DOCX source file is empty.");
        }
        byte[] documentXml = readZipEntry(fileBytes, "word/document.xml");
        if (documentXml == null || documentXml.length == 0) {
            throw new IllegalArgumentException("DOCX file does not contain word/document.xml.");
        }

        String text = extractDocumentText(documentXml);
        OcrResult result = new OcrResult();
        result.setProvider("docx");
        result.setPlainText(text);
        result.setMarkdown(text);
        result.setLayoutJson(fileName == null ? "" : "{\"source\":\"" + escapeJson(fileName) + "\"}");
        return result;
    }

    private byte[] readZipEntry(byte[] fileBytes, String entryName) throws Exception {
        try (ZipInputStream zip = new ZipInputStream(new ByteArrayInputStream(fileBytes))) {
            ZipEntry entry;
            while ((entry = zip.getNextEntry()) != null) {
                if (entryName.equals(entry.getName())) {
                    ByteArrayOutputStream output = new ByteArrayOutputStream();
                    zip.transferTo(output);
                    return output.toByteArray();
                }
            }
        }
        return null;
    }

    private String extractDocumentText(byte[] documentXml) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
        factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        factory.setXIncludeAware(false);
        factory.setExpandEntityReferences(false);

        Document document = factory.newDocumentBuilder()
                .parse(new ByteArrayInputStream(documentXml));
        StringBuilder text = new StringBuilder();
        NodeList bodyNodes = document.getElementsByTagNameNS(
                "http://schemas.openxmlformats.org/wordprocessingml/2006/main", "body");
        Node root = bodyNodes.getLength() > 0 ? bodyNodes.item(0) : document.getDocumentElement();
        appendNodeText(root, text);
        return normalizeText(text.toString());
    }

    private void appendNodeText(Node node, StringBuilder text) {
        if (node == null) {
            return;
        }
        String localName = node.getLocalName();
        if ("t".equals(localName)) {
            text.append(node.getTextContent());
            return;
        }
        if ("tab".equals(localName)) {
            text.append('\t');
            return;
        }
        if ("br".equals(localName) || "cr".equals(localName)) {
            text.append('\n');
            return;
        }

        NodeList children = node.getChildNodes();
        for (int i = 0; i < children.getLength(); i++) {
            appendNodeText(children.item(i), text);
        }
        if ("p".equals(localName) || "tr".equals(localName)) {
            text.append('\n');
        } else if ("tc".equals(localName)) {
            text.append('\t');
        }
    }

    private String normalizeText(String value) {
        return value == null ? "" : value
                .replace("\r", "\n")
                .replaceAll("[ \\t]+\\n", "\n")
                .replaceAll("\\n{3,}", "\n\n")
                .trim();
    }

    private String escapeJson(String value) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; value != null && i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
}
