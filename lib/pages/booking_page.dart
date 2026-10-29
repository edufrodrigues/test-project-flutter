import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/fake_api.dart';
import '../api/models.dart';
import '../app/app_scope.dart';
import '../app/routes.dart';
import '../design_system/design_system.dart';
import '../features/booking/validation.dart';
import '../features/experiences/experience_art.dart';
import '../features/layout/page_layout.dart';
import '../utils/async_loader.dart';
import '../utils/format.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.experienceId});

  final String experienceId;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with AsyncLoader<BookingPage, Experience> {
  @override
  Future<Experience> load(AppServices services) => services.api.getExperience(widget.experienceId);

  @override
  void didUpdateWidget(BookingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.experienceId != widget.experienceId) reload();
  }

  @override
  Widget build(BuildContext context) {
    return RotaPageBody(
      child: switch (loadState) {
        AsyncLoading() => const RotaLoadingRegion(
          label: 'Carregando reserva',
          child: SplitLayout(
            main: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RotaSkeleton(width: 260),
                SizedBox(height: RotaSpacing.s4),
                FractionallySizedBox(widthFactor: 0.6, child: RotaSkeleton(height: 34)),
                SizedBox(height: RotaSpacing.s6),
                RotaSkeleton(height: 420, shape: RotaSkeletonShape.rect),
              ],
            ),
            aside: RotaSkeleton(height: 300, shape: RotaSkeletonShape.rect),
          ),
        ),
        AsyncFailure(:final error) when error is NotFoundException => RotaEmptyState(
          title: 'Experiência não encontrada',
          description: 'Não é possível reservar uma experiência que não existe mais.',
          actions: [RotaButton(label: 'Voltar para explorar', onPressed: () => context.goNamed(AppRoutes.explore))],
        ),
        AsyncFailure(:final error) => RotaErrorState(description: errorMessage(error), onRetry: reload),
        AsyncData(:final data) => BookingForm(experience: data),
      },
    );
  }
}

/// Formulário de reserva. Mostra o erro de um campo depois que a pessoa sai dele ou tenta enviar.
class BookingForm extends StatefulWidget {
  const BookingForm({super.key, required this.experience});

  final Experience experience;

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _focus = {for (final field in BookingField.values) field: FocusNode()};
  final _alertKey = GlobalKey();

  DateTime? _date;
  late int _guests = widget.experience.maxGuests < 2 ? widget.experience.maxGuests : 2;
  bool _acceptedPolicy = false;

  final _touched = <BookingField>{};
  bool _submitted = false;
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    for (final entry in _focus.entries) {
      entry.value.addListener(() {
        if (!entry.value.hasFocus && mounted) setState(() => _touched.add(entry.key));
      });
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _notes]) {
      controller.dispose();
    }
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  BookingFormValues get _values => BookingFormValues(
    name: _name.text,
    email: _email.text,
    phone: _phone.text,
    date: _date,
    guests: _guests,
    notes: _notes.text,
    acceptedPolicy: _acceptedPolicy,
  );

  Map<BookingField, String> get _errors => validateBooking(_values, widget.experience.maxGuests);

  String? _visibleError(BookingField field) {
    if (field == BookingField.acceptedPolicy) return _submitted ? _errors[field] : null;
    return _submitted || _touched.contains(field) ? _errors[field] : null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _submitError = null;
    });

    final errors = _errors;
    if (errors.isNotEmpty) {
      // Foca o primeiro campo inválido, na ordem em que aparece na tela.
      final first = BookingField.values.firstWhere(errors.containsKey);
      _focus[first]!.requestFocus();
      return;
    }

    setState(() => _submitting = true);
    final api = AppScope.of(context).api;
    try {
      final booking = await api.createBooking(
        BookingInput(
          experienceId: widget.experience.id,
          date: _date!,
          guests: _guests,
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text,
          notes: _notes.text.trim(),
        ),
      );
      if (!mounted) return;
      context.goNamed(AppRoutes.confirmation, pathParameters: {'codigo': booking.id});
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = errorMessage(error);
        _submitting = false;
      });
      // Leva o aviso de erro para a área visível.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final alertContext = _alertKey.currentContext;
        if (alertContext != null && alertContext.mounted) {
          Scrollable.ensureVisible(alertContext, duration: RotaMotion.normal, alignment: 0.1);
        }
      });
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.experience, pathParameters: {'id': widget.experience.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    final experience = widget.experience;
    final total = experience.price * _guests;
    final enabled = !_submitting;

    final form = RotaCard(
      padding: RotaCardPadding.lg,
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_submitError != null) ...[
              RotaAlert(
                key: _alertKey,
                tone: RotaTone.danger,
                title: 'Não foi possível concluir sua reserva',
                message: '$_submitError Seus dados foram mantidos, é só tentar de novo.',
              ),
              const SizedBox(height: RotaSpacing.s6),
            ],
            const SectionTitle('Quando e quantas pessoas'),
            const SizedBox(height: RotaSpacing.s4),
            FieldRow(
              children: [
                RotaSelect<DateTime>(
                  label: 'Data',
                  required: true,
                  placeholder: 'Escolha uma data',
                  focusNode: _focus[BookingField.date],
                  enabled: enabled,
                  value: _date,
                  error: _visibleError(BookingField.date),
                  options: [
                    for (final date in experience.availableDates) RotaSelectOption(date, RotaFormat.longDate(date)),
                  ],
                  onChanged: (value) => setState(() {
                    _date = value;
                    _touched.add(BookingField.date);
                  }),
                ),
                RotaSelect<int>(
                  label: 'Pessoas',
                  required: true,
                  focusNode: _focus[BookingField.guests],
                  enabled: enabled,
                  value: _guests,
                  hint: 'Máximo de ${experience.maxGuests} por reserva.',
                  error: _visibleError(BookingField.guests),
                  options: [
                    for (var i = 1; i <= experience.maxGuests; i++) RotaSelectOption(i, RotaFormat.guests(i)),
                  ],
                  onChanged: (value) => setState(() => _guests = value),
                ),
              ],
            ),
            const SizedBox(height: RotaSpacing.s6),
            const Divider(),
            const SizedBox(height: RotaSpacing.s6),
            const SectionTitle('Seus dados'),
            const SizedBox(height: RotaSpacing.s4),
            RotaTextField(
              label: 'Nome completo',
              required: true,
              icon: Icons.person_outline,
              controller: _name,
              focusNode: _focus[BookingField.name],
              enabled: enabled,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
              error: _visibleError(BookingField.name),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: RotaSpacing.s4),
            FieldRow(
              children: [
                RotaTextField(
                  label: 'E-mail',
                  required: true,
                  placeholder: 'voce@exemplo.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  focusNode: _focus[BookingField.email],
                  enabled: enabled,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  error: _visibleError(BookingField.email),
                  onChanged: (_) => setState(() {}),
                ),
                RotaTextField(
                  label: 'Telefone',
                  required: true,
                  placeholder: '(11) 98765-4321',
                  icon: Icons.phone_outlined,
                  controller: _phone,
                  focusNode: _focus[BookingField.phone],
                  enabled: enabled,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: const [PhoneInputFormatter()],
                  textInputAction: TextInputAction.next,
                  error: _visibleError(BookingField.phone),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: RotaSpacing.s4),
            RotaTextField(
              label: 'Observações',
              hint: 'Restrições alimentares, acessibilidade ou outros pedidos. Opcional.',
              controller: _notes,
              focusNode: _focus[BookingField.notes],
              enabled: enabled,
              maxLines: 4,
              maxLength: 320,
              keyboardType: TextInputType.multiline,
              error: _visibleError(BookingField.notes),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: RotaSpacing.s4),
            RotaCheckbox(
              label: 'Li e aceito a política de cancelamento: grátis até 48 horas antes da experiência.',
              value: _acceptedPolicy,
              focusNode: _focus[BookingField.acceptedPolicy],
              error: _visibleError(BookingField.acceptedPolicy),
              onChanged: enabled ? (value) => setState(() => _acceptedPolicy = value) : null,
            ),
            const SizedBox(height: RotaSpacing.s6),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: RotaSpacing.s3,
              runSpacing: RotaSpacing.s3,
              children: [
                RotaButton(
                  label: 'Voltar',
                  icon: Icons.arrow_back,
                  variant: RotaButtonVariant.ghost,
                  onPressed: _submitting ? null : _goBack,
                ),
                RotaButton(
                  label: _submitting ? 'Confirmando…' : 'Confirmar reserva de ${RotaFormat.currency(total)}',
                  size: RotaButtonSize.lg,
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RotaBreadcrumb(
          items: [
            RotaBreadcrumbItem('Explorar', onTap: () => context.goNamed(AppRoutes.explore)),
            RotaBreadcrumbItem(
              experience.title,
              onTap: () => context.goNamed(AppRoutes.experience, pathParameters: {'id': experience.id}),
            ),
            const RotaBreadcrumbItem('Reserva'),
          ],
        ),
        const SizedBox(height: RotaSpacing.s6),
        const PageHeader(
          title: 'Finalize sua reserva',
          subtitle: 'Preencha seus dados. A confirmação chega por e-mail na hora.',
        ),
        const SizedBox(height: RotaSpacing.s8),
        SplitLayout(
          main: form,
          aside: _BookingSummary(experience: experience, date: _date, guests: _guests),
        ),
      ],
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.experience, required this.date, required this.guests});

  final Experience experience;
  final DateTime? date;
  final int guests;

  @override
  Widget build(BuildContext context) {
    final c = context.rotaColors;
    final total = experience.price * guests;
    return RotaCard(
      padding: RotaCardPadding.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(RotaRadius.md),
                child: SizedBox.square(dimension: 64, child: ExperienceArt(art: experience.art)),
              ),
              const SizedBox(width: RotaSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(experience.title, style: RotaTypography.cardTitle.copyWith(color: c.text)),
                    const SizedBox(height: RotaSpacing.s1),
                    Text(experience.location, style: RotaTypography.bodySm.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RotaSpacing.s4),
          const Divider(),
          const SizedBox(height: RotaSpacing.s3),
          DetailLine(label: 'Data', value: date == null ? 'A escolher' : RotaFormat.longDate(date!)),
          DetailLine(
            label: '${RotaFormat.currency(experience.price)} x ${RotaFormat.guests(guests)}',
            value: RotaFormat.currency(total),
          ),
          const DetailLine(label: 'Taxa de serviço', value: 'Grátis'),
          const SizedBox(height: RotaSpacing.s3),
          const Divider(),
          const SizedBox(height: RotaSpacing.s3),
          DetailLine(label: 'Total', value: RotaFormat.currency(total), emphasis: true),
        ],
      ),
    );
  }
}
