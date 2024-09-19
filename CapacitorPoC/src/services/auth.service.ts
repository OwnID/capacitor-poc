import request from './request.service';

const AUTH_CUSTOM_LABEL = 'ownidCustomAuth';
const apiUrl = 'https://node-mongo.custom.demo.dev.ownid.com/api';

export interface ICustomAuthData {
  token: string;
  exp?: number;
}

export interface IUserProfile {
  name: string;
  email: string;
}

class Auth {
  authData: ICustomAuthData | null = null;
  profile: IUserProfile | null = null;

  constructor() {
    const persistedAuthStr = window.localStorage.getItem(AUTH_CUSTOM_LABEL);

    if (persistedAuthStr) {
      this.setAuth(JSON.parse(persistedAuthStr), false);
    }
  }

  isLoggedIn() {
    return this.authData?.exp! >= Date.now();
  }

  async logout() {
    window.localStorage.removeItem(AUTH_CUSTOM_LABEL);
    this.authData = null;
  }

  async getProfile(): Promise<any> {
    const profile = await this.getProfileCall();

    this.profile = { name: profile.name, email: profile.email };
    return this.profile;
  }

  async login(formData: any): Promise<any> {
    try {
      const authData = await this.loginCall(formData);
      this.setAuth(authData);
      return { error: null };
    } catch (e: any) {
      const error = e.errors ? Object.entries(e.errors).map((entries) => entries.join(' ')).join(', ') : (e.message || e.toString());
      return { error };
    }
  }

  async register(formData: any) {
    try {
      const authData = await this.registerCall({ ...formData });
      this.setAuth(authData);
      return { error: null };
    } catch (e: any) {
      const error = e.errors ? Object.entries(e.errors).map((entries) => entries.join(' ')).join(', ') : (e.message || e.toString());
      return { error };
    }
  }

  async onLogin({ token }: any) {
    this.setAuth({ token });
  }

  setAuth(authData: ICustomAuthData, persist = true): void {
    if (!authData) return;

    const { exp } = this.parseJwt(authData.token);

    this.authData = { ...authData, exp: Number(exp + '000') };

    if (persist) {
      window.localStorage.setItem(AUTH_CUSTOM_LABEL, JSON.stringify(authData));
    }
  }

  private parseJwt(token: string): { exp: string } {
    try {
      return JSON.parse(atob(token.split('.')[1]));
    } catch {
      return { exp: '0' };
    }
  }


  async loginCall({ email, password }: any): Promise<ICustomAuthData> {
    return await request.post(`${apiUrl}/auth/login`, {
      email,
      password,
    });
  }

  async registerCall({ email, password, name, ownIdData }: any): Promise<ICustomAuthData> {
    return await request.post(`${apiUrl}/auth/register`, {
      email,
      password,
      name,
      ownIdData,
    });
  }

  getProfileCall(): Promise<IUserProfile> {
    return request.get(`${apiUrl}/auth/profile`, {
      headers: {
        Authorization: `Bearer ${this.authData?.token}`,
      },
      withCredentials: true,
    });
  }
}

export default new Auth();
