import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../services/avatar_service.dart';

class AvatarPickerSheet extends StatefulWidget {
  const AvatarPickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AvatarPickerSheet(),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> {
  bool _picking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_picking) return;
    setState(() => _picking = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);

      if (picked != null && mounted) {
        final avatarService = context.read<AvatarService>();
        avatarService.previewCustomImage(picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarService = context.watch<AvatarService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final txt = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final txtSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: txtSec.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Tu avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: txt)),
          const SizedBox(height: 4),
          Text('Elige un avatar o sube una foto', style: TextStyle(fontSize: 13, color: txtSec)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  color: AppColors.primary,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  color: AppColors.purple,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (avatarService.hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => avatarService.discardPreview(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 16, color: AppColors.danger),
                      SizedBox(width: 6),
                      Text('Deshacer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.danger)),
                    ],
                  ),
                ),
              ),
            ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, mainAxisSpacing: 10, crossAxisSpacing: 10,
            ),
            itemCount: AvatarService.defaults.length,
            itemBuilder: (context, index) {
              final opt = AvatarService.defaults[index];
              final isSelected = avatarService.previewSelectedId == opt.id && !avatarService.isPreviewCustom;
              return GestureDetector(
                onTap: () => avatarService.previewDefault(opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: opt.gradient,
                    ),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: opt.gradient.first.withValues(alpha: 0.6), blurRadius: 10, spreadRadius: 1)]
                        : [],
                  ),
                  child: Center(child: Text(opt.emoji, style: const TextStyle(fontSize: 20))),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: avatarService.hasUnsavedChanges
                  ? () async {
                      await avatarService.confirmChanges();
                      if (mounted) Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    avatarService.hasUnsavedChanges ? 'Confirmar cambios' : 'Sin cambios',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: avatarService.hasUnsavedChanges ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _picking ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _picking ? color.withValues(alpha: 0.05) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: _picking ? 0.1 : 0.2)),
        ),
        child: _picking
            ? const SizedBox(height: 40, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
            : Column(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 6),
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
      ),
    );
  }
}
