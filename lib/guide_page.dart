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
    final TextStyle? normal = Theme.of(context).textTheme.bodyLarge;
    final TextStyle bold = normal?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster Safety')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              style: normal,
              children: [
                TextSpan(text: '🛡 Disaster Safety: A Comprehensive Guide to Preparedness and Protection\n', style: bold),
                TextSpan(text: 'In an era of climate change, urban expansion, and unforeseen global crises, disaster safety is not just a responsibility—it\'s a necessity. Whether natural or man-made, disasters can strike suddenly, leaving little time to react. Being equipped with the right knowledge and tools can make all the difference.\n\nThis guide provides a detailed, topic-wise breakdown of disaster safety strategies to help individuals, families, communities, and institutions stay resilient in the face of calamity.\n\n'),
                TextSpan(text: '1. Understanding Disasters\n', style: bold),
                TextSpan(text: '🔍 Types of Disasters\nNatural Disasters:\n\nEarthquakes\nFloods\nCyclones and Hurricanes\nLandslides\nDroughts\nTsunamis\nWildfires\nVolcanic Eruptions\n\nMan-Made Disasters:\n\nIndustrial Accidents\nChemical Spills\nNuclear Accidents\nTransportation Accidents\nTerrorist Attacks\nCyber Attacks\n\n'),
                TextSpan(text: '🌍 Causes and Effects\n', style: bold),
                TextSpan(text: 'Natural disasters often result from geological, meteorological, or environmental phenomena.\n\nMan-made disasters arise due to human negligence, conflict, or technological failures.\n\nEffects include loss of life, economic damage, displacement, trauma, and long-term societal disruption.\n\n'),
                TextSpan(text: '2. Disaster Preparedness\n', style: bold),
                TextSpan(text: 'Preparedness is the first step toward reducing vulnerability. A well-thought-out plan can save lives.\n\n'),
                TextSpan(text: '🏠 Home and Family Preparedness\n', style: bold),
                TextSpan(text: 'Create a Family Emergency Plan: Define meeting points, emergency contacts, and evacuation routes.\n\nAssemble an Emergency Kit: Include water, non-perishable food, flashlight, batteries, first-aid kit, important documents, radio, multi-tool, medications, and cash.\n\nPractice Drills Regularly: Earthquake and fire drills can build muscle memory for real scenarios.\n\nSecure Your Home: Anchor heavy furniture, retrofit structures, and install fire and smoke alarms.\n\n'),
                TextSpan(text: '🏫 School and Workplace Plans\n', style: bold),
                TextSpan(text: 'Establish evacuation maps and designate safety coordinators.\n\nConduct regular drills and first-aid training sessions.\n\nUse public address systems for real-time communication.\n\n'),
                TextSpan(text: '3. Technology and Disaster Safety\n', style: bold),
                TextSpan(text: 'Modern technology offers real-time alerts, early warning systems, and communication during chaos.\n\n'),
                TextSpan(text: '📲 Mobile Apps and Alerts\n', style: bold),
                TextSpan(text: 'Government emergency apps (e.g., NDMA app in India, FEMA in the US)\n\nGoogle SOS alerts\n\nSocial media crisis response tools\n\n'),
                TextSpan(text: '🌐 Smart Systems\n', style: bold),
                TextSpan(text: 'IoT-based disaster monitoring (flood sensors, fire detection)\n\nSatellite imagery and drones for search and rescue\n\nAI-powered hazard prediction and damage assessment\n\n'),
                TextSpan(text: '💾 Data Backups\n', style: bold),
                TextSpan(text: 'Digitize and back up critical documents to cloud storage.\n\nMaintain encrypted backups of health, ID, and legal records.\n\n'),
                TextSpan(text: '4. During a Disaster: Immediate Response\n', style: bold),
                TextSpan(text: '🧠 Stay Calm & Assess\n', style: bold),
                TextSpan(text: 'Check surroundings for hazards.\n\nAdminister first-aid if needed.\n\nTurn off gas, electricity, and water if safe to do so.\n\n'),
                TextSpan(text: '🧍‍♂ Shelter or Evacuate?\n', style: bold),
                TextSpan(text: 'Earthquake: Drop, cover, and hold on. Stay indoors until shaking stops.\n\nFlood: Move to higher ground. Avoid walking or driving through floodwaters.\n\nFire: Evacuate immediately. Cover nose with cloth; stay low to avoid smoke.\n\nCyclone/Hurricane: Stay indoors, away from windows. Evacuate only if instructed.\n\n'),
                TextSpan(text: '🆘 Communication\n', style: bold),
                TextSpan(text: 'Use SMS or messaging apps to conserve bandwidth.\n\nTune into emergency broadcasts on radio.\n\nNotify local authorities or emergency contacts of your status.\n\n'),
                TextSpan(text: '5. After a Disaster: Recovery and Rehabilitation\n', style: bold),
                TextSpan(text: 'Recovery is a long-term effort, but a structured approach accelerates healing and rebuilding.\n\n'),
                TextSpan(text: '🛠 Physical Recovery\n', style: bold),
                TextSpan(text: 'Check for structural damage before re-entering buildings.\n\nUse protective gear while cleaning debris.\n\nAvoid drinking tap water until authorities declare it safe.\n\n'),
                TextSpan(text: '💰 Financial Recovery\n', style: bold),
                TextSpan(text: 'Contact insurance companies to report damages.\n\nApply for government aid or relief schemes.\n\nKeep receipts and documentation for claims.\n\n'),
                TextSpan(text: '💬 Mental Health Support\n', style: bold),
                TextSpan(text: 'Post-traumatic stress is common after disasters.\n\nProvide counseling, community healing sessions, and peer support.\n\nEncourage open discussions, especially among children and the elderly.\n\n'),
                TextSpan(text: '6. Community Involvement and Volunteerism\n', style: bold),
                TextSpan(text: '🤝 Community Preparedness\n', style: bold),
                TextSpan(text: 'Form local disaster response teams (CERTs).\n\nTrain volunteers in first-aid, firefighting, and evacuation protocols.\n\nEngage schools, colleges, and businesses in safety drills.\n\n'),
                TextSpan(text: '🧑‍🔧 Roles of Local Authorities\n', style: bold),
                TextSpan(text: 'Develop city-wide early warning systems.\n\nConduct risk assessments and vulnerability mapping.\n\nInvest in resilient infrastructure (e.g., elevated roads, storm drains, green spaces).\n\n'),
                TextSpan(text: '7. Building a Culture of Resilience\n', style: bold),
                TextSpan(text: 'Disaster safety isn’t just about one-time readiness—it’s about fostering a resilient mindset.\n\n'),
                TextSpan(text: '📚 Education and Awareness\n', style: bold),
                TextSpan(text: 'Integrate disaster management into school curricula.\n\nHost awareness camps, competitions, and exhibitions.\n\nCelebrate National Disaster Reduction Day (October 13 globally).\n\n'),
                TextSpan(text: '🏗 Sustainable Development\n', style: bold),
                TextSpan(text: 'Avoid construction in hazard-prone zones.\n\nPromote eco-friendly architecture and climate-adaptive designs.\n\nEncourage local innovations (like bamboo reinforcements, rainwater harvesting).\n\n'),
                TextSpan(text: '8. Global and National Disaster Management Frameworks\n', style: bold),
                TextSpan(text: '🌐 International Initiatives\n', style: bold),
                TextSpan(text: 'Sendai Framework for Disaster Risk Reduction (2015–2030)\n\nUNISDR, Red Cross, World Bank Disaster Risk Initiatives\n\n'),
                TextSpan(text: '🇮🇳 India’s Disaster Management Structure\n', style: bold),
                TextSpan(text: 'NDMA (National Disaster Management Authority)\n\nNDRF (National Disaster Response Force)\n\nState Disaster Management Authorities (SDMAs)\n\nDisaster Management Acts and Local Disaster Management Plans\n\n'),
                TextSpan(text: 'Conclusion: Safety is a Shared Responsibility\n', style: bold),
                TextSpan(text: 'Disasters will continue to be part of our reality—but our vulnerability doesn’t have to be. With a collective effort grounded in awareness, preparation, and technology, we can minimize risk, protect lives, and build a future that\'s not only safe, but resilient.\n\nWhether you\'re a student, parent, community leader, or developer building a smart disaster detection system—your actions today shape your safety tomorrow.\n\nStay alert. Stay prepared. Stay strong.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 