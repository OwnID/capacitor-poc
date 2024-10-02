/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    addGigyaSdkScript('4_OaQZgFXxqEu3Qim6gQJJ1w');

    window.ownid('start', {
        ...getProviders(),
    });
}

function addGigyaSdkScript(apikey) {
    const script = document.createElement('script');
    script.src = `https://cdns.gigya.com/js/gigya.js?apikey=${apikey}`;
    window.document.head.append(script);
}

function getProviders() {
    const providers = {
        account: {
            register: async (account) => {
                const regData = {
                    loginId: account.loginId,
                    password: window.ownid('generateOwnIDPassword', 12),
                    firstName: account.profile.firstName,
                    data: account.ownIdData,
                };
                try {
                    await registerStreamline(regData);

                    return {status: 'logged-in'};
                } catch (error) {
                    return {status: 'fail', reason: error};
                }
            },
        },
        auth: {
            password: {
                authenticate: async (params) => {
                    try {
                        await gigyaLogin({email: params.loginId, password: params.password});

                        return {status: 'logged-in'};
                    } catch {
                        return {status: 'fail', reason: 'Please enter a valid password'};
                    }
                },
            },
        },
    };
    const events = {
        onAccountNotFound: () => ({action: 'ui.register'}),
    };

    return {events, providers};
}

function registerStreamline({
    firstName,
    password,
    data: ownidData,
    loginId,
}) {
    return new Promise((resolve, reject) => {
        window.gigya.accounts.initRegistration({
            callback: (response) => {
                // @ts-ignore
                window.gigya.accounts.register({
                    regToken: response.regToken,
                    email: loginId,
                    password,
                    profile: {
                        firstName,
                    },
                    data: { ownId: ownidData },
                    finalizeRegistration: true,
                    callback: async (data) => {
                        if (data.status === 'FAIL') {
                            reject(data.errorDetails);
                            return;
                        }

                        resolve(data);
                    },
                });
            },
        });
    });
}

function gigyaLogin({ email, password }){
    return new Promise((resolve, reject) => {
        window.gigya.accounts.login({
            loginID: email,
            password,
            callback:  (data) => {
                if (data.status === 'FAIL') {
                    reject(data.errorDetails);
                    return;
                }

                resolve(data);
            },
        });
    });
}