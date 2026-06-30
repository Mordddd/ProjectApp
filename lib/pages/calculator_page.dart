import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_components.dart';
import 'dart:math';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  int _selectedTab = 0; // 0: Kalkulator, 1: Geometri

  // Kalkulator
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();

  String? _result;
  String? _selectedOperation;
  String? _errorMessage;

  // Geometri
  int _selectedShape = 0; // 0: Segitiga, 1: Lingkaran, 2: Persegi, 3: Tabung
  final TextEditingController _shapeInput1 = TextEditingController();
  final TextEditingController _shapeInput2 = TextEditingController();
  String? _geometryResult;
  String? _geometryError;

  final List<Map<String, dynamic>> _operations = [
    {'symbol': '+', 'name': 'Tambah', 'color': const Color(0xFF10B981)},
    {'symbol': '-', 'name': 'Kurang', 'color': const Color(0xFFF59E0B)},
    {'symbol': '×', 'name': 'Kali', 'color': AppPalette.navy},
    {'symbol': '÷', 'name': 'Bagi', 'color': const Color(0xFFEF4444)},
  ];

  final List<Map<String, dynamic>> _shapes = [
    {
      'name': 'Segitiga',
      'icon': Icons.change_history,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Lingkaran',
      'icon': Icons.circle_outlined,
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'Persegi',
      'icon': Icons.square_outlined,
      'color': const Color(0xFF10B981),
    },
    {'name': 'Tabung', 'icon': Icons.layers_outlined, 'color': AppPalette.navy},
  ];

  void _calculateGeometry() {
    setState(() {
      _geometryError = null;
    });

    switch (_selectedShape) {
      case 0: // Segitiga
        _calculateTriangle();
        break;
      case 1: // Lingkaran
        _calculateCircle();
        break;
      case 2: // Persegi
        _calculateSquare();
        break;
      case 3: // Tabung
        _calculateCylinder();
        break;
    }
  }

  void _calculateTriangle() {
    final base = double.tryParse(_shapeInput1.text);
    final height = double.tryParse(_shapeInput2.text);

    if (base == null || height == null || base <= 0 || height <= 0) {
      setState(() {
        _geometryError = 'Masukkan alas dan tinggi yang valid (> 0)';
        _geometryResult = null;
      });
      return;
    }

    final area = (base * height) / 2;
    setState(() {
      _geometryResult = area.toStringAsFixed(2);
    });
  }

  void _calculateCircle() {
    final radius = double.tryParse(_shapeInput1.text);

    if (radius == null || radius <= 0) {
      setState(() {
        _geometryError = 'Masukkan jari-jari yang valid (> 0)';
        _geometryResult = null;
      });
      return;
    }

    final area = pi * radius * radius;
    setState(() {
      _geometryResult = area.toStringAsFixed(2);
    });
  }

  void _calculateSquare() {
    final length = double.tryParse(_shapeInput1.text);
    final width = double.tryParse(_shapeInput2.text);

    if (length == null || width == null || length <= 0 || width <= 0) {
      setState(() {
        _geometryError = 'Masukkan panjang dan lebar yang valid (> 0)';
        _geometryResult = null;
      });
      return;
    }

    final area = length * width;
    setState(() {
      _geometryResult = area.toStringAsFixed(2);
    });
  }

  void _calculateCylinder() {
    final radius = double.tryParse(_shapeInput1.text);
    final height = double.tryParse(_shapeInput2.text);

    if (radius == null || height == null || radius <= 0 || height <= 0) {
      setState(() {
        _geometryError = 'Masukkan jari-jari dan tinggi yang valid (> 0)';
        _geometryResult = null;
      });
      return;
    }

    final volume = pi * radius * radius * height;
    setState(() {
      _geometryResult = volume.toStringAsFixed(2);
    });
  }

  void _clearGeometry() {
    setState(() {
      _shapeInput1.clear();
      _shapeInput2.clear();
      _geometryResult = null;
      _geometryError = null;
    });
  }

  String _getResultLabel(int index) {
    switch (index) {
      case 0:
        return 'Luas Segitiga';
      case 1:
        return 'Luas Lingkaran';
      case 2:
        return 'Luas Persegi';
      case 3:
        return 'Volume Tabung';
      default:
        return 'Hasil';
    }
  }

  void _calculate(String operation) {
    setState(() {
      _errorMessage = null;
      _selectedOperation = operation;
    });

    final num1 = double.tryParse(_num1Controller.text);
    final num2 = double.tryParse(_num2Controller.text);

    if (num1 == null || num2 == null) {
      setState(() {
        _errorMessage = 'Masukkan angka yang valid';
        _result = null;
      });
      return;
    }

    double result;
    switch (operation) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '×':
        result = num1 * num2;
        break;
      case '÷':
        if (num2 == 0) {
          setState(() {
            _errorMessage = 'Tidak bisa membagi dengan nol';
            _result = null;
          });
          return;
        }
        result = num1 / num2;
        break;
      default:
        return;
    }

    setState(() {
      _result = result.toStringAsFixed(
        result.truncateToDouble() == result ? 0 : 2,
      );
    });
  }

  void _clear() {
    setState(() {
      _num1Controller.clear();
      _num2Controller.clear();
      _result = null;
      _selectedOperation = null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    _shapeInput1.dispose();
    _shapeInput2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Kalkulator'),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? AppPalette.navy
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Kalkulator',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : AppPalette.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? AppPalette.navy
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Geometri',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : AppPalette.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildCalculatorTab()
                : _buildGeometryTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Card
          Card(
            color: AppPalette.navy,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator Sederhana',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hitung operasi matematika dasar',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Input Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Angka',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Number Inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _num1Controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Angka 1',
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppPalette.navy,
                                width: 2,
                              ),
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _num2Controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Angka 2',
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppPalette.navy,
                                width: 2,
                              ),
                            ),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Operation Buttons
                  Text(
                    'Pilih Operasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: _operations.map((op) {
                      final isSelected = _selectedOperation == op['symbol'];
                      return Material(
                        color: isSelected
                            ? op['color']
                            : (op['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _calculate(op['symbol']),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: op['color'], width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  op['symbol'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : op['color'],
                                  ),
                                ),
                                Text(
                                  op['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : op['color'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Result Card
          if (_result != null)
            Card(
              color: const Color(0xFF10B981),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Hasil',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _num1Controller.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _selectedOperation ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          _num2Controller.text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          ' = ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result!,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Clear Button
          CustomButton(
            text: 'Reset',
            icon: Icons.refresh_rounded,
            onPressed: _clear,
            isOutlined: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildGeometryTab() {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Card
          Card(
            color: const Color(0xFF8B5CF6),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.square_foot_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator Geometri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hitung luas dan volume',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Shape Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Bangun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(_shapes.length, (index) {
                      final isSelected = _selectedShape == index;
                      return Material(
                        color: isSelected
                            ? _shapes[index]['color']
                            : (_shapes[index]['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => setState(() => _selectedShape = index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _shapes[index]['color'],
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _shapes[index]['icon'],
                                  size: 28,
                                  color: isSelected
                                      ? Colors.white
                                      : _shapes[index]['color'],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _shapes[index]['name'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : _shapes[index]['color'],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Input Fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedShape == 0 ||
                      _selectedShape == 2 ||
                      _selectedShape == 3)
                    TextField(
                      controller: _shapeInput1,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _selectedShape == 0
                            ? 'Alas'
                            : _selectedShape == 2
                            ? 'Panjang'
                            : 'Jari-jari',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B5CF6),
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (_selectedShape == 0 ||
                      _selectedShape == 2 ||
                      _selectedShape == 3) ...[
                    const SizedBox(height: 16),
                  ],
                  if (_selectedShape == 0 ||
                      _selectedShape == 2 ||
                      _selectedShape == 3)
                    TextField(
                      controller: _shapeInput2,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _selectedShape == 0
                            ? 'Tinggi'
                            : _selectedShape == 2
                            ? 'Lebar'
                            : 'Tinggi',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B5CF6),
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (_selectedShape == 1)
                    TextField(
                      controller: _shapeInput1,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Jari-jari',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B5CF6),
                            width: 2,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  if (_geometryError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _geometryError!,
                              style: const TextStyle(
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Calculate Button
          CustomButton(
            text: 'Hitung',
            icon: Icons.calculate_rounded,
            onPressed: _calculateGeometry,
            width: double.infinity,
          ),

          const SizedBox(height: 20),

          // Result Card
          if (_geometryResult != null)
            Card(
              color: _shapes[_selectedShape]['color'],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _getResultLabel(_selectedShape),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _geometryResult!,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Clear Button
          CustomButton(
            text: 'Reset',
            icon: Icons.refresh_rounded,
            onPressed: _clearGeometry,
            isOutlined: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
