import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final List<String> initialTags;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  const TagInputField({
    super.key,
    required this.initialTags,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late List<String> _tags;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void didUpdateWidget(TagInputField old) {
    super.didUpdateWidget(old);
    if (old.initialTags != widget.initialTags && _tags.isEmpty) {
      setState(() => _tags = List<String>.from(widget.initialTags));
    }
  }

  void _add(String raw) {
    final value = raw.trim();
    if (value.isEmpty || _tags.contains(value)) return;
    setState(() => _tags.add(value));
    _ctrl.clear();
    widget.onChanged(_tags);
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged(_tags);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags
                  .map(
                    (t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _remove(t),
                      backgroundColor: const Color(0xFFEAE8FF),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ),
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(fontSize: 13),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => _add(_ctrl.text),
            ),
          ),
          onSubmitted: _add,
        ),
      ],
    );
  }
}
