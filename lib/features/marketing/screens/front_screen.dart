import 'package:flutter/material.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WebTopBar(),
        SizedBox(height: 18),
        _WebHero(),
        SizedBox(height: 14),
        _WebSection(
          title: 'Services',
          subtitle: 'Ce que MapleTcf propose actuellement',
          child: _WebServicesRow(),
        ),
        SizedBox(height: 14),
        _WebSection(
          title: 'Tarifs',
          subtitle: 'Formules de preparation',
          child: _WebPricingRow(),
        ),
        SizedBox(height: 14),
        _WebSection(
          title: 'Contact',
          subtitle: 'Parlez avec notre equipe',
          child: _WebContactRow(),
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
      child: const Row(
        children: [
          PremiumBrandMark(),
          SizedBox(width: 10),
          Text(
            'MapleTcf',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          Spacer(),
          _TopChip(text: 'TCF Canada'),
          SizedBox(width: 8),
          _TopChip(text: 'Preparation'),
          SizedBox(width: 8),
          _TopChip(text: 'Plateforme web'),
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
                  'MapleTcf',
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plateforme specialisee dans la preparation au TCF Canada. Entrainez-vous avec des tests adaptes et des sujets mis a jour',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                const _CheckLine(text: '40 tests ecrits et 40 tests oraux'),
                const SizedBox(height: 8),
                const _CheckLine(
                  text: 'Livres PDF pour les expressions orale et ecrite',
                ),
                const SizedBox(height: 8),
                const _CheckLine(text: 'Sujets mis a jour'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _goToLogin(context),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Se connecter'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resume rapide',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _CheckLine(text: 'Essentiel: 15 jours - 30\$'),
                  SizedBox(height: 8),
                  _CheckLine(text: 'Standard: 30 jours - 55\$'),
                  SizedBox(height: 8),
                  _CheckLine(text: 'Contact direct par e-mail et telephone'),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 14),
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
              title: 'Tests ecrits',
              text: '40 tests ecrits adaptes au format TCF Canada',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.mic_rounded,
              title: 'Tests oraux',
              text: '40 tests oraux pour renforcer votre expression',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Ressources PDF',
              text: 'Livres PDF pour les expressions orale et ecrite',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ServiceCard(
              icon: Icons.update_rounded,
              title: 'Sujets mis a jour',
              text: 'Contenu revise regulierement',
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
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.76))),
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
              title: 'Acces essentiel - 15 jours',
              details: [
                '40 tests oraux',
                '40 tests ecrits',
                'Livres PDF pour les expressions orale et ecrite',
              ],
              price: '30\$',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _PricePlanCard(
              title: 'Acces standard - 30 jours',
              details: [
                '40 tests oraux',
                '40 tests ecrits',
                'Livres PDF pour les expressions orale et ecrite',
                'Memes avantages que l offre Essentiel',
              ],
              price: '55\$',
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
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            title: 'E-mail',
            value: 'hello@mapletcf.com',
            icon: Icons.email_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            title: 'Telephone',
            value: '+1 514 555 0147',
            icon: Icons.phone_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactCard(
            title: 'Support',
            value: 'Lundi a vendredi - 9:00 a 18:00',
            icon: Icons.support_agent_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
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
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.78)),
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
          const SizedBox(height: 12),
          Text(
            'MapleTcf',
            textAlign: TextAlign.center,
            style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Plateforme specialisee dans la preparation au TCF Canada. Entrainez-vous avec des tests adaptes et des sujets mis a jour',
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _goToLogin(context),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Se connecter'),
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
    return const _MobileSection(
      title: 'Services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(text: '40 tests oraux'),
          _Line(text: '40 tests ecrits'),
          _Line(text: 'Livres PDF pour les expressions orale et ecrite'),
          _Line(text: 'Sujets mis a jour'),
        ],
      ),
    );
  }
}

class _MobilePricing extends StatelessWidget {
  const _MobilePricing();

  @override
  Widget build(BuildContext context) {
    return const _MobileSection(
      title: 'Tarifs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PricePlanCard(
            title: 'Acces essentiel - 15 jours',
            details: [
              '40 tests oraux',
              '40 tests ecrits',
              'Livres PDF pour les expressions orale et ecrite',
            ],
            price: '30\$',
          ),
          SizedBox(height: 10),
          _PricePlanCard(
            title: 'Acces standard - 30 jours',
            details: [
              '40 tests oraux',
              '40 tests ecrits',
              'Livres PDF pour les expressions orale et ecrite',
              'Memes avantages que l offre Essentiel',
            ],
            price: '55\$',
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
    return const _MobileSection(
      title: 'Contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(text: 'Email: hello@mapletcf.com'),
          _Line(text: 'Telephone: +1 514 555 0147'),
          _Line(text: 'Support: Lundi a vendredi - 9:00 a 18:00'),
        ],
      ),
    );
  }
}

class _MobileSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _MobileSection({required this.title, required this.child});

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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PricePlanCard extends StatelessWidget {
  final String title;
  final List<String> details;
  final String price;

  const _PricePlanCard({
    required this.title,
    required this.details,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          ...details.map((line) => _Line(text: line)),
          Text(
            'Prix: $price',
            style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
          ),
        ],
      ),
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
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final String text;
  const _Line({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.82), height: 1.3),
      ),
    );
  }
}

void _goToLogin(BuildContext context) {
  Navigator.push(context, AppRoutes.fadeSlide(const LoginScreen()));
}
