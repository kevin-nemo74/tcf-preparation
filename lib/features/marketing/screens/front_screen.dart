import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/widgets/premium_ui.dart';
import 'package:tcf_canada_preparation/features/auth/screens/login_screen.dart';

class FrontScreen extends StatelessWidget {
  const FrontScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWebLayout = MediaQuery.sizeOf(context).width >= 1024;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.22),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, isWebLayout ? 24 : 16, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: isWebLayout
                          ? const _WebLanding()
                          : const _MobileLanding(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WebLanding extends StatelessWidget {
  const _WebLanding();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _WebTopBar(),
        const SizedBox(height: 18),
        const _WebHero(),
        const SizedBox(height: 14),
        _WebSection(
          title: 'Nos Services',
          subtitle:
              'Tout ce dont vous avez besoin pour reussir votre TCF Canada',
          child: const _WebServicesRow(),
        ),
        const SizedBox(height: 14),
        _WebSection(
          title: 'Tarifs',
          subtitle: 'Choisissez l\'acces qui vous convient',
          child: const _WebPricingRow(),
        ),
        const SizedBox(height: 14),
        _WebSection(
          title: 'Contact',
          subtitle: 'Contactez-nous pour plus d\'informations',
          child: const _WebContactRow(),
        ),
      ],
    );
  }
}

class _WebTopBar extends StatelessWidget {
  const _WebTopBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const PremiumBrandMark(),
          const SizedBox(width: 10),
          Text(
            'TCF Canada Preparation',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const Spacer(),
          _TopChip(text: 'TCF Canada'),
          const SizedBox(width: 8),
          _TopChip(text: 'Preparation'),
          const SizedBox(width: 8),
          _TopChip(text: 'Plateforme Web'),
        ],
      ),
    );
  }
}

class _TopChip extends StatelessWidget {
  final String text;
  const _TopChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.primaryContainer.withValues(alpha: 0.55),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _WebHero extends StatelessWidget {
  const _WebHero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumBrandMark(large: true),
                const SizedBox(height: 14),
                Text(
                  'Reussissez Votre\nTCF Canada',
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preparez-vous efficacement avec nos tests d\'entrainement et nos ressources completes.',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                _CheckLine(text: 'Comprehension Ecrite et Orale'),
                const SizedBox(height: 8),
                _CheckLine(text: '+1000 textes et extraits sonores'),
                const SizedBox(height: 8),
                _CheckLine(text: 'Corrections des taches recents'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _goToLogin(context),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Commencer maintenant'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.primaryContainer.withValues(alpha: 0.25),
                border: Border.all(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: cs.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Contenu Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CheckLine(text: '40 tests d\'entrainement'),
                  const SizedBox(height: 8),
                  _CheckLine(text: '+1000 textes pour la comprehension'),
                  const SizedBox(height: 8),
                  _CheckLine(text: '+1000 extraits sonores'),
                  const SizedBox(height: 8),
                  _CheckLine(text: 'Corrections Tache 2 et Tache 3'),
                  const SizedBox(height: 8),
                  _CheckLine(text: 'Support par WhatsApp'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _WebSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _WebServicesRow extends StatelessWidget {
  const _WebServicesRow();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ServiceCard(
              icon: Icons.menu_book_rounded,
              title: 'Comprehension Ecrite',
              text: '40 tests d\'entrainement\n+1000 Textes',
              highlight: '40 tests',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.headphones_rounded,
              title: 'Comprehension Orale',
              text: '40 tests d\'entrainement\n+1000 Extraits sonores',
              highlight: '40 tests',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.record_voice_over_rounded,
              title: 'Expression Orale Tache 2',
              text: 'Corrections des\nactualites recentes',
              highlight: 'Corrections',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.speaker_phone_rounded,
              title: 'Expression Orale Tache 3',
              text: 'Corrections des\nactualites recentes',
              highlight: 'Corrections',
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String highlight;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              highlight,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.76),
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebPricingRow extends StatelessWidget {
  const _WebPricingRow();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PricePlanCard(
              title: 'Essentiel - 15 jours',
              details: [
                '40 tests d\'entrainement',
                'Comprehension Ecrite & Orale',
                '+1000 Textes et Extraits sonores',
                'Corrections Tache 2 & Tache 3',
              ],
              price: '15\$',
              isPopular: false,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: _PricePlanCard(
              title: 'Standard - 30 jours',
              details: [
                '40 tests d\'entrainement',
                'Comprehension Ecrite & Orale',
                '+1000 Textes et Extraits sonores',
                'Corrections Tache 2 & Tache 3',
                'Support par WhatsApp',
              ],
              price: '25\$',
              isPopular: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricePlanCard extends StatelessWidget {
  final String title;
  final List<String> details;
  final String price;
  final bool isPopular;

  const _PricePlanCard({
    required this.title,
    required this.details,
    required this.price,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isPopular
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: isPopular
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'POPULAIRE',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...details.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: isPopular
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isPopular ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: isPopular ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebContactRow extends StatelessWidget {
  const _WebContactRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            title: 'Email',
            value: 'tcfmaple@gmail.com',
            icon: Icons.email_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            title: 'WhatsApp',
            value: '+213 557 911 298',
            icon: Icons.chat_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _goToLogin(context),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Connexion'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _ContactCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 90,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLanding extends StatelessWidget {
  const _MobileLanding();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MobileHero(),
        SizedBox(height: 16),
        _MobileServices(),
        SizedBox(height: 14),
        _MobilePricing(),
        SizedBox(height: 14),
        _MobileContact(),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PremiumBrandMark(),
          const SizedBox(height: 14),
          Text(
            'Reussissez Votre\nTCF Canada',
            textAlign: TextAlign.center,
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Preparez-vous efficacement avec nos tests et ressources completes.',
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _goToLogin(context),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Commencer maintenant'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileServices extends StatelessWidget {
  const _MobileServices();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nos Services',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 14),
          _MobileServiceItem(
            icon: Icons.menu_book_rounded,
            title: 'Comprehension Ecrite',
            subtitle: '40 tests + 1000 Textes',
          ),
          const SizedBox(height: 12),
          _MobileServiceItem(
            icon: Icons.headphones_rounded,
            title: 'Comprehension Orale',
            subtitle: '40 tests + 1000 Extraits sonores',
          ),
          const SizedBox(height: 12),
          _MobileServiceItem(
            icon: Icons.record_voice_over_rounded,
            title: 'Expression Orale Tache 2',
            subtitle: 'Corrections des actualites',
          ),
          const SizedBox(height: 12),
          _MobileServiceItem(
            icon: Icons.speaker_phone_rounded,
            title: 'Expression Orale Tache 3',
            subtitle: 'Corrections des actualites',
          ),
        ],
      ),
    );
  }
}

class _MobileServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MobileServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: cs.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobilePricing extends StatelessWidget {
  const _MobilePricing();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarifs',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 14),
          _MobilePriceCard(
            title: 'Essentiel - 15 jours',
            price: '15\$',
            features: [
              '40 tests d\'entrainement',
              'Comprehension Ecrite & Orale',
              '+1000 Textes et Extraits',
              'Corrections Tache 2 & Tache 3',
            ],
            isPopular: false,
          ),
          const SizedBox(height: 12),
          _MobilePriceCard(
            title: 'Standard - 30 jours',
            price: '25\$',
            features: [
              '40 tests d\'entrainement',
              'Comprehension Ecrite & Orale',
              '+1000 Textes et Extraits',
              'Corrections Tache 2 & Tache 3',
              'Support par WhatsApp',
            ],
            isPopular: true,
          ),
        ],
      ),
    );
  }
}

class _MobilePriceCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isPopular;

  const _MobilePriceCard({
    required this.title,
    required this.price,
    required this.features,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isPopular
            ? cs.primaryContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: isPopular
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'POPULAIRE',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: isPopular
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isPopular ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: isPopular ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileContact extends StatelessWidget {
  const _MobileContact();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 14),
          _MobileContactRow(
            icon: Icons.email_rounded,
            title: 'Email',
            value: 'tcfmaple@gmail.com',
          ),
          const SizedBox(height: 12),
          _MobileContactRow(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            value: '+213 557 911 298',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _goToLogin(context),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Connexion'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MobileContactRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckLine extends StatelessWidget {
  final String text;
  const _CheckLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

void _goToLogin(BuildContext context) {
  AppAnalytics.logLandingCtaClicked();
  Navigator.push(context, AppRoutes.fadeSlide(const LoginScreen()));
}
