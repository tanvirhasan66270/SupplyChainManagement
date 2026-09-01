package com.project.scm.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.pdf.PdfDocument;

import com.project.scm.R;
import com.project.scm.model.response.InvoiceResponseDTO;
import com.project.scm.model.response.ProductResponseDTO;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class PdfGenerator {

    private static final int COLOR_PRIMARY = Color.parseColor("#103B79");
    private static final int COLOR_TEXT_MAIN = Color.parseColor("#1A1A1A");
    private static final int COLOR_TEXT_GRAY = Color.parseColor("#666666");
    private static final int COLOR_BG_LIGHT = Color.parseColor("#F8FBFF");
    private static final int COLOR_BORDER = Color.parseColor("#EEEEEE");



    public static File generateInvoicePdf(Context context, InvoiceResponseDTO invoice) {
        PdfDocument document = new PdfDocument();
        int pageWidth = 595;
        int pageHeight = 842;
        Paint paint = new Paint();
        paint.setAntiAlias(true);

        // --- PAGE 1: Header, Invoice Details & Financial Breakdown ---
        PdfDocument.PageInfo pageInfo1 = new PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 1).create();
        PdfDocument.Page page1 = document.startPage(pageInfo1);
        Canvas canvas1 = page1.getCanvas();

        drawInvoiceHeader(context, canvas1, paint, invoice, pageWidth);
        int y = 135;

        y = drawInvoiceSectionHeader(context, canvas1, paint, "INVOICE DETAILS", R.drawable.ic_invoice, y, pageWidth);
        y = drawInvoiceDetailsContent(context, canvas1, paint, invoice, y, pageWidth);

        y += 10;

        y = drawInvoiceSectionHeader(context, canvas1, paint, "FINANCIAL BREAKDOWN", R.drawable.ic_wallet, y, pageWidth);
        y = drawFinancialBreakdownTable(context, canvas1, paint, invoice, y, pageWidth);

        drawFooter(context, canvas1, paint, pageWidth, pageHeight);
        document.finishPage(page1);

        // --- PAGE 2: Payment & Status Section ---
        PdfDocument.PageInfo pageInfo2 = new PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 2).create();
        PdfDocument.Page page2 = document.startPage(pageInfo2);
        Canvas canvas2 = page2.getCanvas();

        int y2 = 50;
        y2 = drawInvoiceSectionHeader(context, canvas2, paint, "PAYMENT & STATUS", R.drawable.ic_bank, y2, pageWidth);
        y2 = drawPaymentStatusContent(context, canvas2, paint, invoice, y2, pageWidth);

        drawFooter(context, canvas2, paint, pageWidth, pageHeight);
        document.finishPage(page2);

        return savePdf(context, "Invoice_" + (invoice.getInvoiceNumber() != null ? invoice.getInvoiceNumber() : invoice.getId()), document);
    }

    private static void drawInvoiceHeader(Context context, Canvas canvas, Paint paint, InvoiceResponseDTO invoice, int width) {
        Bitmap logo = BitmapFactory.decodeResource(context.getResources(), R.mipmap.logo);
        if (logo != null) {
            float logoWidth = 100;
            float logoHeight = (logoWidth / logo.getWidth()) * logo.getHeight();
            RectF destRect = new RectF(30, 20, 30 + logoWidth, 20 + logoHeight);
            canvas.drawBitmap(logo, null, destRect, paint);
        }

        String invNum = "Invoice #" + (invoice.getInvoiceNumber() != null ? invoice.getInvoiceNumber() : "INV-" + invoice.getId());
        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(15);
        paint.setFakeBoldText(true);
        float textWidth = paint.measureText(invNum);
        canvas.drawText(invNum, width - 30 - textWidth, 45, paint);

        paint.setColor(COLOR_BG_LIGHT);
        RectF badgeRect = new RectF(width - 140, 60, width - 30, 85);
        canvas.drawRoundRect(badgeRect, 6, 6, paint);

        drawIcon(context, canvas, R.drawable.ic_invoice, width - 130, 66, 12, COLOR_TEXT_MAIN);
        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(9);
        paint.setFakeBoldText(true);
        canvas.drawText("INVOICE DETAILS", width - 112, 77, paint);
    }

    private static int drawInvoiceSectionHeader(Context context, Canvas canvas, Paint paint, String title, int iconRes, int startY, int width) {
        paint.setColor(COLOR_BG_LIGHT);
        RectF headerBg = new RectF(30, startY, width - 30, startY + 30);
        canvas.drawRoundRect(headerBg, 6, 6, paint);

        drawIcon(context, canvas, iconRes, 45, startY + 6, 18, COLOR_TEXT_MAIN);
        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(13);
        paint.setFakeBoldText(true);
        canvas.drawText(title, 72, startY + 19, paint);

        return startY + 38;
    }

    private static int drawInvoiceDetailsContent(Context context, Canvas canvas, Paint paint, InvoiceResponseDTO invoice, int startY, int width) {
        int y = startY;
        int rowHeight = 22;

        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_invoice, "Invoice #", invoice.getInvoiceNumber(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_copy, "Record ID", String.valueOf(invoice.getId()), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_sync, "Customer Order ID", String.valueOf(invoice.getCustomerOrderId()), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_person, "Issued To", invoice.getIssuedToName(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_mail, "Customer Email", invoice.getCustomerEmail(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_person, "Sales Officer ID", String.valueOf(invoice.getSalesOfficerId() != null ? invoice.getSalesOfficerId() : "N/A"), 50, y, width);

        return y + 8;
    }

    private static int drawFinancialBreakdownTable(Context context, Canvas canvas, Paint paint, InvoiceResponseDTO invoice, int startY, int width) {
        int y = startY;

        paint.setColor(Color.parseColor("#F9F9F9"));
        canvas.drawRect(30, y, width - 30, y + 25, paint);
        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(11);
        paint.setFakeBoldText(true);
        canvas.drawText("Label", 40, y + 17, paint);
        canvas.drawText("Amount", width - 150, y + 17, paint);

        y += 28;
        String symbol = "BDT".equalsIgnoreCase(invoice.getCurrency()) ? "৳" : (invoice.getCurrency() != null ? invoice.getCurrency() : "৳");

        int rowH = 24;
        y = drawBreakdownRow(canvas, paint, "Currency", invoice.getCurrency(), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Subtotal", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getSubtotal()), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Tax Rate", String.format(Locale.getDefault(), "%.1f%% (%s%.2f)", invoice.getTaxRate(), symbol, invoice.getTaxAmount()), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Discount Rate", String.format(Locale.getDefault(), "%.1f%% (%s%.2f)", invoice.getDiscountPercentage(), symbol, invoice.getDiscountAmount()), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Shipping Fees", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getShippingFees()), y, width, rowH);

        paint.setColor(COLOR_BORDER);
        paint.setStrokeWidth(1);
        canvas.drawLine(30, y, width - 30, y, paint);
        y += 4;

        y = drawBreakdownRow(canvas, paint, "Total Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getTotalAmount()), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Paid Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getPaidAmount()), y, width, rowH);
        y = drawBreakdownRow(canvas, paint, "Due Amount", String.format(Locale.getDefault(), "%s%.2f", symbol, invoice.getDueAmount()), y, width, rowH);

        return y + 8;
    }

    private static int drawBreakdownRow(Canvas canvas, Paint paint, String label, String value, int y, int width, int rowHeight) {
        paint.setColor(COLOR_TEXT_GRAY);
        paint.setTextSize(11);
        paint.setFakeBoldText(false);
        canvas.drawText(label, 40, y + 16, paint);

        paint.setColor(COLOR_TEXT_MAIN);
        paint.setFakeBoldText(true);
        float valueWidth = paint.measureText(value);
        canvas.drawText(value, width - 40 - valueWidth, y + 16, paint);

        return y + rowHeight;
    }

    private static int drawPaymentStatusContent(Context context, Canvas canvas, Paint paint, InvoiceResponseDTO invoice, int startY, int width) {
        int y = startY;
        int rowHeight = 22;

        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_check_circle, "Payment Status", invoice.getPaymentStatus(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_bank, "Payment Method", invoice.getPaymentMethod(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_copy, "Transaction Ref", invoice.getTransactionReference(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_invoice, "Invoice Status", invoice.getInvoiceStatus(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_calendar, "Issued Date", invoice.getIssuedAt(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_calendar, "Delivery Date", invoice.getDeliveryDate(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_location, "Delivery Address", invoice.getDeliveryAddress(), 50, y, width);
        y += rowHeight;
        drawPdfFieldRow(context, canvas, paint, R.drawable.ic_copy, "Notes", invoice.getNotes(), 50, y, width);

        return y + 8;
    }

    private static void drawPdfFieldRow(Context context, Canvas canvas, Paint paint, int iconRes, String label, String value, int x, int y, int width) {
        drawIcon(context, canvas, iconRes, x, y + 4, 13, COLOR_TEXT_MAIN);

        paint.setColor(COLOR_TEXT_GRAY);
        paint.setTextSize(10);
        paint.setFakeBoldText(false);
        canvas.drawText(label, x + 22, y + 15, paint);

        canvas.drawText(":", 190, y + 15, paint);

        paint.setColor(COLOR_TEXT_MAIN);
        paint.setFakeBoldText(true);
        String displayValue = value != null ? value : "N/A";
        canvas.drawText(displayValue, 210, y + 15, paint);
    }

    private static void drawFooter(Context context, Canvas canvas, Paint paint, int width, int height) {
        paint.setColor(COLOR_PRIMARY);
        canvas.drawRect(0, height - 60, width, height, paint);
        paint.setColor(Color.WHITE);
        paint.setTextSize(11);
        paint.setFakeBoldText(true);
        canvas.drawText("SCM Enterprise - Supply Chain Management System", 30, height - 35, paint);
        paint.setTextSize(9);
        paint.setFakeBoldText(false);
        canvas.drawText("Generated On: " + new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.getDefault()).format(new Date()), width - 210, height - 35, paint);
    }

    private static void drawIcon(Context context, Canvas canvas, int resId, float x, float y, float size, int color) {
        Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), resId);
        if (bitmap != null) {
            Paint iconPaint = new Paint();
            iconPaint.setAntiAlias(true);
            iconPaint.setColorFilter(new android.graphics.PorterDuffColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN));
            RectF dest = new RectF(x, y, x + size, y + size);
            canvas.drawBitmap(bitmap, null, dest, iconPaint);
        }
    }

    private static File savePdf(Context context, String name, PdfDocument document) {
        File pdfDir = new File(context.getCacheDir(), "pdfs");
        if (!pdfDir.exists()) pdfDir.mkdirs();
        File file = new File(pdfDir, name + ".pdf");
        try {
            document.writeTo(new FileOutputStream(file));
        } catch (IOException e) {
            e.printStackTrace();
            file = null;
        } finally {
            document.close();
        }
        return file;
    }

    public static File generateStatementPdf(Context context, List<InvoiceResponseDTO> invoices) {
        PdfDocument document = new PdfDocument();
        int pageWidth = 595;
        int pageHeight = 842;
        Paint paint = new Paint();
        paint.setAntiAlias(true);

        double totalBilled = 0, totalPaid = 0, totalDue = 0;
        for (InvoiceResponseDTO inv : invoices) {
            totalBilled += inv.getTotalAmount();
            totalPaid += inv.getPaidAmount();
            totalDue += inv.getDueAmount();
        }

        int invoiceIndex = 0;
        int pageNumber = 1;

        while (invoiceIndex < invoices.size() || pageNumber == 1) {
            PdfDocument.PageInfo pageInfo = new PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNumber).create();
            PdfDocument.Page page = document.startPage(pageInfo);
            Canvas canvas = page.getCanvas();

            // 1. Header (Common for all pages)
            drawStatementHeader(context, canvas, paint, pageWidth);

            int y = 110;

            if (pageNumber == 1) {
                // 2. Summary Section (Only on Page 1)
                y = drawStatementSummary(canvas, paint, totalBilled, totalPaid, totalDue, pageWidth, y);
            }

            // 3. Table Header
            y = drawStatementTableHeader(canvas, paint, pageWidth, y);

            // 4. Table Rows
            int maxRowsPerPage = (pageNumber == 1) ? 18 : 25;
            int rowsDrawn = 0;
            while (invoiceIndex < invoices.size() && rowsDrawn < maxRowsPerPage) {
                drawStatementRow(canvas, paint, invoices.get(invoiceIndex), pageWidth, y);
                y += 25;
                invoiceIndex++;
                rowsDrawn++;
            }

            // 5. Footer
            drawFooter(context, canvas, paint, pageWidth, pageHeight);

            document.finishPage(page);
            pageNumber++;
            if (invoiceIndex >= invoices.size()) break;
        }

        return savePdf(context, "Billing_Statement_Report", document);
    }

    private static void drawStatementHeader(Context context, Canvas canvas, Paint paint, int width) {
        Bitmap logo = BitmapFactory.decodeResource(context.getResources(), R.mipmap.logo);
        if (logo != null) {
            float logoWidth = 120;
            float logoHeight = (logoWidth / logo.getWidth()) * logo.getHeight();
            RectF destRect = new RectF(30, 25, 30 + logoWidth, 25 + logoHeight);
            canvas.drawBitmap(logo, null, destRect, paint);
        }

        paint.setColor(COLOR_PRIMARY);
        paint.setTextSize(18);
        paint.setFakeBoldText(true);
        String title = "BILLING STATEMENT REPORT";
        float textWidth = paint.measureText(title);
        canvas.drawText(title, width - 30 - textWidth, 50, paint);

        paint.setColor(COLOR_TEXT_GRAY);
        paint.setTextSize(10);
        paint.setFakeBoldText(false);
        String sub = "Comprehensive Financial Summary";
        canvas.drawText(sub, width - 30 - paint.measureText(sub), 65, paint);
    }

    private static int drawStatementSummary(Canvas canvas, Paint paint, double billed, double paid, double due, int width, int startY) {
        int y = startY;
        paint.setColor(COLOR_BG_LIGHT);
        RectF summaryBox = new RectF(30, y, width - 30, y + 60);
        canvas.drawRoundRect(summaryBox, 8, 8, paint);

        paint.setStrokeWidth(1);
        paint.setColor(COLOR_BORDER);
        paint.setStyle(Paint.Style.STROKE);
        canvas.drawRoundRect(summaryBox, 8, 8, paint);
        paint.setStyle(Paint.Style.FILL);

        int cellW = (width - 60) / 3;
        drawSummaryItem(canvas, paint, "Total Billed", String.format(Locale.getDefault(), "৳%.2f", billed), 30 + cellW / 2, y + 25);
        drawSummaryItem(canvas, paint, "Total Paid", String.format(Locale.getDefault(), "৳%.2f", paid), 30 + cellW + cellW / 2, y + 25);
        drawSummaryItem(canvas, paint, "Outstanding Due", String.format(Locale.getDefault(), "৳%.2f", due), 30 + cellW * 2 + cellW / 2, y + 25);

        return y + 80;
    }

    private static void drawSummaryItem(Canvas canvas, Paint paint, String label, String value, int centerX, int y) {
        paint.setColor(COLOR_TEXT_GRAY);
        paint.setTextSize(10);
        paint.setFakeBoldText(false);
        float lw = paint.measureText(label);
        canvas.drawText(label, centerX - lw / 2, y, paint);

        paint.setColor(COLOR_PRIMARY);
        paint.setTextSize(13);
        paint.setFakeBoldText(true);
        float vw = paint.measureText(value);
        canvas.drawText(value, centerX - vw / 2, y + 20, paint);
    }

    private static int drawStatementTableHeader(Canvas canvas, Paint paint, int width, int y) {
        paint.setColor(Color.parseColor("#F5F5F5"));
        canvas.drawRect(30, y, width - 30, y + 25, paint);

        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(10);
        paint.setFakeBoldText(true);

        canvas.drawText("Invoice #", 40, y + 17, paint);
        canvas.drawText("Date", 150, y + 17, paint);
        canvas.drawText("Status", 260, y + 17, paint);
        canvas.drawText("Total Amount", 380, y + 17, paint);
        canvas.drawText("Due Amount", width - 40 - paint.measureText("Due Amount"), y + 17, paint);

        return y + 35;
    }

    private static void drawStatementRow(Canvas canvas, Paint paint, InvoiceResponseDTO inv, int width, int y) {
        paint.setColor(COLOR_TEXT_MAIN);
        paint.setTextSize(10);
        paint.setFakeBoldText(false);

        String invNum = inv.getInvoiceNumber() != null ? inv.getInvoiceNumber() : "INV-" + inv.getId();
        canvas.drawText(invNum, 40, y + 15, paint);
        canvas.drawText(inv.getIssuedAt() != null ? inv.getIssuedAt() : "N/A", 150, y + 15, paint);
        canvas.drawText(inv.getPaymentStatus() != null ? inv.getPaymentStatus() : "UNPAID", 260, y + 15, paint);

        paint.setFakeBoldText(true);
        String total = String.format(Locale.getDefault(), "৳%.2f", inv.getTotalAmount());
        canvas.drawText(total, 380, y + 15, paint);

        String due = String.format(Locale.getDefault(), "৳%.2f", inv.getDueAmount());
        canvas.drawText(due, width - 40 - paint.measureText(due), y + 15, paint);

        paint.setColor(Color.parseColor("#F9F9F9"));
        paint.setStrokeWidth(0.5f);
        canvas.drawLine(30, y + 22, width - 30, y + 22, paint);
    }
}