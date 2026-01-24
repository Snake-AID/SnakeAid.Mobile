import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Ví dụ về cách sử dụng AppTheme trong các widget khác nhau
class ThemeExamples extends StatefulWidget {
  const ThemeExamples({super.key});

  @override
  State<ThemeExamples> createState() => _ThemeExamplesState();
}

class _ThemeExamplesState extends State<ThemeExamples> {
  bool isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Examples'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle Theme',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sử dụng màu sắc từ AppTheme
              _buildColorSection(),
              const SizedBox(height: AppTheme.spacingLarge),

              // 2. Sử dụng Typography
              _buildTypographySection(context),
              const SizedBox(height: AppTheme.spacingLarge),

              // 3. Sử dụng Cards
              _buildCardSection(context),
              const SizedBox(height: AppTheme.spacingLarge),

              // 4. Sử dụng Buttons
              _buildButtonSection(),
              const SizedBox(height: AppTheme.spacingLarge),

              // 5. Sử dụng Form Elements
              _buildFormSection(),
              const SizedBox(height: AppTheme.spacingLarge),

              // 6. Sử dụng utility methods
              _buildUtilitySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Màu sắc từ AppTheme:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: [
            _buildColorBox('Primary', AppTheme.primaryColor),
            _buildColorBox('Secondary', AppTheme.secondaryColor),
            _buildColorBox('Error', AppTheme.errorColor),
            _buildColorBox('Text Primary', AppTheme.textPrimaryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildColorBox(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Typography từ Theme:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          'Headline Large',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          'Body Large - Đây là text chính',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Body Medium - Text phụ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          'Label Small - Caption text',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildCardSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. Cards với Theme:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin bệnh nhân',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Tên: Nguyễn Văn A',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text('Tuổi: 25', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  'Cập nhật: 2 phút trước',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4. Buttons với Theme:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(onPressed: () {}, child: const Text('Text Button')),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('With Icon'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5. Form Elements với Theme:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Tên bệnh nhân',
            hintText: 'Nhập tên bệnh nhân',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            hintText: 'Nhập số điện thoại',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Mô tả triệu chứng',
            hintText: 'Mô tả chi tiết triệu chứng',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildUtilitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6. Sử dụng Utility Methods:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Container với màu động',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Màu này sẽ thay đổi theo dark/light theme',
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget để demo Bottom Navigation với theme
class ThemeBottomNavExample extends StatefulWidget {
  const ThemeBottomNavExample({super.key});

  @override
  State<ThemeBottomNavExample> createState() => _ThemeBottomNavExampleState();
}

class _ThemeBottomNavExampleState extends State<ThemeBottomNavExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Navigation Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForIndex(_currentIndex),
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Tab ${_currentIndex + 1}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'Cấp cứu',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Tư vấn'),
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Bắt rắn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.emergency;
      case 1:
        return Icons.chat;
      case 2:
        return Icons.catching_pokemon;
      case 3:
        return Icons.person;
      default:
        return Icons.help;
    }
  }
}
