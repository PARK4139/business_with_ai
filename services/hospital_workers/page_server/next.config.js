/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  async rewrites() {
    return [
      {
        source: '/heal_base_hospital_worker/v1/page/:path*',
        destination: '/:path*',
      },
    ];
  },
  env: {
    API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:8002',
  },
};

module.exports = nextConfig;
