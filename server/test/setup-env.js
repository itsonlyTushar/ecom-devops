process.env.BASE_API_URL = process.env.BASE_API_URL || 'api';
process.env.CLIENT_URL = process.env.CLIENT_URL || 'http://localhost:8080';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test_jwt_secret';
process.env.GOOGLE_CALLBACK_URL =
  process.env.GOOGLE_CALLBACK_URL ||
  'http://localhost:3000/api/auth/google/callback';
process.env.FACEBOOK_CALLBACK_URL =
  process.env.FACEBOOK_CALLBACK_URL ||
  'http://localhost:3000/api/auth/facebook/callback';
