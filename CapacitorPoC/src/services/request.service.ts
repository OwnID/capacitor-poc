class RequestService {
  public async post(url: string, data = {}, options?: { headers: { [key: string]: string } }): Promise<any> {
    const response = await fetch(url, {
      method: 'POST',
      mode: 'cors',
      cache: 'no-cache',
      headers: {
        'Content-Type': 'application/json',
      },
      redirect: 'follow',
      referrerPolicy: 'no-referrer',

      body: JSON.stringify(data),
      ...options,
    });

    if (response.status === 200) {
      return response.json();
    }

    if (response.status === 204) {
      return response;
    }

    if (response.status >= 400) {
      throw await response.json();
    }

    throw response;
  }

  public async get(url: string, options?: { headers?: { [key: string]: string }, withCredentials?: boolean }): Promise<any | null> {
    const response = await fetch(url, {
      method: 'GET',
      mode: 'cors',
      cache: 'no-cache',
      redirect: 'follow',
      referrerPolicy: 'no-referrer',
      ...options,
    });

    if (response.status === 200 || response.status === 204) {
      return response.json();
    }

    if (response.status === 204) {
      return response;
    }

    if (response.status >= 400) {
      throw await response.json();
    }

    throw response;
  }
}

export default new RequestService();
