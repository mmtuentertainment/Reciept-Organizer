export interface PasswordValidationResult {
  isValid: boolean;
  errors: string[];
  requirements: {
    minLength: boolean;
    hasUppercase: boolean;
    hasLowercase: boolean;
    hasNumber: boolean;
    hasSpecialChar: boolean;
  };
}

export function validatePassword(password: string): PasswordValidationResult {
  const requirements = {
    minLength: password.length >= 8,
    hasUppercase: /[A-Z]/.test(password),
    hasLowercase: /[a-z]/.test(password),
    hasNumber: /\d/.test(password),
    hasSpecialChar: /[!@#$%^&*(),.?":{}|<>]/.test(password),
  };

  const errors: string[] = [];
  if (!requirements.minLength) errors.push('Password must be at least 8 characters long');
  if (!requirements.hasUppercase) errors.push('Password must contain at least one uppercase letter');
  if (!requirements.hasLowercase) errors.push('Password must contain at least one lowercase letter');
  if (!requirements.hasNumber) errors.push('Password must contain at least one number');
  if (!requirements.hasSpecialChar) errors.push('Password must contain at least one special character');

  return {
    isValid: errors.length === 0,
    errors,
    requirements,
  };
}

export function getPasswordStrength(password: string): 'weak' | 'fair' | 'good' | 'strong' {
  const { requirements } = validatePassword(password);
  const score = Object.values(requirements).filter(Boolean).length;

  if (score < 3) return 'weak';
  if (score < 4) return 'fair';
  if (score < 5) return 'good';
  return 'strong';
}