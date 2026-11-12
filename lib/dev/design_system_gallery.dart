import 'package:flutter/material.dart';

import 'package:repara/app/theme/app_theme.dart';
import 'package:repara/app/theme/tokens.dart';
import 'package:repara/app/theme/typography.dart';
import 'package:repara/core/widgets/app_empty_view.dart';
import 'package:repara/core/widgets/app_error_view.dart';
import 'package:repara/core/widgets/app_skeleton.dart';
import 'package:repara/core/widgets/location_pill.dart';
import 'package:repara/core/widgets/primary_button.dart';
import 'package:repara/core/widgets/status_chip.dart';
import 'package:repara/core/widgets/step_badge.dart';
import 'package:repara/core/widgets/surface_card.dart';
import 'package:repara/features/demands/domain/entities/status_demanda.dart';

/// Developer-only gallery of the design-system tokens and base widgets.
///
/// It is registered at `/dev/design-system` only when `buildAppRouter` receives
/// `includeDesignSystemGallery: true` (defaults to `kDebugMode`), so release
/// builds never expose it. Demo callbacks show a [SnackBar] instead of leaving
/// dead buttons in the gallery.
class DesignSystemGalleryPage extends StatelessWidget {
  const DesignSystemGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReparaSpacing.md),
          children: [
            _Section(
              title: 'Foco',
              children: [
                Text(
                  'Anel de foco sólido de 2 px. Use Tab para navegar entre os '
                  'controles; o anel não desloca o layout.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                PrimaryButton(
                  label: 'Botão com foco visível',
                  autofocus: true,
                  onPressed: () =>
                      _showDemoMessage(context, 'Foco visível acionado'),
                ),
              ],
            ),
            _Section(
              title: 'Cores',
              children: [
                for (final token in _colorTokens)
                  _ColorTokenRow(name: token.$1, color: token.$2),
              ],
            ),
            _Section(
              title: 'Tipografia',
              children: [
                _TypeSample(name: 'display', style: ReparaTypography.display),
                _TypeSample(name: 'h1', style: ReparaTypography.h1),
                _TypeSample(name: 'h2', style: ReparaTypography.h2),
                _TypeSample(name: 'h3', style: ReparaTypography.h3),
                _TypeSample(name: 'title', style: ReparaTypography.title),
                _TypeSample(name: 'body', style: ReparaTypography.body),
                _TypeSample(
                  name: 'bodySmall',
                  style: ReparaTypography.bodySmall,
                ),
                _TypeSample(name: 'label', style: ReparaTypography.label),
                _TypeSample(name: 'caption', style: ReparaTypography.caption),
                _TypeSample(
                  name: 'labelLarge',
                  style: ReparaTypography.labelLarge,
                ),
              ],
            ),
            _Section(
              title: 'Espaçamento e raios',
              children: [
                const _Subheading('Espaçamento'),
                for (final spacing in _spacingTokens)
                  _SpacingSample(name: spacing.$1, value: spacing.$2),
                const _Subheading('Raios'),
                for (final radius in _radiusTokens)
                  _RadiusSample(name: radius.$1, radius: radius.$2),
              ],
            ),
            _Section(
              title: 'Tamanhos',
              children: [
                for (final size in _sizeTokens)
                  _SizeSample(name: size.$1, value: size.$2),
              ],
            ),
            _Section(
              title: 'Sombras',
              children: [
                for (final shadow in _shadowTokens)
                  _ShadowSample(name: shadow.$1, shadows: shadow.$2),
              ],
            ),
            _Section(
              title: 'Durações',
              children: [
                for (final duration in _durationTokens)
                  _DurationSample(name: duration.$1, duration: duration.$2),
              ],
            ),
            _Section(
              title: 'Tema de captura',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ReparaSpacing.md),
                  decoration: BoxDecoration(
                    color: ReparaColors.captureBackground,
                    borderRadius: BorderRadius.circular(ReparaRadii.lg),
                  ),
                  child: Theme(
                    data: AppTheme.capture,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StepBadge(current: 2, total: 3),
                        const SizedBox(height: ReparaSpacing.sm),
                        PrimaryButton(
                          label: 'Ação no tema de captura',
                          onPressed: () => _showDemoMessage(
                            context,
                            'Ação do tema de captura acionada',
                          ),
                        ),
                        const SizedBox(height: ReparaSpacing.sm),
                        const LocationPill(
                          label: 'Local capturado · precisão ±8 m',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _Section(
              title: 'Componentes',
              children: [
                const _Subheading('PrimaryButton'),
                Wrap(
                  spacing: ReparaSpacing.sm,
                  runSpacing: ReparaSpacing.sm,
                  children: [
                    PrimaryButton(
                      label: 'Ação principal',
                      onPressed: () =>
                          _showDemoMessage(context, 'Ação principal acionada'),
                    ),
                    const PrimaryButton(label: 'Desabilitado'),
                    PrimaryButton(
                      label: 'Carregando',
                      isLoading: true,
                      onPressed: () => _showDemoMessage(
                        context,
                        'Ação de carregamento acionada',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ReparaSpacing.xs),
                PrimaryButton(
                  label: 'Expandido com ícone',
                  icon: Icons.add,
                  expand: true,
                  onPressed: () =>
                      _showDemoMessage(context, 'Ação expandida acionada'),
                ),
                const _Subheading('StatusChip'),
                const Wrap(
                  spacing: ReparaSpacing.xs,
                  runSpacing: ReparaSpacing.xs,
                  children: [
                    StatusChip(status: StatusDemanda.aberta),
                    StatusChip(status: StatusDemanda.emAndamento),
                    StatusChip(status: StatusDemanda.resolvida),
                    StatusChip(status: StatusDemanda.rejeitada),
                    StatusChip(
                      status: StatusDemanda.emAndamento,
                      label: 'Em análise',
                    ),
                  ],
                ),
                const _Subheading('StepBadge'),
                Container(
                  padding: const EdgeInsets.all(ReparaSpacing.md),
                  decoration: BoxDecoration(
                    color: ReparaColors.captureBackground,
                    borderRadius: BorderRadius.circular(ReparaRadii.md),
                  ),
                  child: const Wrap(
                    spacing: ReparaSpacing.xs,
                    children: [StepBadge(current: 1, total: 3)],
                  ),
                ),
                const _Subheading('SurfaceCard'),
                SurfaceCard(
                  onTap: () =>
                      _showDemoMessage(context, 'Card acionável tocado'),
                  child: const _CardContent(
                    title: 'Card acionável',
                    description: 'Toque para ver o ripple.',
                  ),
                ),
                const SizedBox(height: ReparaSpacing.xs),
                const SurfaceCard(
                  child: _CardContent(
                    title: 'Card estático',
                    description: 'Sem callback, sem área de toque.',
                  ),
                ),
                const _Subheading('AppSkeleton'),
                const AppSkeleton(height: ReparaSpacing.xxl),
                const SizedBox(height: ReparaSpacing.xs),
                const Row(
                  children: [
                    AppSkeleton(
                      width: ReparaSpacing.xxxl * 5,
                      height: ReparaSpacing.md,
                    ),
                    SizedBox(width: ReparaSpacing.xs),
                    AppSkeleton(
                      width: ReparaSpacing.xxxl,
                      height: ReparaSpacing.md,
                    ),
                  ],
                ),
                const SizedBox(height: ReparaSpacing.xs),
                const AppSkeleton(
                  height: ReparaSpacing.md,
                  semanticLabel: 'Carregando conteúdo',
                ),
                const _Subheading('AppEmptyView'),
                SizedBox(
                  height: ReparaSpacing.xxxl * 7,
                  child: AppEmptyView(
                    title: 'Nenhuma demanda por perto',
                    message:
                        'Tente outra região ou registre uma nova ocorrência.',
                    action: PrimaryButton(
                      label: 'Registrar',
                      onPressed: () =>
                          _showDemoMessage(context, 'Registrar acionado'),
                    ),
                  ),
                ),
                const _Subheading('AppErrorView'),
                SizedBox(
                  height: ReparaSpacing.xxxl * 7,
                  child: AppErrorView(
                    message: 'Não foi possível carregar as demandas.',
                    onRetry: () =>
                        _showDemoMessage(context, 'Tentar novamente acionado'),
                  ),
                ),
                const SizedBox(height: ReparaSpacing.xs),
                SizedBox(
                  height: ReparaSpacing.xxxl * 7,
                  child: AppErrorView(
                    message: 'Nova tentativa em andamento.',
                    isRetrying: true,
                    onRetry: () =>
                        _showDemoMessage(context, 'Nova tentativa acionada'),
                  ),
                ),
                const _Subheading('LocationPill'),
                LocationPill(
                  label: 'Porto Alegre · Centro Histórico',
                  onTrailingTap: () =>
                      _showDemoMessage(context, 'Trocar região acionado'),
                ),
                const SizedBox(height: ReparaSpacing.xs),
                const LocationPill(label: 'Local capturado · precisão ±8 m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Named color tokens with a swatch and the token name.
const _colorTokens = <(String, Color)>[
  ('brand.primary', ReparaColors.brandPrimary),
  ('brand.ink', ReparaColors.brandInk),
  ('brand.soft', ReparaColors.brandSoft),
  ('focusRing', ReparaColors.focusRing),
  ('accent.amber', ReparaColors.accentAmber),
  ('accent.amberPressed', ReparaColors.accentAmberPressed),
  ('canvas', ReparaColors.canvas),
  ('surface', ReparaColors.surface),
  ('surface.muted', ReparaColors.surfaceMuted),
  ('skeleton.base', ReparaColors.skeletonBase),
  ('skeleton.highlight', ReparaColors.skeletonHighlight),
  ('map.canvas', ReparaColors.mapCanvas),
  ('map.block', ReparaColors.mapBlock),
  ('map.blockAlt', ReparaColors.mapBlockAlt),
  ('map.road', ReparaColors.mapRoad),
  ('map.water', ReparaColors.mapWater),
  ('ink', ReparaColors.ink),
  ('ink.muted', ReparaColors.inkMuted),
  ('border', ReparaColors.border),
  ('status.open.bg', ReparaColors.statusOpenBackground),
  ('status.open.fg', ReparaColors.statusOpenForeground),
  ('status.inProgress.bg', ReparaColors.statusInProgressBackground),
  ('status.inProgress.fg', ReparaColors.statusInProgressForeground),
  ('status.resolved.bg', ReparaColors.statusResolvedBackground),
  ('status.resolved.fg', ReparaColors.statusResolvedForeground),
  ('status.rejected.bg', ReparaColors.statusRejectedBackground),
  ('status.rejected.fg', ReparaColors.statusRejectedForeground),
  ('marker.buraco', ReparaColors.markerBuraco),
  ('marker.esgoto', ReparaColors.markerEsgoto),
  ('marker.dejeto', ReparaColors.markerDejeto),
  ('marker.poste', ReparaColors.markerPoste),
  ('capture.bg', ReparaColors.captureBackground),
  ('capture.surface', ReparaColors.captureSurface),
  ('capture.surfaceAlt', ReparaColors.captureSurfaceAlt),
  ('capture.chip', ReparaColors.captureChip),
  ('capture.text', ReparaColors.captureText),
  ('capture.textMuted', ReparaColors.captureTextMuted),
  ('capture.divider', ReparaColors.captureDivider),
  ('error', ReparaColors.error),
  ('success', ReparaColors.success),
  ('scrim', ReparaColors.scrim),
  ('error.dark', ReparaColors.errorDark),
  ('onError.dark', ReparaColors.onErrorDark),
];

/// Spacing scale tokens (spec §5.3).
const _spacingTokens = <(String, double)>[
  ('xxs', ReparaSpacing.xxs),
  ('xs', ReparaSpacing.xs),
  ('sm', ReparaSpacing.sm),
  ('md', ReparaSpacing.md),
  ('lg', ReparaSpacing.lg),
  ('xl', ReparaSpacing.xl),
  ('xxl', ReparaSpacing.xxl),
  ('xxxl', ReparaSpacing.xxxl),
];

/// Radius tokens (spec §5.3).
const _radiusTokens = <(String, double)>[
  ('sm', ReparaRadii.sm),
  ('md', ReparaRadii.md),
  ('lg', ReparaRadii.lg),
  ('xl', ReparaRadii.xl),
  ('selector', ReparaRadii.selector),
  ('pill', ReparaRadii.pill),
];

/// Size tokens (spec §5.3/§5.4).
const _sizeTokens = <(String, double)>[
  ('minTouchTarget', ReparaSizes.minTouchTarget),
  ('focusRingWidth', ReparaSizes.focusRingWidth),
  ('primaryButtonMinWidth', ReparaSizes.primaryButtonMinWidth),
  ('primaryButtonHeight', ReparaSizes.primaryButtonHeight),
  ('appBarHeight', ReparaSizes.appBarHeight),
  ('iconTile', ReparaSizes.iconTile),
  ('statusChipHeight', ReparaSizes.statusChipHeight),
  ('stepBadgeMinWidth', ReparaSizes.stepBadgeMinWidth),
  ('stepBadgeHeight', ReparaSizes.stepBadgeHeight),
  ('locationPillHeight', ReparaSizes.locationPillHeight),
  ('iconSm', ReparaSizes.iconSm),
  ('hairline', ReparaSizes.hairline),
];

/// Elevation tokens (spec §5.3).
const _shadowTokens = <(String, List<BoxShadow>)>[
  ('cta', ReparaShadows.cta),
  ('sheet', ReparaShadows.sheet),
  ('marker', ReparaShadows.marker),
];

/// Motion duration tokens (spec §5.3).
const _durationTokens = <(String, Duration)>[
  ('fast', ReparaDurations.fast),
  ('standard', ReparaDurations.standard),
  ('slow', ReparaDurations.slow),
];

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ReparaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: ReparaSpacing.sm),
          for (final child in children) ...[
            child,
            const SizedBox(height: ReparaSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _Subheading extends StatelessWidget {
  const _Subheading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: ReparaSpacing.xs),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ColorTokenRow extends StatelessWidget {
  const _ColorTokenRow({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSizes.iconTile,
          height: ReparaSizes.iconTile,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ReparaRadii.sm),
              border: Border.all(
                color: ReparaColors.border,
                width: ReparaSizes.hairline,
              ),
            ),
          ),
        ),
        const SizedBox(width: ReparaSpacing.sm),
        Expanded(
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample({required this.name, required this.style});

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text('$name — Repara', style: style);
  }
}

class _SpacingSample extends StatelessWidget {
  const _SpacingSample({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSpacing.xxxl * 2,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(
          width: value,
          height: ReparaSpacing.xs,
          child: const ColoredBox(color: ReparaColors.brandPrimary),
        ),
        const SizedBox(width: ReparaSpacing.xs),
        Text(
          '${value.toStringAsFixed(0)} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _RadiusSample extends StatelessWidget {
  const _RadiusSample({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSpacing.xxxl * 2,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(
          width: ReparaSizes.minTouchTarget,
          height: ReparaSizes.minTouchTarget,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ReparaColors.surfaceMuted,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: ReparaColors.border,
                width: ReparaSizes.hairline,
              ),
            ),
          ),
        ),
        const SizedBox(width: ReparaSpacing.xs),
        Text(
          '${radius.toStringAsFixed(0)} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SizeSample extends StatelessWidget {
  const _SizeSample({required this.name, required this.value});

  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSpacing.xxxl * 5,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '${value.toStringAsFixed(0)} px',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ShadowSample extends StatelessWidget {
  const _ShadowSample({required this.name, required this.shadows});

  final String name;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSpacing.xxxl * 2,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(
          width: ReparaSizes.minTouchTarget,
          height: ReparaSizes.minTouchTarget,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(ReparaRadii.sm),
              boxShadow: shadows,
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationSample extends StatelessWidget {
  const _DurationSample({required this.name, required this.duration});

  final String name;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: ReparaSpacing.xxxl * 2,
          child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '${duration.inMilliseconds} ms',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ReparaSpacing.xxs),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
