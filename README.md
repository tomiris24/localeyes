# LocalEyes

Choose the right local guide, not just any guide.

LocalEyes is a marketplace that connects travellers with independent local
guides in Almaty. This repository is **Milestone 1** of the capstone project:
the MVP user interface, built in Flutter. Milestone 2 added the backend: a
Node + Express REST API over MongoDB in `server/`, which is where every tour,
local, spot and catalog row now comes from.

Author: Tomiris Suleimenova, Narxoz University.

---

## The problem

* **Travellers** can find guides easily, but they cannot *choose* one. Profiles
  all look the same and never say the things that actually matter: difficulty,
  real group size, walking time, how good the guide's English really is.
  Travellers spend a median of 2 hours picking a guide, and 27% spend 5–24 hours.
* **Independent guides** have no steady flow of clients. 8 out of 8 independent
  guides lose a median of 4 days a month, which is about **$280 of lost income**,
  and spend up to 24 hours a week looking for clients on Instagram and TikTok.

So the app is built around one job: help the traveller **choose**, and help the
guide **fill empty dates with clients they can trust**.

## Who it is for

* **Travellers** — independent travellers aged 23–35 who search on Instagram,
  TikTok and Google Maps, read reviews, and still cannot tell which guide fits
  their interests, pace, language and group size.
* **Guides** — independent guides in Almaty and Worldwide, 23–40 years old, 1–7 years of experience, speaking RU / EN / KZ.

---

## Screens

| Discovery feed | Tour detail | Tour detail on a tablet |
| --- | --- | --- |
| ![Feed](docs/screenshots/01-feed.png) | ![Detail](docs/screenshots/02-detail.png) | ![Tablet](docs/screenshots/03-detail-tablet.png) |

1. **Explore** — search field, category chips, the matching card, and a grid of
   tour cards.
2. **Tour detail** — cover photo with a bookmark badge, title, star rating,
   price, category badges, three tabs (About / Route / Reviews), honest tour
   facts, the guide, dates, group size, and a sticky "Add to cart" bar.
3. **Saved** — everything the bookmark badge collected.
4. **Profile** — the traveller's own profile, interests and safety settings.
5. **Cart** — what was added from the detail screen, with the booking request.
6. **Sign in / Create account** — the first screen of the app when nobody is
   signed in, and where "Log out" on the profile leads back to. One form with
   two modes, full validation, a terms checkbox and a role dropdown.
7. **Locals** — the people who live here, with availability filters, their
   profiles and a meetup request form.
8. **Catalog** — the same items as a lazy list or a 2-column grid, with
   pull-to-refresh, swipe-to-delete, undo and an empty state (reached from the
   grid button in the Explore app bar).
9. **Cart** — what the badge counts: every added tour, a delete button on each
   row, the total, and "Clear All".

## Interactive features (StatefulWidget + setState)

| Feature | Where |
| --- | --- |
| Bookmark badge with a press animation | `lib/widgets/bookmark_badge.dart` |
| Category filter chips | `lib/screens/discovery_screen.dart` |
| Live search field | `lib/screens/discovery_screen.dart` |
| Matching quiz (3 questions) that filters the feed | `lib/widgets/match_sheet.dart` |
| About / Route / Reviews tab toggle | `lib/screens/tour_detail_screen.dart` |
| Group size stepper that recalculates the total price | `lib/screens/tour_detail_screen.dart` |
| Date picker chips | `lib/screens/tour_detail_screen.dart` |
| Bottom navigation with the centre action | `lib/widgets/app_bottom_nav.dart` |
| Sign in / sign up switch, live validation, password visibility, terms checkbox, role dropdown | `lib/screens/auth_screen.dart` |
| Catalog list / grid toggle, pull-to-refresh, swipe-to-delete with undo | `lib/screens/catalog_screen.dart` |
| Global cart: add-to-cart toggles, live app-bar badge, total, Clear All | `lib/state/cart_provider.dart` |

Saved tours and saved locals live in one `ChangeNotifier`
(`lib/state/app_state.dart`) shared through an `InheritedNotifier`, so the
bookmark reacts the same way on every screen. The cart is a second
`ChangeNotifier` (`lib/state/cart_provider.dart`), wired with the `provider`
package — see [The global cart](#the-global-cart-changenotifier--provider).
BLoC replaces both in Milestone 3.

## Navigation

The app has one root screen with a `BottomNavigationBar` and pushes a detail
screen on top of it.

### Root screen — four tabs

`lib/screens/home_shell.dart` holds the selected tab index in a
`StatefulWidget` and swaps the body with `setState`:

| Tab | Screen | What it shows |
| --- | --- | --- |
| 1 · Explore (feed) | `discovery_screen.dart` | 7 tours as cards with a photo, title, category and price per person |
| 2 · Saved (favourites) | `saved_screen.dart` | the tours the bookmark badge collected |
| 3 · Profile | `profile_screen.dart` | the traveller's profile, interests and settings |
| 4 · Locals | `locals_screen.dart` | the people who live here and are up for meeting |

The four tabs sit inside an `IndexedStack`, so they are built once and kept
alive. Switching tabs — or coming back from the detail screen — does **not**
rebuild them: the search text, the category chip and the scroll position are
exactly where they were left.

### Pushing the detail screen with the object

Tapping a card calls `Navigator.push` and hands the **whole `Tour` object** to
the next screen as a constructor argument, so the detail screen already has the
title, summary, photo, price and category and never has to look them up again:

```dart
// lib/screens/discovery_screen.dart
void _openTour(Tour tour) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => TourDetailScreen(tour: tour),
    ),
  );
}
```

```dart
// lib/screens/tour_detail_screen.dart
class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.tour});

  final Tour tour; // the complete object that was passed in
```

The Saved tab pushes the same screen the same way, so a tour opens identically
from either tab.

### Two ways back, both `Navigator.pop`

1. **The AppBar arrow.** `TourDetailScreen` has an `AppBar` with the tour title.
   Because the screen was pushed onto the navigator, Flutter adds the back arrow
   automatically and it calls `Navigator.pop` for us.
2. **The in-body button.** At the bottom of the detail screen there is a
   "Back to tours" button:

```dart
OutlinedButton.icon(
  onPressed: () => Navigator.of(context).pop(),
  icon: const Icon(Icons.arrow_back_rounded, size: 19),
  label: const Text('Back to tours'),
)
```

Both return to the tab that opened the screen without restarting it. Saved
tours and the cart live in the shared `AppState`, and the tabs survive in the
`IndexedStack`, so anything bookmarked or added to the cart on the detail screen
is already visible when the screen pops.

`test/layout_overflow_test.dart` checks all of this: that a tap pushes
`TourDetailScreen` carrying the right tour data, that both back buttons pop it,
and that a search typed before opening a tour is still in the field afterwards.

## Dynamic lists, grids and touch gestures

The catalog screen (`lib/screens/catalog_screen.dart`) shows the same data two
ways and answers to three gestures.

| Piece | How it is built |
| --- | --- |
| **List feed** | `ListView.separated` — avatar icon, title, category tag, star rating and price per row, with a 1 px `Divider` from `separatorBuilder` |
| **Grid catalog** | `GridView.builder`, `crossAxisCount: 2`, `childAspectRatio: 0.72` |
| **Toggle** | an `IconButton` in the `AppBar` that flips `CatalogView` with `setState` |
| **Pull-to-refresh** | `RefreshIndicator` → `await Future.delayed(1500 ms)` → `_items.insert(0, …)` |
| **Swipe-to-delete** | `Dismissible` with `key: ValueKey(item.id)`, `endToStart`, red background with `Icons.delete` — in **both** the list and the grid |
| **Undo** | a floating `SnackBar` whose action does `_items.insert(index, item)`, so the item lands back on its old row, not on top |
| **Empty state** | `EmptyState` with "Catalog is Empty" and a "Reset Catalog" button that re-seeds the data |

Both builders are lazy on purpose. A `Column` inside a `SingleChildScrollView`
builds every row up front and keeps them all in memory; `ListView.separated`
and `GridView.builder` only build what is on screen plus a small cache, which
is what keeps a long catalog cheap on a phone.

The `ValueKey` is built from the item **id**, never from the index: with an
index key Flutter would animate away the wrong row once the list shifted after
a removal.

Both lists use `AlwaysScrollableScrollPhysics` and the empty state is itself a
`ListView`, so pull-to-refresh still works when the catalog is short or empty.

`test/catalog_test.dart` covers all of it: the divider and the grid delegate,
the 1500 ms refresh landing at index 0, a swipe in each view, the undo coming
back at the original position, and the empty state with its reset.

## The global cart (ChangeNotifier + Provider)

Two screens, one cart. `CartProvider` (`lib/state/cart_provider.dart`) is a
`ChangeNotifier` that owns the whole truth about what has been added; no screen
keeps a copy, so there is nothing to keep in sync by hand.

```dart
// lib/main.dart — above MaterialApp, so every pushed route sees the same cart
return ChangeNotifierProvider<CartProvider>(
  create: (BuildContext context) => CartProvider(),
  child: AppScope(
    notifier: _appState,
    child: MaterialApp(home: const HomeShell()),
  ),
);
```

| Piece | How it is built |
| --- | --- |
| **The cart itself** | `Map<String, CartItem>` keyed by tour id — a tour cannot be added twice, and a `Map` keeps insertion order, so the cart lists tours in the order they were added |
| **Screen 1 · the feed** | every card carries an Add to cart / In cart toggle; the button's state is read from the provider, never from a local `bool` |
| **Live badge** | `CartBadgeButton` calls `context.watch<CartProvider>()`, so only the button rebuilds when the count changes |
| **Screen 2 · the cart** | every added tour with its own delete button, the total in the booking bar, and "Clear All" with an UNDO SnackBar |
| **Total** | `CartProvider.total` folds price × travellers — the screen displays a number it never calculates |
| **Two ways in** | the toggle on a card adds one traveller on the first free date; the detail screen adds the same tour with a chosen date and group size, and the toggle then reads "In cart" |

Three different ways of reading the provider, each picked for a reason:

* `context.watch<CartProvider>()` — the cart screen and the badge depend on the
  whole object, so they subscribe to it.
* `context.select<CartProvider, bool>((c) => c.contains(tour.id))` — a card
  only cares whether **its** tour is in the cart, so it rebuilds when that one
  boolean flips and sits still when another card changes.
* `context.read<CartProvider>()` — inside button callbacks, where the object is
  needed to call a method on and a subscription would be pure waste.

Because every screen reads the same object, deleting a tour on the cart screen
has already flipped its card back to "Add to cart" and dropped the badge by one
before the back arrow is pressed. `test/cart_provider_test.dart` proves exactly
that: it adds two tours from the feed, opens the cart, deletes one, walks back,
and checks the badge and the button states — and does the same round trip
through the detail screen.

The booking cart is the only state that moved: saved tours, saved locals and
meetup requests still live in `AppState` behind the `InheritedNotifier`.

## Layout and responsiveness

* `Stack` — cover photo, gradients, share button and the bookmark badge
  (`lib/widgets/cover_header.dart`), and the price badge on every card.
* `Row` + `Expanded` — title next to price, rating next to duration, and the
  sticky bar where the main button takes all the remaining width
  (`lib/widgets/booking_bar.dart`).
* `Wrap` — category badges, tour facts and interest tags move to the next line
  instead of overflowing.
* `LayoutBuilder` — the detail screen is one column below 840 px and two columns
  above it; the facts grid switches between two and three columns.
* The feed uses `SliverGridDelegateWithMaxCrossAxisExtent`, so it is one column
  on a phone and two or three on a tablet.

### Zero RenderFlex overflow

`test/layout_overflow_test.dart` opens the feed, the saved screen, the profile
and **every** tour detail screen (including all three tabs and the bottom of the
page) at six screen sizes, from 320×568 to 1280×800, and fails if Flutter
reports any overflow. `test/auth_form_test.dart` does the same for the
sign-up form at four sizes, with every field in its error state — the
tallest the form can get. `test/locals_layout_test.dart` covers the locals
screens, `test/catalog_test.dart` checks both catalog views at 320×568,
390×844 and 768×1024 including the grid after a scroll, and
`test/cart_provider_test.dart` does the same for the feed with a full cart.

```
flutter test
# 92 tests passed
flutter analyze
# No issues found
```

## The look

The app follows one design system, and it ships in both appearances: light by
default, dark when the phone is dark (`ThemeMode.system`).

| Token | Light | Dark |
| --- | --- | --- |
| `canvas` — the page | `#F8FAFC` | `#0B0B0F` |
| `surface` — cards and sheets | `#FFFFFF` | `#1F2937` |
| `surfaceHigh` — chips, inputs | `#F1F5F9` | `#2A3545` |
| `ink` / `inkMuted` — type | `#0F172A` / `#64748B` | `#F1F5F9` / `#94A3B8` |
| `brand` / `brandDeep` — the one accent | `#6366F1` / `#4F46E5` | `#8E97FF` / `#4F46E5` |
| `success` / `warning` / `error` | `#10B981` / `#F59E0B` / `#EF4444` | lightened for dark |

Both palettes live in `AppPalette` (`lib/core/app_theme.dart`) as a
`ThemeExtension`, and every widget reads them through `context.palette` — no
screen contains a hex code, which is what lets one theme switch repaint the
whole app.

* **Type** — Plus Jakarta Sans, shipped with the app as one variable file
  (`assets/fonts/`, OFL). H1 30 / H2 24 / H3 20 semibold, body 16 and 14 at
  150%, caption 12.
* **Shape and size** — cards 16, buttons and chips are capsules; buttons are
  48 / 44 / 36 tall, chips 32, search 48 (`AppSize`).
* **Photo headers** — Explore, Locals and Profile open on a photograph of
  Almaty with the screen's name on it (`lib/widgets/photo_header.dart`), and
  the feature card on the Locals tab works the same way. The scrim over a
  photo is a flat colour, never a gradient.
* **The bottom bar** — four tabs around the indigo circle that opens the "add
  something" sheet: become a local, places locals love, guide picks, catalog
  (`lib/widgets/app_bottom_nav.dart`).

## Design files

Figma-ready artboards live in `design/figma/` — a UI kit plus the three screens
as SVG. Drag them into Figma and they open as editable layers.
See `design/README.md`.

## Folder structure

```
lib/
├── core/          app_theme.dart — colours, spacing, text styles
├── models/        guide.dart, review.dart, tour.dart, local_person.dart,
│                  spot.dart, catalog_item.dart, cart_item.dart
├── data/          local_store.dart — SharedPreferences, opened in main()
│                  api_client.dart — JSON over HTTP, errors already in English
│                  localeyes_api.dart — every call to our own backend
│                  route_api.dart, store_api.dart — the two public APIs
├── state/         app_state.dart — saved tours and locals (AppScope)
│                  cart_provider.dart — the cart (ChangeNotifier + provider)
│                  data_store.dart — what the server answered, in memory
│                  settings_controller.dart — theme and name, from the phone
│                  notes_controller.dart — the notes list, JSON on the phone
├── screens/       home_shell, discovery, tour_detail, saved, cart, profile,
│                  auth_gate, auth, locals, local_profile, meetup_request, spots,
│                  become_local, catalog
└── widgets/       tour_card, cover_header, booking_bar, bookmark_badge,
                   tag_chip, rating_stars, fact_tile, guide_strip,
                   quantity_stepper, avatar_circle, section_header,
                   match_sheet, empty_state, local_card, hangout_row,
                   availability_pill, spot_card, catalog_list_tile,
                   catalog_grid_card, cart_badge_button, cart_toggle_button
```

```
server/
├── src/models/    tour.js, local_person.js, spot.js, catalog_item.js,
│                  taxonomy.js, meetup_request.js — the Mongoose schemas
├── src/routes/    tours.js, locals.js, spots.js, catalog.js, taxonomy.js
├── src/seed.js    loads seed/*.json into MongoDB
└── seed/          the demo data as JSON — the Milestone 1 Dart files,
                   exported once and now the source the database is loaded from
```

```
design/figma/      00-ui-kit, 01-explore, 02-tour-detail, 03-profile  (SVG)
docs/screenshots/  simulator screenshots used in this README
```

## Accounts

Nobody sees a tour before they have an account. `AuthGate` is the first thing
`main.dart` builds: it asks the server whether the token kept on the device is
still good (`GET /api/auth/me`) and then shows either the app or
`AuthScreen` — the sign-in form on a device that has had an account, the
sign-up form on a fresh install. "Log out" on the profile clears the token and
the same switch flips back, with no navigation of its own.

| Endpoint | What it does |
| --- | --- |
| `POST /api/auth/register` | one account per email — a taken one comes back as `409 email_taken` |
| `POST /api/auth/login` | the same answer for an unknown email and a wrong password, so the endpoint does not leak who is registered |
| `GET /api/auth/me` | is this token still good? |

Passwords are stored as a bcrypt hash and never leave the server; the app
keeps only the JWT, in `SharedPreferences`. When the server answers
`email_taken` the sign-up form switches itself to "Sign in" with the email
still in the field — there is nothing left to create.

## What the phone keeps (offline storage)

Three things live on the device itself, in `SharedPreferences`, and survive
the app being force-quit:

| Key | What it is |
| --- | --- |
| `app_theme_dark_mode` | the dark-mode switch — `bool`, absent means "follow the phone" |
| `user_display_name` | the name on the profile, read back as `Guest User` when nothing was saved |
| `trip_notes` | the whole notes list as one JSON string |

`main()` is `async`: it calls `WidgetsFlutterBinding.ensureInitialized()` and
`await LocalStore.init()` **before** `runApp`, so the saved appearance is
known when the first frame is painted. Reading it after `runApp` would show
one light frame and then repaint dark — the flicker everybody notices on a
cold start. Because the store is already open, every later read is
synchronous and no screen needs a `FutureBuilder`.

Notes are a domain model with `toJson()` / `NoteItem.fromJson()`
(`lib/models/note_item.dart`). `NotesController` keeps them newest-first, and
after every add, toggle and delete it writes the whole list back with one
`jsonEncode` + `setString` — a handful of notes that are always read together
are cheaper, and atomic, as one value rather than a key per note. A
half-written or hand-edited file reads back as an empty list instead of
crashing the screen.

**Cold restart test.** Add two notes, turn dark mode on, swipe the app away in
the app switcher, open it again: the theme, the name and both notes are there
on the first frame.

**Why this is not a safe place for secrets.** `SharedPreferences` is a plain
`.plist` on iOS and an XML file on Android, inside the app sandbox but not
encrypted — anyone with a jailbroken or rooted device, or a file-system
backup, can read it. It is the right place for preferences and a cache, and
the wrong place for a password or a token. The session token sits there today
(`auth.token`); the iOS Keychain / Android Keystore, through
`flutter_secure_storage`, is where it belongs before this ships.

## The backend

`server/` is a small Node + Express API over MongoDB. Five collections —
tours, locals, spots, catalog, taxonomy — plus the meetup requests the form
sends.

| Endpoint | What it answers |
| --- | --- |
| `GET /api/tours?category=&q=` | the feed, filtered server-side |
| `GET /api/tours/:id` | one tour with its guide, route, facts and reviews |
| `GET /api/locals?availability=&area=&interest=` | the people who live here |
| `POST /api/locals/:id/meetups` | what the meetup form sends |
| `GET /api/spots` | the pins on the map |
| `GET /api/catalog`, `POST`, `POST /reset`, `DELETE /:id` | the catalog and its gestures |
| `GET /api/taxonomy` | categories, interests, areas, meeting places |

The guide rides inside the tour document: every screen that shows a tour also
shows its guide, so one read answers the whole detail screen.

On the app side the data arrives through `ApiClient` → `LocalEyesApi` →
`DataStore`. `StartupGate` makes that one request round at launch and shows a
spinner, or the error with a Retry button if the server is not up; after that
every screen reads the lists synchronously, the way it used to read the mock
files.

## Run it

```bash
# 1 — MongoDB on the default port
mongod --dbpath ~/mongodb-data/db

# 2 — the API, seeded once
cd server
npm install
cp .env.example .env
npm run seed
npm start          # http://localhost:3000

# 3 — the app
flutter pub get
flutter run
```

The iOS simulator reaches the laptop on `localhost`. An Android emulator or a
real phone needs the host spelled out:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Tested with Flutter 3.47.2 (Dart 3.13.2) on the iOS Simulator, Node 22 and
MongoDB 8.

Widget tests never touch the network: `test/fixtures/fake_server.dart` answers
the same endpoints from `server/seed/`, so the fixtures cannot drift away from
what the app really receives.

## Roadmap

* **Milestone 2** — REST API over MongoDB ✅, chat and real accounts next.
* **Milestone 3** — local database, BLoC architecture, AI matching.


