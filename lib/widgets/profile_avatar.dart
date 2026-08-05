import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/api_helpers/r2_profile_image.dart';
import '../utils/constants/colors.dart';

/// Circular profile-picture thumbnail with tap-to-change (gallery). Fetches the
/// current image via a presigned R2 URL, and uploads a resized JPEG on change.
class ProfileAvatar extends StatefulWidget {
  final String initial;
  final double radius;
  final bool editable;

  const ProfileAvatar({
    super.key,
    required this.initial,
    this.radius = 44,
    this.editable = true,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _url;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final url = await R2ProfileImage.imageUrl();
    if (!mounted) return;
    setState(() {
      _url = url;
      _loading = false;
    });
  }

  Future<void> _pickAndUpload() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      log('avatar: opening picker', name: 'PROFILE');
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (picked == null) {
        log('avatar: picker returned null (cancelled?)', name: 'PROFILE');
        return;
      }
      final bytes = await picked.readAsBytes();
      log('avatar: picked ${bytes.length} bytes', name: 'PROFILE');
      if (!mounted) return;
      setState(() => _uploading = true);
      final ok = await R2ProfileImage.upload(bytes);
      if (!mounted) return;
      if (ok) {
        await _fetch();
        messenger.showSnackBar(const SnackBar(
            content: Text('Profile photo updated'),
            backgroundColor: Colors.green));
      } else {
        messenger.showSnackBar(const SnackBar(
            content: Text('Could not upload photo. Please try again.')));
      }
      if (mounted) setState(() => _uploading = false);
    } catch (e) {
      log('avatar: pick/upload error: $e', name: 'PROFILE');
      if (mounted) {
        setState(() => _uploading = false);
        messenger.showSnackBar(
            SnackBar(content: Text('Photo error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    final showSpinner = _loading || _uploading;
    return GestureDetector(
      onTap: (!widget.editable || _uploading) ? null : _pickAndUpload,
      child: SizedBox(
      width: r * 2,
      height: r * 2,
      child: Stack(
        children: [
          Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: royalBlue.withValues(alpha: 0.10),
              image: _url != null
                  ? DecorationImage(
                      image: NetworkImage(_url!), fit: BoxFit.cover)
                  : null,
            ),
            child: showSpinner
                ? const Center(
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : (_url == null
                    ? Center(
                        child: Text(
                          widget.initial.isNotEmpty
                              ? widget.initial[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.hind(
                            fontSize: r * 0.7,
                            fontWeight: FontWeight.w700,
                            color: royalBlue,
                          ),
                        ),
                      )
                    : null),
          ),
          if (widget.editable)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _uploading ? null : _pickAndUpload,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: royalBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 15, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
