import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Ví dụ về cách sử dụng AppTheme trong các widget khác nhau
/// UPDATED: Fixed text visibility issues in both light and dark themes
class ThemeExamples extends StatefulWidget {
  const ThemeExamples({super.key});

  @override
  State<ThemeExamples> createState() => _ThemeExamplesFixedState();
}

class _ThemeExamplesFixedState extends State<ThemeExamples> {
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
      child: Builder(
        // Wrap with Builder to get correct theme context
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Theme Examples (Fixed)'),
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
                // Theme indicator
                _buildThemeIndicator(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 1. Color palette
                _buildColorSection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 2. Typography
                _buildTypographySection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 3. Cards
                _buildCardSection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 4. Buttons
                _buildButtonSection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 5. Form Elements
                _buildFormSection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 6. Text on different backgrounds
                _buildTextContrastSection(context),
                const SizedBox(height: AppTheme.spacingLarge),

                // 7. List items
                _buildListSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            'Current theme: ${isDarkMode ? 'Dark' : 'Light'} Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Color Palette',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          'Colors automatically adapt to theme',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        Wrap(
          spacing: AppTheme.spacingMedium,
          runSpacing: AppTheme.spacingMedium,
          children: [
            _buildColorBox(
              context,
              'Primary',
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary,
            ),
            _buildColorBox(
              context,
              'Secondary',
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.onSecondary,
            ),
            _buildColorBox(
              context,
              'Error',
              Theme.of(context).colorScheme.error,
              Theme.of(context).colorScheme.onError,
            ),
            _buildColorBox(
              context,
              'Surface',
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorBox(
    BuildContext context,
    String name,
    Color backgroundColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'Aa',
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          '2. Typography Styles',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Display styles
        Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
        Text(
          'Headline Large',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          'Headline Medium',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          'Headline Small',
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: AppTheme.spacingSmall),
        const Divider(),
        const SizedBox(height: AppTheme.spacingSmall),

        // Title styles
        Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
        Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
        Text('Title Small', style: Theme.of(context).textTheme.titleSmall),

        const SizedBox(height: AppTheme.spacingSmall),
        const Divider(),
        const SizedBox(height: AppTheme.spacingSmall),

        // Body styles
        Text(
          'Body Large - This is the main body text used for most content. '
          'It should be easily readable on both light and dark backgrounds.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Body Medium - Slightly smaller text for secondary content. '
          'Still very readable and commonly used.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Body Small - Used for captions, helper text, and less important information.',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        const SizedBox(height: AppTheme.spacingSmall),
        const Divider(),
        const SizedBox(height: AppTheme.spacingSmall),

        // Label styles
        Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
        Text('Label Medium', style: Theme.of(context).textTheme.labelMedium),
        Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _buildCardSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. Card Components',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Standard card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      'Thông tin bệnh nhân',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                const Divider(),
                const SizedBox(height: AppTheme.spacingSmall),
                _buildInfoRow(context, 'Họ tên:', 'Nguyễn Văn A'),
                _buildInfoRow(context, 'Tuổi:', '25'),
                _buildInfoRow(context, 'Giới tính:', 'Nam'),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Cập nhật: 2 phút trước',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacingSmall),

        // Card with colored background
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      'Thông báo quan trọng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Đây là một thông báo với background màu primary. '
                  'Text color tự động điều chỉnh để đảm bảo contrast.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '4. Button Styles',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        Wrap(
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('With Icon'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            TextButton(onPressed: () {}, child: const Text('Text Button')),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/signalr-test'),
              icon: const Icon(Icons.access_time),
              label: const Text('Test SignalR'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/map-test'),
              icon: const Icon(Icons.access_time),
              label: const Text('Test Location Tracker'),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingMedium),

        // Full width button example
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.emergency),
            label: const Text('Gọi cấp cứu'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5. Form Input Fields',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

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
            helperText: 'Ví dụ: 0901234567',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        const TextField(
          decoration: InputDecoration(
            labelText: 'Mô tả triệu chứng',
            hintText: 'Mô tả chi tiết triệu chứng',
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Dropdown example
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Loại rắn',
            prefixIcon: Icon(Icons.catching_pokemon),
          ),
          items: const [
            DropdownMenuItem(value: 'cobra', child: Text('Rắn hổ mang')),
            DropdownMenuItem(value: 'viper', child: Text('Rắn lục')),
            DropdownMenuItem(value: 'unknown', child: Text('Không rõ')),
          ],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildTextContrastSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6. Text Contrast Testing',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Text on primary color
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text on Primary Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Text(
                'This text uses onPrimary color for proper contrast',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingSmall),

        // Text on secondary color
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text on Secondary Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              Text(
                'This text uses onSecondary color for proper contrast',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingSmall),

        // Text on surface (card)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text on Surface (Card)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'This text uses onSurface color - perfect for cards and dialogs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('7. List Items', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTheme.spacingMedium),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.emergency,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                title: Text(
                  'Trường hợp cấp cứu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Xử lý ngay lập tức',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Icon(
                    Icons.chat,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                title: Text(
                  'Tư vấn trực tuyến',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Hỏi đáp với chuyên gia',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                title: Text(
                  'Lịch sử khám bệnh',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'Xem các trường hợp đã xử lý',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
