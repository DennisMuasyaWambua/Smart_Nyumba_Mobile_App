import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simple in-app viewer for the privacy policy and terms of service.
class PolicyScreen extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> sections;

  const PolicyScreen.privacyPolicy({super.key})
      : title = 'Privacy Policy',
        sections = const [
          MapEntry(
            'Information We Collect',
            'Smart Nyumba collects the information you provide when '
                'registering and using the app: your name, email address, '
                'phone number, national ID number, and details of the '
                'property you occupy or manage.',
          ),
          MapEntry(
            'How We Use Your Information',
            'Your information is used to manage tenancy records, process '
                'rent and service charge payments, coordinate repair '
                'requests, and send you notifications about your account. '
                'Payment processing is handled by licensed payment '
                'providers; Smart Nyumba does not store your M-Pesa PIN or '
                'card details.',
          ),
          MapEntry(
            'Sharing',
            'Your information is shared only with the landlord, caretaker, '
                'or property managers of your estate as needed to provide '
                'the service. We do not sell your personal data to third '
                'parties.',
          ),
          MapEntry(
            'Data Security',
            'Data is transmitted over encrypted connections and access is '
                'restricted to authenticated users with an appropriate role.',
          ),
          MapEntry(
            'Contact',
            'For questions or data deletion requests, contact your estate '
                'administrator or reach us through smartnyumba.tech.',
          ),
        ];

  const PolicyScreen.termsOfService({super.key})
      : title = 'Terms of Service',
        sections = const [
          MapEntry(
            'Acceptance of Terms',
            'By creating an account and using Smart Nyumba you agree to '
                'these terms. If you do not agree, do not use the app.',
          ),
          MapEntry(
            'The Service',
            'Smart Nyumba provides property management tools: rent and '
                'service charge payments, repair requests, tenant '
                'onboarding, and estate communication. The service is '
                'provided "as is" and may change over time.',
          ),
          MapEntry(
            'Payments',
            'Payments made through the app are processed by third-party '
                'payment providers. Amounts, due dates, and any commission '
                'are set by your landlord or estate management. Always '
                'confirm payment details before approving a transaction.',
          ),
          MapEntry(
            'Your Responsibilities',
            'You are responsible for keeping your login credentials secure '
                'and for the accuracy of the information you provide. '
                'Misuse of the platform may result in account suspension.',
          ),
          MapEntry(
            'Liability',
            'Smart Nyumba is not a party to the tenancy agreement between '
                'you and your landlord and is not liable for disputes '
                'arising from that relationship.',
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.key,
                  style: GoogleFonts.hind(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  section.value,
                  style: GoogleFonts.hind(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
