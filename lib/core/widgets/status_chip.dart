import 'package:flutter/material.dart';

import 'package:repara/app/theme/tokens.dart';
import 'package:repara/app/theme/typography.dart';
import 'package:repara/features/demands/domain/entities/status_demanda.dart';

/// Compact pill that maps a [StatusDemanda] to the design-system colors and a
/// pt-BR presentation label.
///
/// The spec deliberately couples this core widget to the domain enum: §Fase 1
/// asks for `core/widgets/status_chip.dart` to map every status. "Encaminhada"
/// is the presentation label for [StatusDemanda.emAndamento], not a domain
/// value; [label] overrides the default text when the UI needs another label.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.label});

  /// Demand status being presented.
  final StatusDemanda status;

  /// Overrides the default pt-BR label for [status].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, defaultLabel) = switch (status) {
      StatusDemanda.aberta => (
        ReparaColors.statusOpenBackground,
        ReparaColors.statusOpenForeground,
        'Aberta',
      ),
      StatusDemanda.emAndamento => (
        ReparaColors.statusInProgressBackground,
        ReparaColors.statusInProgressForeground,
        'Encaminhada',
      ),
      StatusDemanda.resolvida => (
        ReparaColors.statusResolvedBackground,
        ReparaColors.statusResolvedForeground,
        'Resolvida',
      ),
      StatusDemanda.rejeitada => (
        ReparaColors.statusRejectedBackground,
        ReparaColors.statusRejectedForeground,
        'Rejeitada',
      ),
    };
    final displayLabel = label ?? defaultLabel;

    return Semantics(
      label: 'Status: $displayLabel',
      container: true,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: ReparaSizes.statusChipHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ReparaSpacing.xs,
          vertical: ReparaSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(ReparaRadii.pill),
        ),
        child: Text(
          displayLabel,
          style: ReparaTypography.label.copyWith(color: foreground),
        ),
      ),
    );
  }
}
