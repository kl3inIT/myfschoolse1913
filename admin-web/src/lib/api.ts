const SESSION_STORAGE_KEY = 'myfschool_admin_session'

export type UserRole = 'PARENT' | 'STUDENT' | 'TEACHER' | 'ADMIN'

export type AuthUser = {
  id: string
  phoneNumber: string
  fullName: string
  role: UserRole
}

export type AuthSession = {
  accessToken: string
  refreshToken: string
  tokenType: 'Bearer'
  expiresInSeconds: number
  user: AuthUser
}

type ApiError = {
  message?: string
}

export function getStoredSession(): AuthSession | null {
  const raw = localStorage.getItem(SESSION_STORAGE_KEY)
  if (!raw) {
    return null
  }

  try {
    return JSON.parse(raw) as AuthSession
  } catch {
    localStorage.removeItem(SESSION_STORAGE_KEY)
    return null
  }
}

export function storeSession(session: AuthSession) {
  localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session))
}

export function clearSession() {
  localStorage.removeItem(SESSION_STORAGE_KEY)
}

export async function login(phoneNumber: string, password: string) {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ phoneNumber, password }),
  })

  return parseResponse<AuthSession>(response)
}

export async function authorizedJson<TResponse>(
  path: string,
  init: RequestInit = {},
) {
  const session = getStoredSession()
  if (!session) {
    throw new Error('Bạn cần đăng nhập quản trị')
  }

  const response = await fetch(path, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `${session.tokenType} ${session.accessToken}`,
      ...init.headers,
    },
  })

  if (response.status === 401 || response.status === 403) {
    clearSession()
    if (window.location.pathname !== '/login') {
      window.location.assign('/login')
    }
  }

  return parseResponse<TResponse>(response)
}

export async function authorizedForm<TResponse>(
  path: string,
  formData: FormData,
) {
  const session = getStoredSession()
  if (!session) {
    throw new Error('Bạn cần đăng nhập quản trị')
  }

  // No Content-Type header: the browser sets multipart/form-data with the
  // boundary itself.
  const response = await fetch(path, {
    method: 'POST',
    headers: {
      Authorization: `${session.tokenType} ${session.accessToken}`,
    },
    body: formData,
  })

  if (response.status === 401 || response.status === 403) {
    clearSession()
    if (window.location.pathname !== '/login') {
      window.location.assign('/login')
    }
  }

  return parseResponse<TResponse>(response)
}

async function parseResponse<T>(response: Response) {
  if (response.status === 204) {
    return undefined as T
  }

  const data = (await response.json().catch(() => null)) as ApiError | T | null
  if (!response.ok) {
    throw new Error(
      isApiError(data) && data.message
        ? data.message
        : 'Yêu cầu không thành công',
    )
  }

  return data as T
}

function isApiError(value: unknown): value is ApiError {
  return (
    typeof value === 'object' &&
    value !== null &&
    'message' in value &&
    typeof value.message === 'string'
  )
}
