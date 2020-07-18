/* global APP */

import React from 'react';
import ReactDOM from 'react-dom';

import { getJitsiMeetTransport } from '../modules/transport';

import { App } from './features/app';
import { getLogger } from './features/base/logging/functions';
import { Platform } from './features/base/react';

const logger = getLogger('index.web');
const OS = Platform.OS;

declare var DeviceChecker: any;

/**
 * Renders the app when the DOM tree has been loaded.
 */


document.addEventListener('DOMContentLoaded', () => {

    const successCallback = () => {
        const now = window.performance.now();
        APP.connectionTimes['document.ready'] = now;
        logger.log('(TIME) document ready:\t', now);
        // Render the main/root Component.
        const spinnerElement = document.getElementById("main-spinner");
        if (spinnerElement){
            spinnerElement.parentNode.removeChild(spinnerElement);
        }
        ReactDOM.render(< App / >, document.getElementById('react'));
    };

    if (DeviceChecker.isDesktop()){
        successCallback();
        return;
    }

    const urlParts  = window.location.pathname.split("/");
    let conferenceId = urlParts.length ===  3 ? urlParts[2] : "0";
    let urlToRedirect = "/iam/c/" + conferenceId;
    const apiToCall = window.config.iam.backendUrl + "/iam/v1/business/conference/validateJoinedUser";
    const params = {
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify({
            confId: conferenceId
        }),
        headers:{
            'Content-Type': 'application/json'
        }
    };

    fetch(apiToCall, params)
        .then(res => {
            if (res && res.status === 409){
                urlToRedirect = "/iam/joined";
                throw new Error();
            }
            return res.json()
        }).then(
        (result) => {
            let statusAPI = result && result.resultCode === "0";
            if (statusAPI) {
                successCallback();
            }else{
                logger.error('Calling API success with error', result);
                window.location.href = urlToRedirect;
            }
        },
        (error) => {
            logger.error('Calling API failed', error);
            window.location.href = urlToRedirect;
        }
    );


});

// Workaround for the issue when returning to a page with the back button and
// the page is loaded from the 'back-forward' cache on iOS which causes nothing
// to be rendered.
if (OS === 'ios') {
    window.addEventListener('pageshow', event => {
        // Detect pages loaded from the 'back-forward' cache
        // (https://webkit.org/blog/516/webkit-page-cache-ii-the-unload-event/)
        if (event.persisted) {
            // Maybe there is a more graceful approach but in the moment of
            // writing nothing else resolves the issue. I tried to execute our
            // DOMContentLoaded handler but it seems that the 'onpageshow' event
            // is triggered only when 'window.location.reload()' code exists.
            window.location.reload();
        }
    });
}

/**
 * Stops collecting the logs and disposing the API when the user closes the
 * page.
 */
window.addEventListener('beforeunload', () => {
    // Stop the LogCollector
    if (APP.logCollectorStarted) {
        APP.logCollector.stop();
        APP.logCollectorStarted = false;
    }
    APP.API.notifyConferenceLeft(APP.conference.roomName);
    APP.API.dispose();
    getJitsiMeetTransport().dispose();
});
