/**
 * Password validation utilities
 * Requirements:
 * - At least 8 characters long
 * - At least 1 uppercase letter
 * - At least 1 lowercase letter
 * - At least 1 number
 * - At least 1 special character
 */

export interface PasswordValidationResult {
  isValid: boolean;
  errors: string[];
}

export interface PasswordStrength {
  score: number; // 0-4
  label: 'weak' | 'fair' | 'good' | 'strong' | 'very-strong';
  percentage: number;
}

export const PASSWORD_REQUIREMENTS = {
  minLength: 8,
  requireUppercase: true,
  requireLowercase: true,
  requireNumber: true,
  requireSpecial: true,
} as const;

export function validatePassword(password: string): PasswordValidationResult {
  const errors: string[] = [];

  if (!password || password.length === 0) {
    return {
      isValid: false,
      errors: ['Password is required'],
    };
  }

  // Check minimum length
  if (password.length < PASSWORD_REQUIREMENTS.minLength) {
    errors.push(`Password must be at least ${PASSWORD_REQUIREMENTS.minLength} characters long`);
  }

  // Check for uppercase letter
  if (PASSWORD_REQUIREMENTS.requireUppercase && !/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }

  // Check for lowercase letter
  if (PASSWORD_REQUIREMENTS.requireLowercase && !/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }

  // Check for number
  if (PASSWORD_REQUIREMENTS.requireNumber && !/\d/.test(password)) {
    errors.push('Password must contain at least one number');
  }

  // Check for special character
  if (PASSWORD_REQUIREMENTS.requireSpecial && !/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    errors.push('Password must contain at least one special character');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

export function getPasswordStrength(password: string): PasswordStrength {
  if (!password) {
    return {
      score: 0,
      label: 'weak',
      percentage: 0,
    };
  }

  let score = 0;

  // Length scoring
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (password.length >= 16) score++;

  // Complexity scoring
  if (/[a-z]/.test(password)) score++;
  if (/[A-Z]/.test(password)) score++;
  if (/\d/.test(password)) score++;
  if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) score++;

  // Additional patterns
  if (/[a-z].*[A-Z]|[A-Z].*[a-z]/.test(password)) score++; // Mixed case
  if (/\d.*[!@#$%^&*]|[!@#$%^&*].*\d/.test(password)) score++; // Numbers and special chars

  // Normalize score to 0-4 range
  const normalizedScore = Math.min(4, Math.floor(score / 2.25));

  const labels: Record<number, PasswordStrength['label']> = {
    0: 'weak',
    1: 'fair',
    2: 'good',
    3: 'strong',
    4: 'very-strong',
  };

  return {
    score: normalizedScore,
    label: labels[normalizedScore],
    percentage: (normalizedScore / 4) * 100,
  };
}

export function getPasswordRequirementsList(): string[] {
  return [
    `At least ${PASSWORD_REQUIREMENTS.minLength} characters`,
    'One uppercase letter',
    'One lowercase letter',
    'One number',
    'One special character (!@#$%^&*()_+-=[]{};\':"|,.<>/?)',
  ];
}