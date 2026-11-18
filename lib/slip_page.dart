import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'models.dart';
import 'screens.dart' show dateLabel, money;

class SlipPage extends StatelessWidget {
  const SlipPage({super.key, required this.record});

  final PayrollRecord record;

  Future<Uint8List> _makePdf() async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.fromLTRB(42, 42, 42, 38),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KARTAPPAY',
                      style: pw.TextStyle(
                        fontSize: 19,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#173B35'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'PAYROLL SLIP',
                      style: pw.TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      record.kind == 'pakyaw' ? 'PAKYAW' : 'DRIVER PAY',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      dateLabel(record.date),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Divider(color: PdfColor.fromHex('#173B35'), thickness: 1.2),
            pw.SizedBox(height: 12),
            _pdfMeta(
              'Reference',
              record.reference.isEmpty ? '-' : record.reference,
            ),
            if (record.kind == 'pakyaw')
              _pdfMeta(
                'Work details',
                record.description.isEmpty ? '-' : record.description,
              )
            else ...[
              _pdfMeta(
                'Destination',
                record.destination.isEmpty ? '-' : record.destination,
              ),
              _pdfMeta(
                'Truck',
                record.truckPlate.isEmpty ? '-' : record.truckPlate,
              ),
              _pdfMeta('Trips', '${record.tripCount}'),
              _pdfMeta('Rate per trip', _pdfMoney(record.ratePerTrip)),
            ],
            pw.SizedBox(height: 18),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Worker / Driver',
                'Gross Pay',
                'Deductions',
                'Net Pay',
              ],
              data: record.lines
                  .map(
                    (line) => [
                      line.workerName,
                      _pdfMoney(line.gross),
                      _pdfMoney(line.deduction),
                      _pdfMoney(line.net),
                    ],
                  )
                  .toList(),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE2EEE5),
              ),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerRight,
              headerAlignment: pw.Alignment.centerRight,
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(1.3),
                2: const pw.FlexColumnWidth(1.3),
                3: const pw.FlexColumnWidth(1.3),
              },
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: .5,
                ),
                bottom: pw.BorderSide(color: PdfColors.grey400, width: .7),
              ),
            ),
            pw.SizedBox(height: 17),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 210,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF3F5F1),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  children: [
                    _pdfTotal('Gross total', record.totalGross),
                    pw.SizedBox(height: 6),
                    _pdfTotal('Total deductions', record.totalDeduction),
                    pw.Divider(color: PdfColors.grey400),
                    _pdfTotal('NET PAY', record.totalNet, strong: true),
                  ],
                ),
              ),
            ),
            pw.Spacer(),
            pw.Row(
              children: [
                pw.Expanded(child: _signature('Prepared by')),
                pw.SizedBox(width: 35),
                pw.Expanded(child: _signature('Received by')),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'Generated by KartapPay',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  String _pdfMoney(double value) =>
      'PHP ${NumberFormat('#,##0.00').format(value)}';

  pw.Widget _pdfMeta(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 115,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  pw.Widget _pdfTotal(String label, double value, {bool strong = false}) =>
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: strong ? 11 : 9,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Text(
            _pdfMoney(value),
            style: pw.TextStyle(
              fontSize: strong ? 11 : 9,
              fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      );

  pw.Widget _signature(String label) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(height: 1, color: PdfColors.grey600),
      pw.SizedBox(height: 5),
      pw.Text(
        label,
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
      ),
    ],
  );

  Future<void> _print() async {
    await Printing.layoutPdf(
      onLayout: (_) => _makePdf(),
      name:
          'KartapPay-${record.reference.isEmpty ? record.id : record.reference}.pdf',
      format: PdfPageFormat.letter,
    );
  }

  Future<void> _share() async {
    final bytes = await _makePdf();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'KartapPay-${record.reference.isEmpty ? record.id : record.reference}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPakyaw = record.kind == 'pakyaw';
    final compactPreview = MediaQuery.sizeOf(context).width < 420;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print preview'),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: _share,
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            tooltip: 'Print slip',
            onPressed: _print,
            icon: const Icon(Icons.print_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 28),
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E4DE)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KARTAPPAY',
                            style: TextStyle(
                              color: Color(0xFF173B35),
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'PAYROLL SLIP',
                            style: TextStyle(
                              color: Color(0xFF65716B),
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isPakyaw ? 'PAKYAW' : 'DRIVER PAY',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLabel(record.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: Color(0xFF173B35), thickness: 1.4),
                ),
                _PreviewMeta(
                  label: 'Reference',
                  value: record.reference.isEmpty ? '-' : record.reference,
                ),
                if (isPakyaw)
                  _PreviewMeta(
                    label: 'Work details',
                    value: record.description.isEmpty
                        ? '-'
                        : record.description,
                  )
                else ...[
                  _PreviewMeta(
                    label: 'Destination',
                    value: record.destination.isEmpty
                        ? '-'
                        : record.destination,
                  ),
                  _PreviewMeta(
                    label: 'Truck',
                    value: record.truckPlate.isEmpty ? '-' : record.truckPlate,
                  ),
                  _PreviewMeta(label: 'Trips', value: '${record.tripCount}'),
                  _PreviewMeta(
                    label: 'Rate per trip',
                    value: money(record.ratePerTrip),
                  ),
                ],
                const SizedBox(height: 18),
                const Divider(),
                if (compactPreview)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('PAYROLL DETAILS', style: _tableHead),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text('WORKER / DRIVER', style: _tableHead),
                        ),
                        Expanded(
                          child: Text(
                            'GROSS',
                            textAlign: TextAlign.right,
                            style: _tableHead,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'DEDUCT.',
                            textAlign: TextAlign.right,
                            style: _tableHead,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'NET',
                            textAlign: TextAlign.right,
                            style: _tableHead,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                ...record.lines.map(
                  (line) => compactPreview
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.workerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CompactFigure(
                                      label: 'Gross',
                                      value: money(line.gross),
                                    ),
                                  ),
                                  Expanded(
                                    child: _CompactFigure(
                                      label: 'Deduction',
                                      value: money(line.deduction),
                                    ),
                                  ),
                                  Expanded(
                                    child: _CompactFigure(
                                      label: 'Net',
                                      value: money(line.net),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  line.workerName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  money(line.gross),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  money(line.deduction),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  money(line.net),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const Divider(),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      children: [
                        _PreviewTotal('Gross total', money(record.totalGross)),
                        const SizedBox(height: 7),
                        _PreviewTotal(
                          'Total deductions',
                          money(record.totalDeduction),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        _PreviewTotal(
                          'NET PAY',
                          money(record.totalNet),
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 54),
                Row(
                  children: [
                    Expanded(child: _PreviewSignature(label: 'Prepared by')),
                    const SizedBox(width: 28),
                    Expanded(child: _PreviewSignature(label: 'Received by')),
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Generated by KartapPay',
                    style: TextStyle(color: Color(0xFF7A857F), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _tableHead = TextStyle(
  fontSize: 8,
  fontWeight: FontWeight.w800,
  color: Color(0xFF65716B),
);

class _PreviewMeta extends StatelessWidget {
  const _PreviewMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF65716B), fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _CompactFigure extends StatelessWidget {
  const _CompactFigure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF65716B), fontSize: 9),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _PreviewTotal extends StatelessWidget {
  const _PreviewTotal(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: strong ? 14 : 11,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: strong ? 14 : 11,
          fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PreviewSignature extends StatelessWidget {
  const _PreviewSignature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Divider(color: Color(0xFF8A938D)),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF65716B)),
      ),
    ],
  );
}
