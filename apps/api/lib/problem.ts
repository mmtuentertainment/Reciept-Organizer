/**
 * RFC9457 Problem Details for HTTP APIs
 * https://www.rfc-editor.org/rfc/rfc9457.html
 */

export interface Problem {
  /**
   * A URI reference that identifies the problem type.
   * When dereferenced, it should provide human-readable documentation.
   * Default: "about:blank"
   */
  type?: string;

  /**
   * A short, human-readable summary of the problem type.
   * Should not change from occurrence to occurrence.
   */
  title: string;

  /**
   * The HTTP status code for this occurrence of the problem.
   */
  status?: number;

  /**
   * A human-readable explanation specific to this occurrence of the problem.
   */
  detail?: string;

  /**
   * A URI reference that identifies the specific occurrence of the problem.
   */
  instance?: string;

  /**
   * Additional members can be added for problem-specific information
   */
  [key: string]: unknown;
}

/**
 * Creates an RFC9457 Problem Details response
 * @param problem The problem details object
 * @param status HTTP status code (defaults to problem.status or 400)
 * @returns Response with application/problem+json content type
 */
export function problemJSON(problem: Problem, status?: number): Response {
  const statusCode = status ?? problem.status ?? 400;

  const body: Problem = {
    type: problem.type ?? "about:blank",
    title: problem.title,
    status: statusCode,
    ...(problem.detail && { detail: problem.detail }),
    ...(problem.instance && { instance: problem.instance }),
  };

  // Add any additional custom properties
  Object.keys(problem).forEach(key => {
    if (!['type', 'title', 'status', 'detail', 'instance'].includes(key)) {
      body[key] = problem[key];
    }
  });

  return new Response(JSON.stringify(body), {
    status: statusCode,
    headers: {
      "Content-Type": "application/problem+json",
      "Cache-Control": "no-cache",
    },
  });
}

/**
 * Common problem types for the Receipt Organizer API
 */
export const ProblemTypes = {
  BAD_REQUEST: "https://example.com/problems/bad-request",
  UNAUTHORIZED: "https://example.com/problems/unauthorized",
  NOT_FOUND: "https://example.com/problems/not-found",
  RATE_LIMIT: "https://example.com/problems/rate-limit",
  IDEMPOTENCY_REQUIRED: "https://example.com/problems/idempotency-required",
  INVALID_JSON: "https://example.com/problems/invalid-json",
  INVALID_INPUT: "https://example.com/problems/invalid-input",
  UNSUPPORTED_MEDIA_TYPE: "https://example.com/problems/unsupported-media-type",
} as const;