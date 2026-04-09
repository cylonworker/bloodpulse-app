# BloodPulse Flutter App - Deployment Configuration

## Updated: 2026-03-30

### Production Configuration

The Flutter app has been configured to work with the production backend:

#### Supabase Configuration
- **Project ID**: `lnafpawzcgsiiffupzvr`
- **URL**: `https://lnafpawzcgsiiffupzvr.supabase.co`
- **Auth**: Supabase Auth with Row Level Security (RLS)
- **Database**: PostgreSQL with migrations applied

#### Backend API
- **URL**: `https://backend-theta-pied.vercel.app`
- **Platform**: Vercel (Node.js 24.x)
- **Alternative**: `https://bloodpulse-backend.vercel.app`

### Database Schema
The following tables are available in Supabase:
- `user_profiles` - User account information
- `blood_pressure_readings` - BP measurements with timestamps
- `user_settings` - User preferences (thresholds, notifications, theme)

### Files Updated
1. **lib/core/constants/app_constants.dart**
   - Added production Supabase URL and anon key
   - Added API base URL for backend

### How the App Works
1. **Authentication**: Uses Supabase Auth directly via `supabase_flutter`
2. **Data Storage**: Direct Supabase database access with RLS policies
3. **API Layer**: Optional REST API at `/api/*` endpoints (also available)

### Testing Connection
After building the app:
1. Users can sign up/sign in via Supabase Auth
2. Blood pressure readings are stored directly in Supabase
3. Settings are synced via the `user_settings` table

### Build Commands
```bash
cd /shared/build/artifacts/bloodpulse
flutter pub get
flutter build apk --release        # Android
flutter build ios --release        # iOS (requires macOS)
```

### Environment Variables
The app uses compile-time constants (no .env files needed):
- `AppConstants.supabaseUrl` - Supabase project URL
- `AppConstants.supabaseAnonKey` - Public anon key (safe to embed)
- `AppConstants.apiBaseUrl` - Optional REST API backend