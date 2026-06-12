# Truce App

Truce is a Flutter mobile app for comparing product prices across Egyptian online stores. It helps users search products, browse categories, compare store offers, view live market indicators, and jump directly to the seller with the best available price.

The app is integrated with the backend repository [`MahmoudMadihBedier/truce-APIs`](https://github.com/MahmoudMadihBedier/truce-APIs), which provides the product aggregation and market-rate API used by this Flutter client.

## Project Overview

Truce is positioned as Egypt's price aggregator. The mobile app focuses on the customer experience:

- Discover featured deals and product categories.
- Search products by name, category, brand, or store.
- Compare variants of the same product across supported stores.
- Highlight the lowest available price.
- View product availability, discounts, previous prices, and seller links.
- Show live market data such as USD/EGP and gold rates.
- Support guest browsing and authenticated accounts.
- Provide English and Arabic localization.
- Support light and dark themes.

## Backend Integration

The Flutter app uses a shared Dio API client configured with the deployed Truce API base URL:

```text
https://truce-ap-is-dw59.vercel.app
```

The integrated backend repo is:

```text
https://github.com/MahmoudMadihBedier/truce-APIs
```

Current app integrations include:

- `GET /api/all-products` for paginated product feeds.
- `GET /api/products` for filtered product search.
- `GET /api/rates` for USD/EGP and gold market rates.

The product API returns normalized product data used by the app, including product name, category, brand, image URL, store name, current price in EGP, previous price, discount offers, availability, location, product URL, and last updated time.

## Main Features

- Product feed with shimmer loading states.
- Search page with debounced queries, filters, pagination, and page indicators.
- Product details page with store-by-store price comparison.
- Best-price highlighting for grouped product variants.
- External seller links through `url_launcher`.
- Firebase Authentication with email/password, Google sign-in, phone verification, password reset, and guest login.
- Account page with preferences, theme switching, and localization settings.
- Market overview for currency and gold-rate tracking.
- Dependency injection through `get_it`.
- State management through `flutter_bloc`.

## Tech Stack

- Flutter and Dart
- Firebase Core and Firebase Auth
- Dio for API networking
- flutter_bloc for presentation state
- get_it for dependency injection
- shared_preferences for local settings
- flutter_dotenv and `--dart-define` for environment values
- cached_network_image, shimmer, animations, and flutter_animate for UI polish
- English and Arabic localization assets

## Project Structure

```text
lib/
  core/
    config/          Environment and API configuration
    di/              Dependency injection setup
    error/           Result and failure models
    localization/    App localization helpers
    network/         Shared API client
    services/        App services
    theme/           Light/dark themes and settings cubit
    widgets/         Shared UI widgets
  features/
    account/         Account and preferences UI
    auth/            Authentication domain, data, and presentation layers
    coupons/         Coupons UI
    home/            Splash, home, and navigation screens
    market/          Market-rate domain, data, and presentation layers
    products/        Product models, repositories, use cases, cubits, and pages
```

## Environment Variables

MetalPrice API support requires an API key. Pass it at run/build time:

```bash
flutter run --dart-define=METALPRICE_API_KEY=YOUR_KEY_HERE
```

You can also create a local `.env` file from the example file:

```bash
cp .env.example .env
```

Do not commit real secrets in `.env`.

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run --dart-define=METALPRICE_API_KEY=YOUR_KEY_HERE
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Related Repository

- Backend/API: [`MahmoudMadihBedier/truce-APIs`](https://github.com/MahmoudMadihBedier/truce-APIs)
