import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/core/colors/colors.dart';
import 'package:munturai/features/auth/domain/entities/user_entity.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';
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

  String birth = '2000-01-01';

  final namecontroller = TextEditingController();
  final prenomcontroller = TextEditingController();
  final villecontroller = TextEditingController();
  final pwdcontroller = TextEditingController();

  @override
  void dispose() {
    namecontroller.dispose();
    prenomcontroller.dispose();
    villecontroller.dispose();
    pwdcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Watch auth state — user loaded from Isar (online-first in authStateProvider)
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
        body: Center(child: Text('Erreur: $e')),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(child: Text(translator.loading)),
          );
        }
        return _buildBody(context, appStyle, translator, colorScheme, user);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic appStyle,
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
                            image: user.photo != null && user.photo!.isNotEmpty
                                ? NetworkImage(user.photo!) as ImageProvider
                                : const AssetImage(
                                    'assets/images/placeholder_user.png'),
                            fit: BoxFit.cover,
                          ),
                          border:
                              Border.all(width: 4, color: colorScheme.primary),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _takeImage,
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
                onPressed: () {},
              ),
              ProfileTile(
                icon: const Icon(Icons.phone),
                text: translator.hint_phone,
                desc: user.phone ?? '—',
                onPressed: () {},
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
                    setState(() => setName = false);
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
                    setState(() => setAge = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setAge = false),
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
                    setState(() => setLocation = false);
                  },
                ),
              ],
            ),
            onClose: () => setState(() => setLocation = false),
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
                    await ref
                        .read(authStateProvider.notifier)
                        .resetPassword(pwdcontroller.text);
                    setState(() => setPassword = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Mot de passe modifié')));
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

  Future<void> _takeImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickMedia();
    if (file == null) return;
    // TODO Phase 8: upload via MediaRepository, then call updateProfile({photo: url})
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload photo — Phase 8')));
    }
  }
}
