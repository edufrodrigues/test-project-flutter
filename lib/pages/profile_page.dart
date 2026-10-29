import 'package:flutter/material.dart';

import '../api/fake_api.dart';
import '../api/models.dart';
import '../app/app_scope.dart';
import '../app/theme_controller.dart';
import '../design_system/design_system.dart';
import '../features/booking/validation.dart';
import '../features/layout/page_layout.dart';
import '../utils/async_loader.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AsyncLoader<ProfilePage, Profile> {
  @override
  Future<Profile> load(AppServices services) => services.api.getProfile();

  @override
  Widget build(BuildContext context) {
    return RotaPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            title: 'Meu perfil',
            subtitle: 'Gerencie seus dados, a aparência do app e as notificações.',
          ),
          const SizedBox(height: RotaSpacing.s8),
          switch (loadState) {
            AsyncLoading() => const RotaLoadingRegion(
              label: 'Carregando perfil',
              child: _ProfileLayout(
                identity: RotaSkeleton(height: 220, shape: RotaSkeletonShape.rect),
                sections: RotaSkeleton(height: 360, shape: RotaSkeletonShape.rect),
              ),
            ),
            AsyncFailure(:final error) => RotaErrorState(
              title: 'Não foi possível carregar seu perfil',
              description: errorMessage(error),
              onRetry: reload,
            ),
            AsyncData(:final data) => _ProfileLayout(
              identity: _IdentityCard(profile: data),
              sections: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileForm(profile: data, onSaved: setData),
                  const SizedBox(height: RotaSpacing.s6),
                  const _AppearanceSection(),
                  const SizedBox(height: RotaSpacing.s6),
                  const _NotificationsSection(),
                ],
              ),
            ),
          },
        ],
      ),
    );
  }
}

class _ProfileLayout extends StatelessWidget {
  const _ProfileLayout({required this.identity, required this.sections});

  final Widget identity;
  final Widget sections;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < RotaLayout.splitBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [identity, const SizedBox(height: RotaSpacing.s6), sections],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 300, child: identity),
            const SizedBox(width: RotaSpacing.s8),
            Expanded(child: sections),
          ],
        );
      },
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        children: [
          RotaAvatar(name: profile.name, size: RotaAvatarSize.lg),
          const SizedBox(height: RotaSpacing.s4),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: RotaTypography.sectionTitle.copyWith(color: c.text, fontSize: RotaTypography.xl),
          ),
          const SizedBox(height: RotaSpacing.s1),
          Text(profile.city, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
          const SizedBox(height: RotaSpacing.s3),
          RotaBadge(label: 'Viajante desde ${profile.memberSince}', tone: RotaTone.primary),
        ],
      ),
    );
  }
}

/// Formulário de dados pessoais. "Salvar" só fica ativo quando há alterações.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.profile, required this.onSaved});

  final Profile profile;
  final ValueChanged<Profile> onSaved;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _email = TextEditingController(text: widget.profile.email);
  late final _phone = TextEditingController(text: widget.profile.phone);
  late final _city = TextEditingController(text: widget.profile.city);

  bool _saving = false;
  bool _showErrors = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _city]) {
      controller.dispose();
    }
    super.dispose();
  }

  Profile get _values => widget.profile.copyWith(
    name: _name.text,
    email: _email.text,
    phone: _phone.text,
    city: _city.text,
  );

  String? get _nameError => _name.text.trim().length < 3 ? 'Informe seu nome completo.' : null;
  String? get _emailError => isValidEmail(_email.text) ? null : 'Informe um e-mail válido.';

  Future<void> _submit() async {
    setState(() {
      _showErrors = true;
      _error = null;
    });
    if (_nameError != null || _emailError != null) return;

    setState(() => _saving = true);
    final api = AppScope.of(context).api;
    try {
      final saved = await api.updateProfile(_values);
      if (!mounted) return;
      widget.onSaved(saved);
      showRotaToast(context, title: 'Perfil atualizado', description: 'Suas alterações foram salvas.');
    } catch (error) {
      if (mounted) setState(() => _error = errorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dirty = _values != widget.profile;
    void changed(String _) => setState(() {});

    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Dados pessoais'),
          const SizedBox(height: RotaSpacing.s4),
          if (_error != null) ...[
            RotaAlert(tone: RotaTone.danger, title: 'Não foi possível salvar', message: _error!),
            const SizedBox(height: RotaSpacing.s4),
          ],
          FieldRow(
            children: [
              RotaTextField(
                label: 'Nome',
                required: true,
                controller: _name,
                enabled: !_saving,
                error: _showErrors ? _nameError : null,
                onChanged: changed,
              ),
              RotaTextField(
                label: 'E-mail',
                required: true,
                controller: _email,
                enabled: !_saving,
                keyboardType: TextInputType.emailAddress,
                error: _showErrors ? _emailError : null,
                onChanged: changed,
              ),
            ],
          ),
          const SizedBox(height: RotaSpacing.s4),
          FieldRow(
            children: [
              RotaTextField(
                label: 'Telefone',
                controller: _phone,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                inputFormatters: const [PhoneInputFormatter()],
                onChanged: changed,
              ),
              RotaTextField(label: 'Cidade', controller: _city, enabled: !_saving, onChanged: changed),
            ],
          ),
          const SizedBox(height: RotaSpacing.s6),
          Align(
            alignment: Alignment.centerRight,
            child: RotaButton(label: 'Salvar alterações', loading: _saving, onPressed: dirty ? _submit : null),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Aparência'),
          const SizedBox(height: RotaSpacing.s4),
          ListenableBuilder(
            listenable: theme,
            builder: (context, _) => Row(
              children: [
                for (final option in ThemePreference.values) ...[
                  if (option != ThemePreference.values.first) const SizedBox(width: RotaSpacing.s3),
                  Expanded(
                    child: _ThemeOption(
                      option: option,
                      selected: theme.preference == option,
                      onTap: () => theme.preference = option,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.option, required this.selected, required this.onTap});

  final ThemePreference option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final color = selected ? c.primary : c.textMuted;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: 'Tema ${option.label}',
      excludeSemantics: true,
      child: Material(
        color: selected ? c.primarySoft : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RotaRadius.md),
          side: BorderSide(color: selected ? c.primary : c.border, width: selected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RotaRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: RotaSpacing.s4),
            child: Column(
              children: [
                Icon(option.icon, size: 20, color: color),
                const SizedBox(height: RotaSpacing.s2),
                Text(option.label, style: RotaTypography.label.copyWith(color: color, fontWeight: RotaTypography.semibold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _reminders = true;
  bool _offers = false;
  bool _newsletter = true;

  @override
  Widget build(BuildContext context) {
    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Notificações'),
          const SizedBox(height: RotaSpacing.s4),
          RotaSwitch(
            label: 'Lembretes de viagem',
            description: 'Avisos 48 horas e 2 horas antes de cada experiência.',
            value: _reminders,
            onChanged: (value) => setState(() => _reminders = value),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: RotaSpacing.s3), child: Divider()),
          RotaSwitch(
            label: 'Ofertas e promoções',
            description: 'Descontos em experiências parecidas com as que você reservou.',
            value: _offers,
            onChanged: (value) => setState(() => _offers = value),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: RotaSpacing.s3), child: Divider()),
          RotaSwitch(
            label: 'Newsletter mensal',
            description: 'Roteiros e dicas de destinos pelo Brasil.',
            value: _newsletter,
            onChanged: (value) => setState(() => _newsletter = value),
          ),
        ],
      ),
    );
  }
}
