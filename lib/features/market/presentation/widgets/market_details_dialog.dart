import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/market_details.dart';
import '../../domain/entities/market_instrument.dart';
import '../cubit/market_cubit.dart';

class MarketDetailsDialog extends StatelessWidget {
  final MarketInstrument instrument;
  final String title;

  const MarketDetailsDialog({
    super.key,
    required this.instrument,
    required this.title,
  });

  static const _gramsPerTroyOunce = 31.1034768;
  static const _gold21kRatio = 21.0 / 24.0;
  static const _gold18kRatio = 18.0 / 24.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Result<MarketDetails>>(
          future: context.read<MarketCubit>().fetchDetails(instrument),
          builder: (context, snap) {
            final result = snap.data;
            if (snap.connectionState != ConnectionState.done ||
                result == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context,
                      subtitle: context.tr('loading', fallback: 'Loading…')),
                  const SizedBox(height: 14),
                  const ShimmerLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 10),
                  const ShimmerLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 10),
                  const ShimmerLoader(width: double.infinity, height: 16),
                ],
              );
            }

            if (result.isError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context,
                      subtitle: context.tr('failed_to_load',
                          fallback: 'Failed to load')),
                  const SizedBox(height: 12),
                  Text(
                    result.failure!.message,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.tr('close', fallback: 'Close')),
                    ),
                  ),
                ],
              );
            }

            final details = result.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context,
                    subtitle: _formatTime(details.latestTimestamp)),
                const SizedBox(height: 12),
                _sectionTitle(context,
                    context.tr('latest_rates', fallback: 'Latest')),
                const SizedBox(height: 8),
                ..._latestRows(context, details),
                if (details.ohlc != null) ...[
                  const SizedBox(height: 14),
                  _sectionTitle(context,
                      context.tr('ohlc_yesterday', fallback: 'OHLC (Yesterday, GMT)')),
                  const SizedBox(height: 8),
                  ..._ohlcRows(context, details.ohlc!, instrument),
                ],
                if (details.changeWeek != null) ...[
                  const SizedBox(height: 14),
                  _sectionTitle(context,
                      context.tr('change_7days', fallback: 'Change (7 days)')),
                  const SizedBox(height: 8),
                  ..._changeRows(context, details.changeWeek!, instrument),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.tr('close', fallback: 'Close')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, {required String subtitle}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<Widget> _latestRows(BuildContext context, MarketDetails details) {
    if (instrument == MarketInstrument.gold24k ||
        instrument == MarketInstrument.gold21k ||
        instrument == MarketInstrument.gold18k) {
      final perOunce = details.latestRate;
      final basePerGram24k = perOunce / _gramsPerTroyOunce;
      final perGram21k = basePerGram24k * _gold21kRatio;
      final perGram18k = basePerGram24k * _gold18kRatio;
      return [
        _row(context, context.tr('per_troy_oz', fallback: 'Per troy oz'),
            '${perOunce.toStringAsFixed(2)} EGP'),
        _row(context, context.tr('per_gram_24k', fallback: 'Per gram 24K (est.)'),
            '${basePerGram24k.toStringAsFixed(2)} EGP'),
        _row(context, context.tr('per_gram_21k', fallback: 'Per gram 21K (est.)'),
            '${perGram21k.toStringAsFixed(2)} EGP'),
        _row(context, context.tr('per_gram_18k', fallback: 'Per gram 18K (est.)'),
            '${perGram18k.toStringAsFixed(2)} EGP'),
      ];
    }
    return [
      _row(context, context.tr('one_usd', fallback: '1 USD'),
          '${details.latestRate.toStringAsFixed(4)} EGP'),
    ];
  }

  List<Widget> _ohlcRows(
      BuildContext context, MarketOhlc ohlc, MarketInstrument inst) {
    String fmt(double v) {
      if (inst == MarketInstrument.gold24k ||
          inst == MarketInstrument.gold21k ||
          inst == MarketInstrument.gold18k) {
        return '${v.toStringAsFixed(2)} EGP/oz';
      }
      return '${v.toStringAsFixed(4)} EGP';
    }

    return [
      _row(context, 'Open', fmt(ohlc.open)),
      _row(context, 'High', fmt(ohlc.high)),
      _row(context, 'Low', fmt(ohlc.low)),
      _row(context, 'Close', fmt(ohlc.close)),
    ];
  }

  List<Widget> _changeRows(
      BuildContext context, MarketChange change, MarketInstrument inst) {
    String fmtRate(double v) {
      if (inst == MarketInstrument.gold24k ||
          inst == MarketInstrument.gold21k ||
          inst == MarketInstrument.gold18k) {
        return '${v.toStringAsFixed(6)} EGP/oz';
      }
      return '${v.toStringAsFixed(6)} EGP';
    }

    return [
      _row(context, 'From',
          '${_formatDate(change.startDate)} • ${fmtRate(change.startRate)}'),
      _row(context, 'To',
          '${_formatDate(change.endDate)} • ${fmtRate(change.endRate)}'),
      _row(context, 'Change', '${change.changePct.toStringAsFixed(2)}%'),
    ];
  }

  Widget _row(BuildContext context, String k, String v) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            v,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}/${two(l.month)}/${l.year} ${two(l.hour)}:${two(l.minute)}';
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}/${two(l.month)}/${l.year}';
  }
}
