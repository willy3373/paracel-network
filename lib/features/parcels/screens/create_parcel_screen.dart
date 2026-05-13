import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/parcels/services/parcel_service.dart';
import 'package:pick_pack/models/agency.dart';
import 'package:pick_pack/models/app_user.dart';
import 'package:pick_pack/models/parcel.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _senderNameCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();
  final _receiverNameCtrl = TextEditingController();
  final _receiverPhoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _trackingCodeCtrl = TextEditingController();
  
  String? _destinationAgencyId;
  bool _isPOD = false;
  bool _isLoading = false;
  
  final _parcelService = ParcelService();
  double _gangFee = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFee();
  }

  Future<void> _fetchFee() async {
    final user = context.read<AuthService>().currentUser;
    if (user?.agencyId != null) {
      final fee = await _parcelService.getGangFeeForAgency(user!.agencyId!);
      setState(() {
        _gangFee = fee;
        if (_amountCtrl.text.isEmpty && _gangFee > 0) {
          _amountCtrl.text = _gangFee.toStringAsFixed(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _amountCtrl.dispose();
    _labelCtrl.dispose();
    _trackingCodeCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_destinationAgencyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectDestinationAgency), backgroundColor: AppTheme.errorColor)
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final parcel = Parcel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Use timestamp as ID
      senderName: _senderNameCtrl.text.trim(),
      senderPhone: _senderPhoneCtrl.text.trim(),
      receiverName: _receiverNameCtrl.text.trim(),
      receiverPhone: _receiverPhoneCtrl.text.trim(),
      originAgencyId: currentUser.agencyId ?? '',
      destinationAgencyId: _destinationAgencyId!,
      weight: 0.0,
      amount: double.tryParse(_amountCtrl.text) ?? 0.0,
      label: _labelCtrl.text.trim(),
      trackingCode: _trackingCodeCtrl.text.trim(),
      status: 'sent',
      createdAt: DateTime.now(),
      isPayOnDelivery: _isPOD,
    );

    final error = await _parcelService.createParcel(parcel);

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.errorColor)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parcelCreatedSuccessfully), backgroundColor: AppTheme.secondaryColor)
        );
        _formKey.currentState!.reset();
        _senderNameCtrl.clear();
        _senderPhoneCtrl.clear();
        _receiverNameCtrl.clear();
        _receiverPhoneCtrl.clear();
        _amountCtrl.clear();
        _labelCtrl.clear();
        _trackingCodeCtrl.clear();
        setState(() {
          _destinationAgencyId = null;
          _isPOD = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAgencyId = context.watch<AuthService>().currentUser?.agencyId ?? '';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendNewParcel),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.senderInformation),
              const SizedBox(height: 12),
              _buildTextField(l10n.fullName, LucideIcons.user, _senderNameCtrl, l10n: l10n),
              const SizedBox(height: 12),
              _buildTextField(l10n.phoneNumber, LucideIcons.phone, _senderPhoneCtrl, keyboardType: TextInputType.phone, l10n: l10n),
              
              const SizedBox(height: 16),
              _buildSectionTitle(l10n.receiverInformation),
              const SizedBox(height: 12),
              _buildTextField(l10n.fullName, LucideIcons.user, _receiverNameCtrl, l10n: l10n),
              const SizedBox(height: 12),
              _buildTextField(l10n.phoneNumber, LucideIcons.phone, _receiverPhoneCtrl, keyboardType: TextInputType.phone, l10n: l10n),
              
              const SizedBox(height: 16),
              _buildSectionTitle(l10n.parcelDetails),
              const SizedBox(height: 12),
              
              // Dynamic Dropdown for Agencies in same gang
              FutureBuilder<List<Agency>>(
                future: _parcelService.getAgenciesInSameGang(currentAgencyId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final agencies = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _destinationAgencyId,
                    decoration: InputDecoration(
                      labelText: l10n.destinationAgency,
                      prefixIcon: const Icon(LucideIcons.building2, size: 20),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: AppConstants.borderRadiusMd,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: AppTheme.surfaceColor,
                    items: agencies.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.name, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (val) => setState(() => _destinationAgencyId = val),
                    validator: (v) => v == null ? l10n.requiredField : null,
                  );
                }
              ),
              
              const SizedBox(height: 12),
              _buildTextField(
                l10n.amount, 
                LucideIcons.banknote, 
                _amountCtrl, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                readOnly: context.read<AuthService>().currentUser?.role != UserRole.admin, // Only admin can override fee
                l10n: l10n,
              ),
              const SizedBox(height: 12),
              _buildTextField(l10n.labelDetails, LucideIcons.tag, _labelCtrl, isRequired: false, maxLines: 2, l10n: l10n),
              const SizedBox(height: 12),
              _buildTextField(l10n.trackingCodeOptional, LucideIcons.hash, _trackingCodeCtrl, isRequired: false, hint: l10n.leaveBlankToAutoGenerate, l10n: l10n),
              
              const SizedBox(height: 24),
              _buildPODToggle(l10n),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.createShipment, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType, bool isRequired = true, String? hint, int maxLines = 1, bool readOnly = false, required AppLocalizations l10n}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: isRequired ? (v) => v == null || v.isEmpty ? l10n.requiredField : null : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildPODToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.payOnDelivery, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(l10n.receiverPaysForShipment, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
          Switch(
            value: _isPOD,
            onChanged: (value) => setState(() => _isPOD = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
