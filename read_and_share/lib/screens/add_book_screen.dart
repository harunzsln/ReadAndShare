import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:read_and_share/providers/book_provider.dart';
import 'package:read_and_share/screens/scan_screen.dart';
import 'package:read_and_share/services/book_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _isbnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final _service = BookService();

  @override
  void dispose() {
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (code != null && code.isNotEmpty) {
      _isbnController.text = code;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<BookProvider>();
      final book = await provider.addByIsbn(
        _isbnController.text.trim(),
        _service,
      );
      if (book == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('There is no result for this ISBN.')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${book.title}" added.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateIsbn(String? value) {
    final v = (value ?? '').replaceAll(RegExp(r'[^0-9Xx]'), '');
    if (v.isEmpty) return 'Input ISBN';
    if (v.length != 10 && v.length != 13)
      return 'ISBN must be 10 or 13 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitap Ekle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(
                    labelText: 'ISBN',
                    hintText: 'example: 9780131103627',
                    suffixIcon: IconButton(
                      onPressed: _scan,
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'QR/Barcode Scan',
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateIsbn,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download_outlined),
                    label: const Text('Fetch Book Info'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hint: You can input ISBN manuelly or you can scan barcode.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
