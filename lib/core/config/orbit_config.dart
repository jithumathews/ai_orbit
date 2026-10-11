// AI Orbit — Configuration & Environment Settings
// Sensitive keys never live here! Only public Supabase project URL and Anon key.

class OrbitConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ikkkfwoiivwhrvdszztr.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlra2tmd29paXZ3aHJ2ZHN6enRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE3MDA0OTgsImV4cCI6MjEwNzI3NjQ5OH0.p9V0IKZ4P8psXRYr7qN74n0ZLNgMJUAp2KMIPSedn4Y',
  );

  // Maximum characters per user message enforced client-side before gateway dispatch
  static const int maxMessageLength = 4000;

  // Maximum messages retrieved for context
  static const int maxHistoryMessages = 10;

  // Whether app is running with a live connected Supabase project
  static bool get isConfigured =>
      !supabaseUrl.contains('placeholder-project') &&
      !supabaseAnonKey.contains('dummy_anon_key');
}
