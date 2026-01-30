import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../models/api/office_address.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class AddressesScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const AddressesScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String _selectedLocation = 'USA';
  List<OfficeAddress> _allAddresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService(authToken: userProvider.authToken);
      final addresses = await apiService.getOfficeAddresses();
      
      setState(() {
        _allAddresses = addresses;
        // If we have addresses but current selection isn't one of them, pick the first one
        if (_allAddresses.isNotEmpty) {
           final hasCurrent = _allAddresses.any((a) => a.location == _selectedLocation);
           if (!hasCurrent) {
             _selectedLocation = _allAddresses.first.location;
           }
        } else {
          // If no addresses, maybe keep USA or clear it
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Set<String> get _locations => _allAddresses.map((a) => a.location).toSet();

  List<OfficeAddress> get _currentAddresses => 
      _allAddresses.where((a) => a.location == _selectedLocation).toList();

  String _getLocationName(String locationCode) {
    // Map location codes to localized names
    switch (locationCode.toUpperCase()) {
      case 'USA':
      case 'US':
        return context.l10n.translate('usa');
      case 'TURKEY':
      case 'TR':
        return context.l10n.translate('turkey');
      case 'CHINA':
      case 'CN':
        return context.l10n.translate('china');
      case 'GERMANY':
      case 'DE':
        return 'Germany';
      case 'KOREA':
      case 'KR':
        return 'Korea';
      case 'UK':
      case 'GB':
        return 'UK';
      default:
        return locationCode;
    }
  }

  String _getFlagEmoji(String locationCode) {
    switch (locationCode.toUpperCase()) {
      case 'USA':
      case 'US':
        return '🇺🇸';
      case 'TURKEY':
      case 'TR':
        return '🇹🇷';
      case 'CHINA':
      case 'CN':
        return '🇨🇳';
      case 'GERMANY':
      case 'DE':
        return '🇩🇪';
      case 'KOREA':
      case 'KR':
      case 'SOUTH KOREA':
        return '🇰🇷';
      case 'UK':
      case 'GB':
      case 'UNITED KINGDOM':
        return '🇬🇧';
      default:
        return '🏳️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final userProvider = Provider.of<UserProvider>(context);
    // Use personalNumber as the Suite ID, or fallback to user ID
    final userSuiteId = userProvider.userInfo?.personalNumber ?? userProvider.userInfo?.id?.toString() ?? '...';
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAddresses,
                    color: AppTheme.gold,
                 backgroundColor: ThemeHelper.getCardColor(context),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            context.l10n.translate('office_addresses'),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.translate('use_for_orders'),
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_isLoading)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(child: CircularProgressIndicator(color: AppTheme.gold)),
                            )
                          else if (_error != null)
                             Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    Text(
                                      _error!,
                                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      textAlign: TextAlign.center,
                                    ),
                                    TextButton(
                                      onPressed: _loadAddresses,
                                      child: const Text('Retry'),
                                    )
                                  ],
                                ),
                              ),
                            )
                          else if (_allAddresses.isEmpty)
                             Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 100),
                                child: Text(
                                  'No addresses found',
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                            )
                          else ...[
                            // Location tabs (Country selection)
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _locations.length,
                                separatorBuilder: (c, i) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final location = _locations.elementAt(index);
                                  return SizedBox(
                                    width: 110, // Fixed smaller width to show more items
                                    child: _buildCountryButton(
                                      location,
                                      _getLocationName(location),
                                      _selectedLocation == location,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Address cards
                            ..._currentAddresses.map((address) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAddressCard(address, userSuiteId),
                            )),
                          ],

                          // Spacer for navigation
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryButton(
    String locationCode,
    String countryName,
    bool isSelected,
  ) {
    // If we only have 2 or fewer items, we want them expanded to fill space? 
    // The previous implementation used Expanded. I used SizedBox with calc width in ListView.
    // That's fine for scrollable list.
    
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = locationCode;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.3)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.gold
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag icon in circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: textSecondaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getFlagEmoji(locationCode),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              countryName,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.gold
                    : textColor,
                fontSize: 16,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(OfficeAddress address, String userSuiteId) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with country name and warehouse button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocationName(address.location),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (address.state != null)
                      Text(
                        address.state!,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.l10n.translate('warehouse'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Address line
          if (address.address != null) ...[
            _buildAddressLine(
              Icons.location_on_outlined,
              address.address!,
            ),
            const SizedBox(height: 16),
          ],
          // Region line
          if (address.state != null) ...[
            _buildAddressLine(
              Icons.map_outlined,
              address.state!,
            ),
            const SizedBox(height: 16),
          ],
          
          if (address.zip != null) ...[
             _buildAddressLine(
              Icons.label_outline,
              'ZIP - ${address.zip}',
            ),
            const SizedBox(height: 16),
          ],
          
          Divider(
            height: 1,
            thickness: 1,
            color: textSecondaryColor.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          
          // Phone line
          if (address.phoneNumber != null) ...[
            _buildAddressLine(
              Icons.phone_outlined,
              address.phoneNumber!,
            ),
            const SizedBox(height: 16),
          ],
          
          // Working hours line
          if (address.workingHours != null)
            _buildAddressLine(
              Icons.access_time_outlined,
              address.workingHours!,
            ),
        ],
      ),
    );
  }

  Widget _buildAddressLine(IconData icon, String text) {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              CustomSnackBar.show(
                context: context,
                message: context.l10n.translate('copy_to_clipboard'),
                icon: Icons.check_circle_rounded,
                backgroundColor: AppTheme.gold.withValues(alpha: 0.95),
                iconColor: const Color(0xFF0A0E27),
                duration: const Duration(seconds: 2),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy,
                color: textSecondaryColor,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
