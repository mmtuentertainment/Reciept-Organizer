import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Optimize for production deployment
  output: 'standalone',
  
  // Disable source maps in production
  productionBrowserSourceMaps: false,
  
  // Remove console logs in production
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
  
  // Optimize package imports
  experimental: {
    optimizePackageImports: [
      '@upstash/ratelimit',
      '@upstash/redis',
      'jose',
      'zod',
    ],
  },
};

export default nextConfig;