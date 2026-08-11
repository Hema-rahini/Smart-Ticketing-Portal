import axios from 'axios'

export async function getAuthToken(email: string, password = 'password123', baseUrl = 'http://localhost:8000'): Promise<string> {
  try {
    const res = await axios.post(`${baseUrl}/auth/login`, { email, password })
    return res.data.access_token || res.data.token || ''
  } catch (err) {
    return ''
  }
}
