import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'models.dart';
import 'payroll_store.dart';
import 'slip_page.dart';

final _currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
final _dateFormat = DateFormat('dd MMM yyyy');

String money(num value) => _currency.format(value);
String dateLabel(DateTime value) => _dateFormat.format(value);
String newId() => DateTime.now().microsecondsSinceEpoch.toString();

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.records,
    required this.workers,
    required this.trucks,
    required this.onNewPakyaw,
    required this.onNewDriver,
    required this.onViewRecords,
  });

  final List<PayrollRecord> records;
  final List<Worker> workers;
  final List<Truck> trucks;
  final VoidCallback onNewPakyaw;
  final VoidCallback onNewDriver;
  final VoidCallback onViewRecords;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayRecords = records.where(
      (record) =>
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day,
    );
    final todayTotal = todayRecords.fold<double>(
      0,
      (total, record) => total + record.totalNet,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF173B35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments_outlined, color: Colors.white),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'KartapPay',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              DateFormat('EEE, d MMM').format(today),
              style: const TextStyle(color: Color(0xFF65716B)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: const Color(0xFF173B35),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TODAY'S PAYROLL",
                style: TextStyle(
                  color: Color(0xFFC9D8D0),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                money(todayTotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _HeroMetric(
                    label: 'PAYROLLS',
                    value: '${todayRecords.length}',
                  ),
                  const SizedBox(width: 30),
                  _HeroMetric(label: 'WORKERS', value: '${workers.length}'),
                  const SizedBox(width: 30),
                  _HeroMetric(label: 'TRUCKS', value: '${trucks.length}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Create payroll', trailing: 'NEW'),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.construction_outlined,
                title: 'Pakyaw',
                subtitle: 'Split job pay',
                color: const Color(0xFFE9B948),
                onTap: onNewPakyaw,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.local_shipping_outlined,
                title: 'Driver',
                subtitle: 'Trips & rate',
                color: const Color(0xFFB7D4C1),
                onTap: onNewDriver,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _SectionHeading(
          title: 'Recent records',
          trailing: 'SEE ALL',
          onTap: onViewRecords,
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          const _EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Wala pang payroll record',
            subtitle: 'Create a payroll to see it here.',
          )
        else
          ...records
              .take(3)
              .map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _RecordTile(record: record),
                ),
              ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC9D8D0),
          fontSize: 10,
          letterSpacing: .7,
        ),
      ),
    ],
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: const Color(0xFF173B35), size: 21),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF65716B), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, required this.records});

  final List<PayrollRecord> records;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final visible = widget.records
        .where((record) => _filter == 'all' || record.kind == _filter)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 21, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payroll records',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.records.length} saved payrolls',
                style: const TextStyle(color: Color(0xFF65716B)),
              ),
              const SizedBox(height: 17),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'pakyaw', label: Text('Pakyaw')),
                  ButtonSegment(value: 'driver', label: Text('Driver')),
                ],
                selected: {_filter},
                onSelectionChanged: (value) =>
                    setState(() => _filter = value.first),
                showSelectedIcon: false,
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const _EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No records yet',
                  subtitle: 'Your saved payrolls will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) =>
                      _RecordTile(record: visible[index]),
                ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PayrollRecord record;

  @override
  Widget build(BuildContext context) {
    final isPakyaw = record.kind == 'pakyaw';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => SlipPage(record: record))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isPakyaw
                      ? const Color(0xFFFFF1CF)
                      : const Color(0xFFE2EEE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPakyaw
                      ? Icons.construction_outlined
                      : Icons.local_shipping_outlined,
                  color: const Color(0xFF173B35),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.reference.isEmpty
                          ? (isPakyaw ? 'Pakyaw job' : 'Driver trip')
                          : record.reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${dateLabel(record.date)}  ·  ${record.lines.length} ${record.lines.length == 1 ? 'worker' : 'workers'}',
                      style: const TextStyle(
                        color: Color(0xFF65716B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(record.totalNet),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'NET PAY',
                    style: TextStyle(
                      color: Color(0xFF65716B),
                      fontSize: 9,
                      letterSpacing: .5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({
    super.key,
    required this.store,
    required this.workers,
    required this.trucks,
    required this.onChanged,
  });

  final PayrollStore store;
  final List<Worker> workers;
  final List<Truck> trucks;
  final Future<void> Function() onChanged;

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  int _section = 0;

  Future<void> _workerDialog([Worker? worker]) async {
    final name = TextEditingController(text: worker?.name ?? '');
    final contact = TextEditingController(text: worker?.contact ?? '');
    var type = worker?.type ?? WorkerType.pakyaw;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(worker == null ? 'Add worker' : 'Edit worker'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WorkerType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Worker type'),
                items: const [
                  DropdownMenuItem(
                    value: WorkerType.pakyaw,
                    child: Text('Pakyaw worker'),
                  ),
                  DropdownMenuItem(
                    value: WorkerType.driver,
                    child: Text('Truck driver'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => type = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await widget.store.saveWorker(
                  Worker(
                    id: worker?.id ?? newId(),
                    name: name.text.trim(),
                    contact: contact.text.trim(),
                    type: type,
                  ),
                );
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    contact.dispose();
    if (result == true) await widget.onChanged();
  }

  Future<void> _truckDialog([Truck? truck]) async {
    final plate = TextEditingController(text: truck?.plate ?? '');
    var driverId = truck?.driverId ?? '';
    final drivers = widget.workers
        .where((worker) => worker.type == WorkerType.driver)
        .toList();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(truck == null ? 'Add truck' : 'Edit truck'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plate,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Plate number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: drivers.any((driver) => driver.id == driverId)
                    ? driverId
                    : '',
                decoration: const InputDecoration(labelText: 'Assigned driver'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Unassigned')),
                  ...drivers.map(
                    (driver) => DropdownMenuItem(
                      value: driver.id,
                      child: Text(driver.name),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => driverId = value ?? ''),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (plate.text.trim().isEmpty) return;
                await widget.store.saveTruck(
                  Truck(
                    id: truck?.id ?? newId(),
                    plate: plate.text.trim().toUpperCase(),
                    driverId: driverId.isEmpty ? null : driverId,
                  ),
                );
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    plate.dispose();
    if (result == true) await widget.onChanged();
  }

  Future<void> _delete(String title, Future<void> Function() action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $title?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await action();
      await widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPeople = _section == 0;
    final drivers = widget.workers
        .where((worker) => worker.type == WorkerType.driver)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 21, 20, 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'People & fleet',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filled(
                tooltip: isPeople ? 'Add worker' : 'Add truck',
                onPressed: () => isPeople ? _workerDialog() : _truckDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Workers')),
              ButtonSegment(value: 1, label: Text('Trucks')),
            ],
            selected: {_section},
            onSelectionChanged: (value) =>
                setState(() => _section = value.first),
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 13),
        Expanded(
          child: isPeople
              ? widget.workers.isEmpty
                    ? const _EmptyState(
                        icon: Icons.groups_2_outlined,
                        title: 'No workers added',
                        subtitle: 'Add workers and drivers to start payroll.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: widget.workers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final worker = widget.workers[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE2EEE5),
                                foregroundColor: const Color(0xFF173B35),
                                child: Icon(
                                  worker.type == WorkerType.driver
                                      ? Icons.local_shipping_outlined
                                      : Icons.person_outline,
                                ),
                              ),
                              title: Text(
                                worker.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${worker.type == WorkerType.driver ? 'Truck driver' : 'Pakyaw worker'}${worker.contact.isEmpty ? '' : ' · ${worker.contact}'}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') _workerDialog(worker);
                                  if (value == 'delete') {
                                    _delete(
                                      worker.name,
                                      () =>
                                          widget.store.deleteWorker(worker.id),
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
              : widget.trucks.isEmpty
              ? const _EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'No trucks added',
                  subtitle: 'Add truck plate numbers and assign drivers.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: widget.trucks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final truck = widget.trucks[index];
                    final assigned = drivers.where(
                      (worker) => worker.id == truck.driverId,
                    );
                    final driverName = assigned.isEmpty
                        ? 'Unassigned'
                        : assigned.first.name;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF1CF),
                          foregroundColor: Color(0xFF173B35),
                          child: Icon(Icons.local_shipping_outlined),
                        ),
                        title: Text(
                          truck.plate,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('Driver: $driverName'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _truckDialog(truck);
                            if (value == 'delete') {
                              _delete(
                                truck.plate,
                                () => widget.store.deleteTruck(truck.id),
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class PakyawPayrollScreen extends StatefulWidget {
  const PakyawPayrollScreen({
    super.key,
    required this.store,
    required this.workers,
  });

  final PayrollStore store;
  final List<Worker> workers;

  @override
  State<PakyawPayrollScreen> createState() => _PakyawPayrollScreenState();
}

class _PakyawPayrollScreenState extends State<PakyawPayrollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _description = TextEditingController();
  final Map<String, TextEditingController> _shares = {};
  final Set<String> _selected = {};
  DateTime _date = DateTime.now();
  bool _saving = false;

  List<Worker> get _eligible => widget.workers
      .where((worker) => worker.type == WorkerType.pakyaw)
      .toList();
  double get _total => double.tryParse(_amount.text) ?? 0;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _description.dispose();
    for (final controller in _shares.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _redistribute() {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final amounts = equalShares(_total, ids.length);
    for (var index = 0; index < ids.length; index++) {
      _shares.putIfAbsent(ids[index], TextEditingController.new).text =
          amounts[index].toStringAsFixed(2);
    }
  }

  int get _shareCents => _selected.fold<int>(0, (total, id) {
    final value = double.tryParse(_shares[id]?.text ?? '') ?? 0;
    return total + (value * 100).round();
  });

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selected.isEmpty) {
      _notice('Select at least one worker.');
      return;
    }
    final targetCents = (_total * 100).round();
    if (_shareCents != targetCents) {
      _notice('Adjusted shares must add up to ${money(_total)}.');
      return;
    }
    setState(() => _saving = true);
    final lines = _eligible
        .where((worker) => _selected.contains(worker.id))
        .map(
          (worker) => PayrollLine(
            workerId: worker.id,
            workerName: worker.name,
            gross: (double.tryParse(_shares[worker.id]?.text ?? '') ?? 0),
          ),
        )
        .toList();
    await widget.store.saveRecord(
      PayrollRecord(
        id: newId(),
        kind: 'pakyaw',
        date: _date,
        reference: _reference.text.trim(),
        description: _description.text.trim(),
        lines: lines,
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _notice(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New pakyaw payroll')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _FormIntro(
              icon: Icons.construction_outlined,
              title: 'Job payment',
              subtitle:
                  'Add the job details, then split the amount among the crew.',
            ),
            const SizedBox(height: 19),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Total pakyaw amount',
                prefixText: '₱ ',
              ),
              validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                  ? 'Enter an amount above zero'
                  : null,
              onChanged: (_) {
                setState(_redistribute);
              },
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _reference,
              decoration: const InputDecoration(
                labelText: 'Job reference (optional)',
              ),
            ),
            const SizedBox(height: 13),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Work description'),
            ),
            const SizedBox(height: 13),
            _DateField(date: _date, onTap: _pickDate),
            const SizedBox(height: 23),
            const _SectionHeading(title: 'Who worked on this job?'),
            const SizedBox(height: 8),
            if (_eligible.isEmpty)
              const _EmptyState(
                icon: Icons.person_add_alt_1,
                title: 'No pakyaw workers yet',
                subtitle: 'Add pakyaw workers from the People tab first.',
              )
            else
              ..._eligible.map(
                (worker) => Card(
                  margin: const EdgeInsets.only(bottom: 7),
                  child: CheckboxListTile(
                    value: _selected.contains(worker.id),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(worker.id);
                        _shares.putIfAbsent(
                          worker.id,
                          () => TextEditingController(),
                        );
                      } else {
                        _selected.remove(worker.id);
                      }
                      _redistribute();
                    }),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      worker.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: worker.contact.isEmpty
                        ? null
                        : Text(worker.contact),
                  ),
                ),
              ),
            if (_selected.isNotEmpty) ...[
              const SizedBox(height: 14),
              const _SectionHeading(title: 'Share per worker'),
              const SizedBox(height: 4),
              const Text(
                'Equal shares are pre-filled. Edit an amount if needed; total shares must match the job amount.',
                style: TextStyle(color: Color(0xFF65716B), fontSize: 12),
              ),
              const SizedBox(height: 10),
              ..._eligible
                  .where((worker) => _selected.contains(worker.id))
                  .map(
                    (worker) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: TextFormField(
                        controller: _shares[worker.id],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: worker.name,
                          prefixText: '₱ ',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _shareCents == (_total * 100).round()
                      ? const Color(0xFFE2EEE5)
                      : const Color(0xFFFFF1CF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(child: Text('Assigned total')),
                    Text(
                      money(_shareCents / 100),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving || _eligible.isEmpty ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save payroll'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverPayrollScreen extends StatefulWidget {
  const DriverPayrollScreen({
    super.key,
    required this.store,
    required this.workers,
    required this.trucks,
  });

  final PayrollStore store;
  final List<Worker> workers;
  final List<Truck> trucks;

  @override
  State<DriverPayrollScreen> createState() => _DriverPayrollScreenState();
}

class _DriverPayrollScreenState extends State<DriverPayrollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trips = TextEditingController(text: '1');
  final _rate = TextEditingController();
  final _deduction = TextEditingController(text: '0');
  final _destination = TextEditingController();
  final _reference = TextEditingController();
  DateTime _date = DateTime.now();
  String? _driverId;
  String? _truckId;
  bool _saving = false;

  List<Worker> get _drivers => widget.workers
      .where((worker) => worker.type == WorkerType.driver)
      .toList();
  int get _tripCount => int.tryParse(_trips.text) ?? 0;
  double get _gross => _tripCount * (double.tryParse(_rate.text) ?? 0);
  double get _deductionAmount => double.tryParse(_deduction.text) ?? 0;

  @override
  void dispose() {
    _trips.dispose();
    _rate.dispose();
    _deduction.dispose();
    _destination.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_drivers.isEmpty) return;
    final selectedDriverId = _driverId ?? _drivers.first.id;
    final driver = _drivers.firstWhere(
      (worker) => worker.id == selectedDriverId,
    );
    final truck = widget.trucks.where((value) => value.id == _truckId);
    setState(() => _saving = true);
    await widget.store.saveRecord(
      PayrollRecord(
        id: newId(),
        kind: 'driver',
        date: _date,
        reference: _reference.text.trim(),
        description: '$_tripCount ${_tripCount == 1 ? 'trip' : 'trips'}',
        destination: _destination.text.trim(),
        truckPlate: truck.isEmpty ? '' : truck.first.plate,
        tripCount: _tripCount,
        ratePerTrip: double.tryParse(_rate.text) ?? 0,
        lines: [
          PayrollLine(
            workerId: driver.id,
            workerName: driver.name,
            gross: _gross,
            deduction: _deductionAmount,
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New driver payroll')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _FormIntro(
              icon: Icons.local_shipping_outlined,
              title: 'Driver trip pay',
              subtitle:
                  'Trip total is calculated from the rate and trip count.',
            ),
            const SizedBox(height: 19),
            if (_drivers.isEmpty)
              const _EmptyState(
                icon: Icons.person_add_alt_1,
                title: 'No drivers added',
                subtitle: 'Add a truck driver from the People tab first.',
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _driverId ?? _drivers.first.id,
                decoration: const InputDecoration(labelText: 'Driver'),
                items: _drivers
                    .map(
                      (driver) => DropdownMenuItem(
                        value: driver.id,
                        child: Text(driver.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _driverId = value),
              ),
              const SizedBox(height: 13),
              DropdownButtonFormField<String>(
                initialValue: _truckId ?? '',
                decoration: const InputDecoration(
                  labelText: 'Truck (optional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('No truck selected'),
                  ),
                  ...widget.trucks.map(
                    (truck) => DropdownMenuItem(
                      value: truck.id,
                      child: Text(truck.plate),
                    ),
                  ),
                ],
                onChanged: (value) => setState(
                  () =>
                      _truckId = value == null || value.isEmpty ? null : value,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _trips,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'No. of trips',
                      ),
                      validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                          ? 'Enter 1 or more'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: TextFormField(
                      controller: _rate,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Rate / trip',
                        prefixText: '₱ ',
                      ),
                      validator: (value) =>
                          (double.tryParse(value ?? '') ?? 0) <= 0
                          ? 'Enter a rate'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              TextFormField(
                controller: _destination,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 13),
              TextFormField(
                controller: _reference,
                decoration: const InputDecoration(
                  labelText: 'Trip / payroll reference (optional)',
                ),
              ),
              const SizedBox(height: 13),
              _DateField(date: _date, onTap: _pickDate),
              const SizedBox(height: 13),
              TextFormField(
                controller: _deduction,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Deductions (optional)',
                  prefixText: '₱ ',
                ),
                validator: (value) {
                  final deduction = double.tryParse(value ?? '') ?? 0;
                  if (deduction < 0) return 'Cannot be negative';
                  if (deduction > _gross) return 'Cannot exceed gross pay';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2EEE5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    _TotalRow(label: 'Gross pay', value: money(_gross)),
                    const SizedBox(height: 8),
                    _TotalRow(
                      label: 'Deductions',
                      value: '- ${money(_deductionAmount)}',
                    ),
                    const Divider(height: 20),
                    _TotalRow(
                      label: 'Net pay',
                      value: money(_gross - _deductionAmount),
                      strong: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _saving || _drivers.isEmpty ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save payroll'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Payroll date'),
      child: Row(
        children: [
          Expanded(child: Text(dateLabel(date))),
          const Icon(Icons.calendar_today_outlined, size: 18),
        ],
      ),
    ),
  );
}

class _FormIntro extends StatelessWidget {
  const _FormIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 47,
        height: 47,
        decoration: BoxDecoration(
          color: const Color(0xFFE2EEE5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: const Color(0xFF173B35)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF65716B)),
            ),
          ],
        ),
      ),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing, this.onTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      if (trailing != null)
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: const Color(0xFF527064),
          ),
          child: Text(
            trailing!,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
    child: Column(
      children: [
        Icon(icon, size: 31, color: const Color(0xFF718079)),
        const SizedBox(height: 9),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF65716B), fontSize: 12),
        ),
      ],
    ),
  );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

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
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            fontSize: strong ? 16 : 14,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          fontSize: strong ? 17 : 14,
        ),
      ),
    ],
  );
}
