import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_profile.dart';
import '../providers/providers.dart';
import '../widgets/tag_input_field.dart';
import '../widgets/section_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _industryCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _productCtrl;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _industryCtrl = TextEditingController();
    _taglineCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _productCtrl = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _industryCtrl, _taglineCtrl,
      _ageCtrl, _genderCtrl, _productCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncFromProfile(BusinessProfile p) {
    _nameCtrl.text = p.businessName;
    _industryCtrl.text = p.industry;
    _taglineCtrl.text = p.tagline;
    _ageCtrl.text = p.ageRange;
    _genderCtrl.text = p.targetGender;
    _productCtrl.text = p.currentProduct;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(profileProvider);
    ref.read(profileProvider.notifier).update(
          current.copyWith(
            businessName: _nameCtrl.text.trim(),
            industry: _industryCtrl.text.trim(),
            tagline: _taglineCtrl.text.trim(),
            ageRange: _ageCtrl.text.trim(),
            targetGender: _genderCtrl.text.trim(),
            currentProduct: _productCtrl.text.trim(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    if (!_initialized) {
      _syncFromProfile(profile);
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: 'Brand Identity',
              children: [
                _field(_nameCtrl, 'Business name', required: true),
                _field(_industryCtrl, 'Industry', hint: 'e.g. Beauty & Wellness'),
                _field(_taglineCtrl, 'Tagline', hint: 'e.g. "Glow from within"'),
                const SizedBox(height: 8),
                const Text('Brand tones', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                TagInputField(
                  initialTags: profile.brandTones,
                  hint: 'Add tone and press Enter',
                  onChanged: (tags) => ref
                      .read(profileProvider.notifier)
                      .updateField((p) => p.copyWith(brandTones: tags)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Target Audience',
              children: [
                _field(_ageCtrl, 'Age range', hint: 'e.g. 25–40'),
                _field(_genderCtrl, 'Gender focus', hint: 'e.g. Primarily female'),
                const SizedBox(height: 8),
                const Text('Interests', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                TagInputField(
                  initialTags: profile.interests,
                  hint: 'Add interest and press Enter',
                  onChanged: (tags) => ref
                      .read(profileProvider.notifier)
                      .updateField((p) => p.copyWith(interests: tags)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Product / Service',
              children: [
                _field(_productCtrl, 'Current product / campaign', required: true),
                const SizedBox(height: 8),
                const Text('Key benefits', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                TagInputField(
                  initialTags: profile.keyBenefits,
                  hint: 'Add benefit and press Enter',
                  onChanged: (tags) => ref
                      .read(profileProvider.notifier)
                      .updateField((p) => p.copyWith(keyBenefits: tags)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }
}
