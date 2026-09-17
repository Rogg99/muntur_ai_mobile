import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/network/api_client.dart';
import 'package:munturai/features/auth/domain/entities/user_entity.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
import 'package:munturai/features/marketplace/presentation/providers/marketplace_provider.dart';
import 'package:munturai/screens/marketplace_vendor_dashboard.dart';
import 'package:munturai/utils/divisionsFilter.dart';
import 'package:munturai/widgets/custom_filter_card.dart';
import 'package:munturai/widgets/primary_button.dart';
import 'package:munturai/widgets/widget_profile_tile.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile>
    with TickerProviderStateMixin {
  bool setName = false;
  bool setAge = false;
  bool setLocation = false;
  bool setPassword = false;
  bool setPhone = false;
  bool setSexe = false;
  bool setPays = false;
  bool _uploadingPhoto = false;

  String birth = '2000-01-01';
  // 'MALE' / 'FEMALE' — matches the values register.dart writes at signup.
  String sexeValue = 'MALE';
  String paysValue = 'CAMEROUN';

  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final villecontroller = TextEditingController();
  final pwdcontroller = TextEditingController();
  final phonecontroller = TextEditingController();

  @override
  void dispose() {
    namecontroller.dispose();
    prenomcontroller.dispose();
    villecontroller.dispose();
    pwdcontroller.dispose();
    phonecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final userAsync = ref.watch(authStateProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(child: Text('${translator.error_prefix}: $e')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(child: Text(translator.profile_loading)),
          );
        }
        return _buildBody(context, appStyle, translator, colorScheme, user);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppStyle appStyle,
    AppLocalizations translator,
    ColorScheme colorScheme,
    UserEntity user,
  ) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              translator.profile,
              style: appStyle.H3(color: colorScheme.onSurface, weight: 'bold'),
            ),
            backgroundColor: colorScheme.surface,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              // ─── Avatar ───
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(130),
                          image: DecorationImage(
                            image:
                                (user.photo != null && user.photo!.isNotEmpty)
                                    ? NetworkImage(user.photo!) as ImageProvider
                                    : const AssetImage(
                                        'assets/images/placeholder_user.png'),
                            fit: BoxFit.cover,
                          ),
                          border:
                              Border.all(width: 4, color: colorScheme.primary),
                        ),
                        child: _uploadingPhoto
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadingPhoto ? null : _takeImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.camera_fill,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Mon compte ───
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(translator.my_account,
                    style: appStyle.txtRoboto(weight: 'b', size: 22)),
              ),
              ProfileTile(
                icon: const Icon(Icons.email),
                text: translator.email_label,
                desc: user.email,
                // The Profile model backing this data has no email field
                // (only Django's User model does, which has no update
                // endpoint exposed yet) — nothing to open here until that
                // exists server-side, so say so instead of doing nothing.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(translator.profile_email_edit_unavailable)),
                ),
              ),
              ProfileTile(
                icon: const Icon(Icons.phone),
                text: translator.hint_phone,
                desc: user.phone ?? '—',
                onPressed: () {
                  phonecontroller.text = user.phone ?? '';
                  setState(() => setPhone = true);
                },
              ),
              ProfileTile(
                icon: const Icon(Icons.password),
                text: translator.password_hint,
                desc: '••••••••••',
                onPressed: () => setState(() => setPassword = true),
              ),
              ProfileTile(
                icon: const Icon(Icons.location_on_sharp),
                text: translator.location,
                desc: user.ville ?? '—',
                onPressed: () {
                  villecontroller.text = user.ville ?? '';
                  setState(() => setLocation = true);
                },
              ),

              // ─── Infos personnelles ───
              Padding(
                padding: const EdgeInsets.only(top: 28, bottom: 8),
                child: Text(translator.personalInfos,
                    style: appStyle.txtRoboto(weight: 'b', size: 22)),
              ),
              ProfileTile(
                icon: const Icon(Icons.person),
                text: translator.name,
                desc: user.fullName.isNotEmpty ? user.fullName : '—',
                onPressed: () {
                  namecontroller.text = user.lastName ?? '';
                  prenomcontroller.text = user.firstName ?? '';
                  setState(() => setName = true);
                },
              ),
              ProfileTile(
                icon: const Icon(Icons.calendar_month),
                text: translator.birthDateLabel,
                desc: user.dateNaissance ?? '—',
                onPressed: () => setState(() => setAge = true),
              ),
              ProfileTile(
                icon: const Icon(Icons.wc),
                text: translator.genderLabel,
                desc: (user.sexe ?? 'MALE') == 'FEMALE'
                    ? translator.genderFemale
                    : translator.genderMale,
                onPressed: () {
                  sexeValue = user.sexe ?? 'MALE';
                  setState(() => setSexe = true);
                },
              ),
              ProfileTile(
                icon: const Icon(Icons.public),
                text: translator.countryHint,
                desc: user.pays ?? '—',
                onPressed: () {
                  paysValue = user.pays ?? 'CAMEROUN';
                  setState(() => setPays = true);
                },
              ),

              // ─── Ma boutique marketplace (vendeurs uniquement) ───
              Consumer(
                builder: (context, ref, _) {
                  final vendorAsync = ref.watch(marketplaceMyVendorProvider);
                  final vendor = vendorAsync.valueOrNull;
                  if (vendor == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 28, bottom: 8),
                        child: Text(translator.profile_marketplace_section_label,
                            style: appStyle.txtRoboto(weight: 'b', size: 22)),
                      ),
                      ProfileTile(
                        icon: const Icon(Icons.storefront_outlined),
                        text: translator.profile_my_shop,
                        desc: vendor.shopName,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MarketplaceVendorDashboard()),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),

        // ─── Overlay : modifier nom ───
        if (setName)
          CustomFilterCard(
            title: translator.name,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namecontroller,
                  style: appStyle.H6(),
                  decoration: InputDecoration(
                    hintText: translator.surnameHint,
                    label: Text(translator.surnameHint),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prenomcontroller,
                  style: appStyle.H6(),
                  decoration: InputDecoration(
                    hintText: translator.nameHint,
                    label: Text(translator.nameHint),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).updateProfile({
                      'nom': namecontroller.text,
                      'prenom': prenomcontroller.text,
                    });
                    if (mounted) setState(() => setName = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setName = false),
          ),

        // ─── Overlay : modifier date naissance ───
        if (setAge)
          CustomFilterCard(
            title: translator.birthDateLabel,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      firstDate: DateTime(1950),
                      lastDate: DateTime(DateTime.now().year - 18),
                    ),
                    value: [DateTime.tryParse(birth) ?? DateTime(2000)],
                    onValueChanged: (dates) {
                      if (dates.isNotEmpty && dates[0] != null) {
                        setState(() {
                          birth = dates[0]!.toIso8601String().split('T')[0];
                        });
                      }
                    },
                  ),
                ),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .updateProfile({'date_naissance': birth});
                    if (mounted) setState(() => setAge = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setAge = false),
          ),

        // ─── Overlay : modifier sexe ───
        if (setSexe)
          CustomFilterCard(
            title: translator.genderLabel,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text(translator.genderMale),
                      selected: sexeValue == 'MALE',
                      onSelected: (_) => setState(() => sexeValue = 'MALE'),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(translator.genderFemale),
                      selected: sexeValue == 'FEMALE',
                      onSelected: (_) => setState(() => sexeValue = 'FEMALE'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .updateProfile({'sexe': sexeValue});
                    if (mounted) setState(() => setSexe = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setSexe = false),
          ),

        // ─── Overlay : modifier pays ───
        if (setPays)
          CustomFilterCard(
            title: translator.countryHint,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: countries_eng.length,
                    itemBuilder: (context, index) {
                      final country = countries_eng[index];
                      return RadioListTile<String>(
                        title: Text(country),
                        value: country,
                        groupValue: paysValue,
                        onChanged: (v) =>
                            setState(() => paysValue = v ?? paysValue),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .updateProfile({'pays': paysValue});
                    if (mounted) setState(() => setPays = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setPays = false),
          ),

        // ─── Overlay : modifier ville ───
        if (setLocation)
          CustomFilterCard(
            title: translator.location,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: villecontroller,
                  style: appStyle.H6(),
                  decoration: InputDecoration(
                    hintText: translator.enter_city_hint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .updateProfile({'ville': villecontroller.text});
                    if (mounted) setState(() => setLocation = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setLocation = false),
          ),

        // ─── Overlay : modifier téléphone ───
        if (setPhone)
          CustomFilterCard(
            title: translator.hint_phone,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phonecontroller,
                  keyboardType: TextInputType.phone,
                  style: appStyle.H6(),
                  decoration: InputDecoration(
                    hintText: translator.phoneHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .updateProfile({'telephone': phonecontroller.text});
                    if (mounted) setState(() => setPhone = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setPhone = false),
          ),

        // ─── Overlay : changer mot de passe ───
        if (setPassword)
          CustomFilterCard(
            title: translator.password_hint,
            desc: '',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pwdcontroller,
                  obscureText: true,
                  style: appStyle.H6(),
                  decoration: InputDecoration(
                    hintText: translator.hint_password,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: translator.save,
                  padding: 50,
                  radius: 50,
                  onPressed: () async {
                    final pwd = pwdcontroller.text;
                    await ref
                        .read(authStateProvider.notifier)
                        .resetPassword(pwd);
                    if (mounted) {
                      setState(() => setPassword = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(translator.profile_password_changed)),
                      );
                    }
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setPassword = false),
          ),
      ],
    );
  }

  /// Uploads to the same shared /medias/ endpoint the chatbot attachments
  /// and marketplace catalog photos use, then PATCHes the returned media id
  /// onto the profile — Profile.photo is a FK to Media, not a raw URL.
  Future<void> _takeImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickMedia();
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      final response = await ApiClient().postMultipart('/medias/', form);
      final data = response.data['data'] ?? response.data;
      final mediaId = data is Map ? data['id']?.toString() : null;
      if (mediaId == null) throw Exception('no media id in response');
      await ref
          .read(authStateProvider.notifier)
          .updateProfile({'photo': mediaId});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.profile_photo_upload_failed)),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }
}
