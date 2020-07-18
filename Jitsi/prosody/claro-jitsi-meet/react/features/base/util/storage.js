const STORAGE_KEY = 'features/base/conference_list';

/**
 * Loads a script from a specific URL. The script will be interpreted upon load.
 *
 * @param {Object} state - Redix state
 * @returns {Promise} Resolved with no arguments when the script is loaded and
 * rejected with the error from JitsiMeetJS.ScriptUtil.loadScript method.
 */
export function getConferenceFromListStorage(state) {
    try {
        const conferenceId = state['features/base/conference'].room || '';

        if (conferenceId && window && window.localStorage) {
            const conferenceList = JSON.parse(window.localStorage.getItem(STORAGE_KEY));

            if (conferenceList[conferenceId]) {
                return conferenceList[conferenceId];
            }
        }
    }catch (e) {
        console.error('[AMX DEBUG] Failed to decode conference from list');
    }

    return false;

}