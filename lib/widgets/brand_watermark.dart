import 'package:flutter/material.dart';

class BrandWatermark extends StatelessWidget {
  const BrandWatermark({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(.72),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: cs.outlineVariant.withOpacity(.35)),
            ),
            child: Text(
              'Alexis David Obil Colli · Eliana Sarai Sima Tut',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(.75),
                    letterSpacing: .2,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
