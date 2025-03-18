import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalaryInfo {
  final String title;
  final double amount;

  SalaryInfo({required this.title, required this.amount});
}

class HomePageSharePdf {
  static Future<void> generateDynamicPDF(
      BuildContext context, List<SalaryInfo> salaryData, String title) async {
    if (salaryData.isEmpty) {
      throw Exception('No salary data available to generate the PDF.');
    }

    final pdf = pw.Document();

    // Load Background Image
    pw.MemoryImage? backgroundImage;
    try {
      final ByteData imageData = await rootBundle.load('assets/images/head.png');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      backgroundImage = pw.MemoryImage(imageBytes);
    } catch (e) {
      debugPrint("Error loading image: $e");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // **Background Image**
              if (backgroundImage != null)
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: 1, // **✅ Light transparency for readability**
                    child: pw.Image(
                      backgroundImage,
                      fit: pw.BoxFit.fill, // **Covers entire page**
                    ),
                  ),
                ),

              // **Content on Top of the Background**
              pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // **Title**
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // **Date**
                    pw.Text(
                      'Date: ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 20),

                    // **Table**
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.black),
                      columnWidths: {
                        0: pw.FlexColumnWidth(3),
                        1: pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Header Row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey300),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6.0),
                              child: pw.Text("Title",
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6.0),
                              child: pw.Text("Amount",
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),

                        // Data Rows
                        ...salaryData.map((salary) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6.0),
                                child: pw.Text(salary.title,
                                    style: pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6.0),
                                child: pw.Text("\$${salary.amount.toStringAsFixed(2)}",
                                    style: pw.TextStyle(fontSize: 10)),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // **📌 Save and Open PDF**
    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateFormat('dd_MM_yyyy_HH_mm_ss').format(DateTime.now())}_Salary_Report.pdf';
      final filePath = '${outputDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved at $filePath');

      final result = await OpenFilex.open(filePath);
      debugPrint('📂 OpenFilex result: ${result.message}');
    } catch (e) {
      debugPrint('❌ Error saving or opening PDF: $e');
    }
  }
}














/*
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalaryInfo {
  final String title;
  final double amount;

  SalaryInfo({required this.title, required this.amount});
}

class HomePageSharePdf {
  static Future<void> generateDynamicPDF(
      BuildContext context, List<SalaryInfo> salaryData, String title) async {
    if (salaryData.isEmpty) {
      throw Exception('No salary data available to generate the PDF.');
    }

    final pdf = pw.Document();

    // Load Image
    pw.MemoryImage? pdfImage;
    try {
      final ByteData imageData = await rootBundle.load('assets/images/head.png');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      pdfImage = pw.MemoryImage(imageBytes);
    } catch (e) {
      debugPrint("Error loading image: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 20,
          marginRight: 20,
          marginTop: 20,
          marginBottom: 20,
        ),
        build: (pw.Context context) {
          return [
            // **✅ Image Resized Instead of Full Page**
            if (pdfImage != null)
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Image(pdfImage, width: 500, height: 120), // **Smaller Size**
              ),
            pw.SizedBox(height: 10),

            // **Title**
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            // **Date**
            pw.Center(
              child: pw.Text(
                'Date: ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
              ),
            ),
            pw.SizedBox(height: 10),

            // **Salary Table with Wrapping**
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                // **Header**
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text("Title",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6.0),
                      child: pw.Text("Amount",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),

                // **Dynamic Rows with Wrapping**
                ...salaryData.map((salary) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text(salary.title,
                            style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6.0),
                        child: pw.Text("\$${salary.amount.toStringAsFixed(2)}",
                            style: pw.TextStyle(fontSize: 10)),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    // **📌 Save and Open PDF**
    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateFormat('dd_MM_yyyy_HH_mm_ss').format(DateTime.now())}_Salary_Report.pdf';
      final filePath = '${outputDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved at $filePath');

      final result = await OpenFilex.open(filePath);
      debugPrint('📂 OpenFilex result: ${result.message}');
    } catch (e) {
      debugPrint('❌ Error saving or opening PDF: $e');
    }
  }
}
*/
