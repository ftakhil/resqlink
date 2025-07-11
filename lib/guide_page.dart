import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Guide'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '"We cannot stop natural disasters, but we can arm ourselves with knowledge."',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _GuideTile(
                    icon: Icons.medical_services,
                    color: Colors.red,
                    title: 'First Aid',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FirstAidScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _GuideTile(
                    icon: Icons.list_alt,
                    color: Colors.blue,
                    title: 'Protocols',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProtocolScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _GuideTile(
                    icon: Icons.public,
                    color: Colors.green,
                    title: 'Disaster Safety',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DisasterSafetyScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _GuideTile({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}

// Placeholder screens for navigation
class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextStyle? normal = Theme.of(context).textTheme.bodyLarge;
    final TextStyle bold = normal?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: const Text('First Aid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: normal,
              children: [
                TextSpan(text: '1. Why First Aid Is Crucial During Disasters\n', style: bold),
                TextSpan(text: 'Disasters like floods, earthquakes, or storms often cause chaos. Roads may be blocked, medical help may take time to arrive, and people can be injured or very frightened. First aid—the simple things you do at the scene—can make a life-saving difference. It helps stop heavy bleeding, keeps airways open, and reassures people while waiting for rescuers.\n\nWhen you’re prepared and calm, you can help someone breathe easier, prevent shock, and reduce pain. Every minute counts—it can mean the difference between life and death, or a quick recovery instead of long-term injury.\n\n'),
                TextSpan(text: '2. Basic First Aid Kit: What You Really Need\n', style: bold),
                TextSpan(text: 'You don’t need fancy gear to start saving lives. Your kit should include:\n\nClean cloths or gauze pads for dressing wounds\nStrong tape and bandages\nSmall scissors and tweezers\nDisposable gloves (to protect both sides)\nA few pain relievers (like paracetamol)\nA flashlight and batteries\n\nStore everything in a sturdy box. Check it every few months, replace expired items, and keep it in an easy-to-find spot with your family, so everyone knows where it is in an emergency.\n\n'),
                TextSpan(text: '3. What to Do First: Stay Safe, Check Quickly\n', style: bold),
                TextSpan(text: 'Before helping, make sure it’s safe. Look around: is there jagged metal, fallen power lines, flooding? If yes, call for help first—it’s not worth risking more lives.\n\nIf it’s safe: check the person’s breathing and response. Can they talk or nod? If they\'re not breathing, call for emergency help, and start CPR: chest compressions plus rescue breaths (30:2 ratio). If you’re alone and don’t know CPR well, do hands-only chest compressions until help arrives. If they’re breathing but unconscious, gently place them on their side—this keeps their airway clear.\n\n'),
                TextSpan(text: '4. Stopping Bleeding and Protecting Wounds\n', style: bold),
                TextSpan(text: 'Heavy bleeding must be stopped fast. Make sure you wear gloves if you have them. Press firmly and continuously with a clean cloth or gauze. If the blood soaks through, put another cloth on top—don’t remove the soaked one. Keep pressing until the bleeding slows.\n\nAfter bleeding is under control, cover the wound with a clean dressing or bandage. This helps prevent infection. If the injury is deep, the person feels dizzy, or blood spurts out, keep pressure and get professional care immediately.\n\n'),
                TextSpan(text: '5. Helping with Fractures and Sprains\n', style: bold),
                TextSpan(text: 'If a limb looks bent unusually or the person can’t move it without severe pain, it might be broken. Don’t try to reset it. You can make a splint using sticks, rolled-up newspapers, or a stiff board. Tie it loosely above and below the injured area. Your goal is to keep the limb from moving too much and causing more damage.\n\nFor sprains—where joints swell and hurt—apply the RICE method:\nRest the injured part,\nIce to reduce swelling (wrap ice in cloth, don’t put it straight on skin),\nCompression with a bandage (not too tight),\nElevation—lift it higher than the heart if you can.\n\nThis helps reduce pain and swelling until professional care is possible.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProtocolScreen extends StatelessWidget {
  const ProtocolScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protocols')),
      body: const Center(child: Text('Protocols Content Here')),
    );
  }
}

class DisasterSafetyScreen extends StatelessWidget {
  const DisasterSafetyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster Safety')),
      body: const Center(child: Text('Disaster Safety Content Here')),
    );
  }
} 