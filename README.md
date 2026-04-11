# Trace

Trace is an AI-powered Organizational Memory Engine built natively in Flutter. The platform sits across disparate communication channels (Slack, Email, Meetings, GitHub) and reconstructs institutional knowledge into a unified, queryable vector space. 

Instead of searching keywords natively on a platform, Trace uses a vector database (`ChromaDB`) chained with Llama-3 to actively synthesize, trace, and cite executive decisions as they travel through your organization. 

---

## UI/UX

Trace relies on a glassmorphic logic suite tied intricately to responsive state boundaries `MediaQuery` to accommodate native deployment across Web, Tablet, and Mobile. 

### Core Views
* **Command Center**: The primary landing zone. Offers macro Organizational Health Scores, visual conflict severity radars, and recent team activity.
* **Investigation Dashboard**: An immersive AI-chat window capable of analyzing the organizational memory. Replaced standard layout vectors with a wide-angle dual split-pane view (rendering conversational context on the left, while real-time timeline scrubbing features map the decision on the right quadrant). Includes native edge-sidebar capabilities for recalling previous historical investigation prompts/sessions. 
* **Analytics/Temporal Explorer**: Drill comprehensively into contribution matrices (e.g. tracking what an employee discussed on March 15th directly based on parsed email integrations). 
* **Dynamic Integration Dashboard**: Safely write/store Slack Bot credentials, Discord mappings, and Organizational ID logic securely mapped to internal API backend environment parameters—preventing hard-coded configuration liabilities securely directly from the front-end. 

---

## System Architecture

The frontend strictly relies on native State Management boundaries (`ValueNotifier`, `IndexedStack`) instead of aggressive third-party implementations, resulting in lightning-fast native rendering natively avoiding API exhaustion via state-loss destruction variables. 

* **State**: Utilizes `IndexedStack` nested within the core Sidebar navigation component to prevent recursive DOM and widget regeneration, heavily preserving API quotas during cross-screen migration. 
* **Theming**: Employs an internal global `ValueNotifier<ThemeMode>` bound inside `runApp()` to dynamically switch context styling dynamically between the natively built solid dark-modes and high-luminance professional Light themes instantly without routing. 
* **Markdown Formatting**: Renders high-fidelity markdown tags directly via `flutter_markdown` mapping internal Llama-3 outputs directly to rich textual logic.

---

## Tech Stack
* **Framework**: Flutter (Dart) 
* **Networking**: Native HTTP mapped directly to a local Python FastAPI backend instance.
* **Component Tracking**: `timeline_tile` package enabling robust visual decision mapping sequentially. 
* **Persistence Layer**: Heavy localized persistence modeled through `shared_preferences` capable of routing entire cached thread states without needing repeated localized API fetch calls. 

---

## Quickstart Guide

### Prerequisites
1. You must have the [Trace Web API / Backend](https://github.com/path-to-trace-backend) natively compiled and actively running on your machine (Usually executed via `uvicorn main:app`).
2. Ensure you have the Flutter SDK configured. 

### Launch 

1. Install Dependencies: 
```bash
flutter pub get
```

2. Standard Execution (Chrome recommended for optimal desktop styling):
```bash
flutter run -d chrome
```

3. Open the **Settings Dashboard** (Left sidebar gear icon).
4. Update the **Organization ID** to map directly against your ChromaDB vectorized array namespace. 
5. Start investigating! 

---

*Built locally for high-performance context rendering natively isolated via edge infrastructure*
