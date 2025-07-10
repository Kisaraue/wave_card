import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../data/models/profile_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'glassmorphism_container.dart';

class ProfileCardWidget extends StatefulWidget {
  final ProfileCard profileCard;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;

  const ProfileCardWidget({
    super.key,
    required this.profileCard,
    this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onShare,
  });

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends State<ProfileCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force rebuild when profile card data or style changes
    if (oldWidget.profileCard != widget.profileCard || _hasStyleChanged(oldWidget.profileCard.cardStyle, widget.profileCard.cardStyle)) {
      setState(() {});
    }
  }

  bool _hasStyleChanged(CardStyle oldStyle, CardStyle newStyle) {
    return oldStyle.fontFamily != newStyle.fontFamily ||
           oldStyle.fontSize != newStyle.fontSize ||
           oldStyle.fontWeight != newStyle.fontWeight ||
           oldStyle.textColor != newStyle.textColor ||
           oldStyle.template != newStyle.template ||
           oldStyle.backgroundColor != newStyle.backgroundColor ||
           oldStyle.backgroundType != newStyle.backgroundType ||
           oldStyle.borderRadius != newStyle.borderRadius ||
           oldStyle.hasGlassmorphism != newStyle.hasGlassmorphism ||
           oldStyle.has3DEffect != newStyle.has3DEffect;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: _buildCard(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Container(
      width: AppConstants.cardWidth,
      height: AppConstants.cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
        boxShadow: [
          if (cardStyle.has3DEffect) ...[
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ],
      ),
      child: Stack(
        children: [
          _buildCardBackground(),
          _buildCardContent(),
          if (widget.showActions) _buildCardActions(),
        ],
      ),
    );
  }

  Widget _buildCardBackground() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
        color: cardStyle.backgroundType == 'solid' ? cardStyle.backgroundColor : null,
        gradient: cardStyle.backgroundType == 'gradient' 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardStyle.gradientColors,
            )
          : null,
        image: cardStyle.backgroundType == 'image' && cardStyle.backgroundImageUrl != null
          ? DecorationImage(
              image: CachedNetworkImageProvider(cardStyle.backgroundImageUrl!),
              fit: BoxFit.cover,
            )
          : null,
      ),
      child: cardStyle.hasGlassmorphism
        ? GlassmorphismContainer(
            borderRadius: cardStyle.borderRadius,
            child: const SizedBox.expand(),
          )
        : null,
    );
  }

  Widget _buildCardContent() {
    final cardStyle = widget.profileCard.cardStyle;
    
    switch (cardStyle.template) {
      case 'Modern':
        return _buildModernTemplate();
      case 'Minimalist':
        return _buildMinimalistTemplate();
      case 'Creative':
        return _buildCreativeTemplate();
      case 'Professional':
        return _buildProfessionalTemplate();
      case 'Vibrant':
        return _buildVibrantTemplate();
      case 'Classic':
      default:
        return _buildClassicTemplate();
    }
  }

  Widget _buildClassicTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProfileImage(),
              const SizedBox(width: AppConstants.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profileCard.fullName,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize + 4,
                        fontWeight: cardStyle.fontWeight,
                        color: cardStyle.textColor,
                        fontFamily: cardStyle.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.smallSpacing / 2),
                    Text(
                      widget.profileCard.jobTitle,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize,
                        fontWeight: FontWeight.w500,
                        color: cardStyle.textColor.withOpacity(0.8),
                        fontFamily: cardStyle.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.profileCard.company,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize - 2,
                        color: cardStyle.textColor.withOpacity(0.6),
                        fontFamily: cardStyle.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildContactInfo(),
          const SizedBox(height: AppConstants.smallSpacing),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildModernTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: AppConstants.smallSpacing),
                    Text(
                      widget.profileCard.fullName,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: cardStyle.textColor,
                        fontFamily: cardStyle.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.profileCard.jobTitle,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize,
                        fontWeight: FontWeight.w500,
                        color: cardStyle.textColor.withOpacity(0.8),
                        fontFamily: cardStyle.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.profileCard.company,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize - 2,
                        color: cardStyle.textColor.withOpacity(0.6),
                        fontFamily: cardStyle.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildContactInfo(),
          const SizedBox(height: AppConstants.smallSpacing / 2),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildMinimalistTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.profileCard.fullName,
                  style: TextStyle(
                    fontSize: cardStyle.fontSize + 6,
                    fontWeight: FontWeight.w300,
                    color: cardStyle.textColor,
                    fontFamily: cardStyle.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.smallSpacing / 2),
                Text(
                  widget.profileCard.jobTitle,
                  style: TextStyle(
                    fontSize: cardStyle.fontSize,
                    fontWeight: FontWeight.w400,
                    color: cardStyle.textColor.withOpacity(0.7),
                    fontFamily: cardStyle.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.profileCard.company,
                  style: TextStyle(
                    fontSize: cardStyle.fontSize - 2,
                    color: cardStyle.textColor.withOpacity(0.5),
                    fontFamily: cardStyle.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.profileCard.email != null)
            Text(
              widget.profileCard.email!,
              style: TextStyle(
                fontSize: cardStyle.fontSize - 2,
                color: cardStyle.textColor.withOpacity(0.6),
                fontFamily: cardStyle.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: AppConstants.smallSpacing / 2),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildCreativeTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profileCard.fullName,
                            style: TextStyle(
                              fontSize: cardStyle.fontSize + 4,
                              fontWeight: FontWeight.w700,
                              color: cardStyle.textColor,
                              fontFamily: cardStyle.fontFamily,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppConstants.smallSpacing / 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cardStyle.textColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.profileCard.jobTitle,
                              style: TextStyle(
                                fontSize: cardStyle.fontSize - 1,
                                fontWeight: FontWeight.w500,
                                color: cardStyle.textColor,
                                fontFamily: cardStyle.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    _buildProfileImage(),
                  ],
                ),
                const SizedBox(height: AppConstants.smallSpacing / 2),
                Text(
                  widget.profileCard.company,
                  style: TextStyle(
                    fontSize: cardStyle.fontSize - 2,
                    color: cardStyle.textColor.withOpacity(0.6),
                    fontFamily: cardStyle.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildContactInfo(),
          const SizedBox(height: AppConstants.smallSpacing / 2),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildProfessionalTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallSpacing),
                  decoration: BoxDecoration(
                    color: cardStyle.textColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildProfileImage(),
                      const SizedBox(width: AppConstants.mediumSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profileCard.fullName,
                              style: TextStyle(
                                fontSize: cardStyle.fontSize + 3,
                                fontWeight: FontWeight.w600,
                                color: cardStyle.textColor,
                                fontFamily: cardStyle.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.profileCard.jobTitle,
                              style: TextStyle(
                                fontSize: cardStyle.fontSize - 1,
                                color: cardStyle.textColor.withOpacity(0.7),
                                fontFamily: cardStyle.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.profileCard.company,
                              style: TextStyle(
                                fontSize: cardStyle.fontSize - 2,
                                color: cardStyle.textColor.withOpacity(0.6),
                                fontFamily: cardStyle.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildContactInfo(),
          const SizedBox(height: AppConstants.smallSpacing / 2),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildVibrantTemplate() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardStyle.textColor.withOpacity(0.1),
            cardStyle.textColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cardStyle.textColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _buildProfileImage(),
                      ),
                      const SizedBox(width: AppConstants.mediumSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.profileCard.fullName,
                              style: TextStyle(
                                fontSize: cardStyle.fontSize + 4,
                                fontWeight: FontWeight.w800,
                                color: cardStyle.textColor,
                                fontFamily: cardStyle.fontFamily,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppConstants.smallSpacing / 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cardStyle.textColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                widget.profileCard.jobTitle,
                                style: TextStyle(
                                  fontSize: cardStyle.fontSize - 2,
                                  fontWeight: FontWeight.w500,
                                  color: cardStyle.backgroundColor,
                                  fontFamily: cardStyle.fontFamily,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallSpacing / 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.profileCard.company,
                      style: TextStyle(
                        fontSize: cardStyle.fontSize - 2,
                        color: cardStyle.textColor.withOpacity(0.6),
                        fontFamily: cardStyle.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildContactInfo(),
            const SizedBox(height: AppConstants.smallSpacing / 2),
            _buildSocialLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: widget.profileCard.profileImageUrl != null
          ? _buildProfileImageWidget()
          : Container(
              color: AppColors.lightGrey,
              child: const Icon(Icons.person, size: 30, color: AppColors.grey),
            ),
      ),
    );
  }

  Widget _buildProfileImageWidget() {
    final imageUrl = widget.profileCard.profileImageUrl!;
    
    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        memCacheWidth: 120,
        memCacheHeight: 120,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.lightGrey,
          child: const Icon(Icons.person, size: 30, color: AppColors.grey),
        ),
      );
    } else {
      // Handle local file
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.lightGrey,
            child: const Icon(Icons.person, size: 30, color: AppColors.grey),
          ),
        );
      } else {
        return Container(
          color: AppColors.lightGrey,
          child: const Icon(Icons.person, size: 30, color: AppColors.grey),
        );
      }
    }
  }

  Widget _buildContactInfo() {
    final cardStyle = widget.profileCard.cardStyle;
    
    return Row(
      children: [
        if (widget.profileCard.email != null) ...[
          Icon(
            Icons.email_outlined,
            size: 16,
            color: cardStyle.textColor.withOpacity(0.7),
          ),
          const SizedBox(width: AppConstants.smallSpacing / 2),
          Expanded(
            child: Text(
              widget.profileCard.email!,
              style: TextStyle(
                fontSize: cardStyle.fontSize - 2,
                color: cardStyle.textColor.withOpacity(0.7),
                fontFamily: cardStyle.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (widget.profileCard.phone != null) ...[
          const SizedBox(width: AppConstants.smallSpacing),
          Icon(
            Icons.phone_outlined,
            size: 16,
            color: cardStyle.textColor.withOpacity(0.7),
          ),
          const SizedBox(width: AppConstants.smallSpacing / 2),
          Text(
            widget.profileCard.phone!,
            style: TextStyle(
              fontSize: cardStyle.fontSize - 2,
              color: cardStyle.textColor.withOpacity(0.7),
              fontFamily: cardStyle.fontFamily,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = widget.profileCard.socialLinks;
    if (socialLinks.isEmpty) return const SizedBox.shrink();

    return Row(
      children: socialLinks.entries
          .take(4)
          .map((entry) => Padding(
                padding: const EdgeInsets.only(right: AppConstants.smallSpacing),
                child: _buildSocialIcon(entry.key),
              ))
          .toList(),
    );
  }

  Widget _buildSocialIcon(String platform) {
    IconData iconData;
    switch (platform.toLowerCase()) {
      case 'linkedin':
        iconData = Icons.business;
        break;
      case 'twitter':
        iconData = Icons.alternate_email;
        break;
      case 'instagram':
        iconData = Icons.camera_alt;
        break;
      case 'github':
        iconData = Icons.code;
        break;
      case 'facebook':
        iconData = Icons.facebook;
        break;
      default:
        iconData = Icons.link;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(0.2),
      ),
      child: Icon(
        iconData,
        size: 14,
        color: widget.profileCard.cardStyle.textColor.withOpacity(0.8),
      ),
    );
  }

  Widget _buildCardActions() {
    return Positioned(
      top: 8,
      right: 8,
      child: PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.more_vert,
            size: 16,
            color: AppColors.white,
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              widget.onEdit?.call();
              break;
            case 'duplicate':
              widget.onDuplicate?.call();
              break;
            case 'delete':
              widget.onDelete?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'duplicate',
            child: Row(
              children: [
                Icon(Icons.copy, size: 16),
                SizedBox(width: 8),
                Text('Duplicate'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}