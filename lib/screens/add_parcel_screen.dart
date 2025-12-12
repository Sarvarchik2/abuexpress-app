import 'package:flutter/material.dart';
import '../models/parcel.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;

class AddParcelScreen extends StatefulWidget {
  const AddParcelScreen({super.key});

  @override
  State<AddParcelScreen> createState() => _AddParcelScreenState();
}

class _AddParcelScreenState extends State<AddParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trackNumberController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _costController = TextEditingController(text: '100.00');
  final _weightController = TextEditingController(text: '1.5');
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _trackNumberController.dispose();
    _storeNameController.dispose();
    _productNameController.dispose();
    _productLinkController.dispose();
    _costController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Добавить посылку',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField(
              label: 'Трек-номер',
              controller: _trackNumberController,
              hint: 'Например: 1Z999AA10123456784',
              icon: Icons.inbox_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Название магазина',
              controller: _storeNameController,
              hint: 'Amazon, AliExpress и т.д.',
              icon: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Название товара',
              controller: _productNameController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Ссылка на товар',
              controller: _productLinkController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Стоимость (\$)',
              controller: _costController,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Вес (кг)',
              controller: _weightController,
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Цвет',
              controller: _colorController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Размер',
              controller: _sizeController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Количество',
              controller: _quantityController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Комментарий для оператора',
              controller: _commentController,
              hint: 'Краткое описание содержимого посылки',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            _buildAddButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textColor),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: textSecondaryColor,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final parcel = Parcel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            trackNumber: _trackNumberController.text.isEmpty
                ? 'ABU${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
                : _trackNumberController.text,
            storeName: _storeNameController.text.isEmpty
                ? 'Не указано'
                : _storeNameController.text,
            productName: _productNameController.text.isEmpty
                ? 'Товар'
                : _productNameController.text,
            productLink: _productLinkController.text.isEmpty
                ? null
                : _productLinkController.text,
            cost: double.tryParse(_costController.text) ?? 0.0,
            weight: double.tryParse(_weightController.text) ?? 0.0,
            color: _colorController.text.isEmpty ? null : _colorController.text,
            size: _sizeController.text.isEmpty ? null : _sizeController.text,
            quantity: int.tryParse(_quantityController.text) ?? 1,
            comment: _commentController.text.isEmpty
                ? null
                : _commentController.text,
            status: 'На складе',
            dateAdded: DateTime.now(),
          );

          Navigator.pop(context, parcel);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Посылка добавлена'),
              backgroundColor: Color(0xFFFFD700),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Добавить посылку',
          style: TextStyle(
            color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

