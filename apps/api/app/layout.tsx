import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Receipt Organizer API",
  description: "CSV validation API for QuickBooks and Xero",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
      </body>
    </html>
  );
}
