import {openDialog} from '../base/dialog';

import { DesktopPicker } from './components';
import {showNotification} from "../notifications";
import {NOTIFICATION_TYPE} from "../notifications/constants";

/**
 * Signals to open a dialog with the DesktopPicker component.
 *
 * @param {Object} options - Desktop sharing settings.
 * @param {Function} onSourceChoose - The callback to invoke when
 * a DesktopCapturerSource has been chosen.
 * @returns {Object}
 */
export function showDesktopPicker(options = {}, onSourceChoose) {
    const { desktopSharingSources } = options;

    return openDialog(DesktopPicker, {
        desktopSharingSources,
        onSourceChoose
    });
}

export function askedSharingScreenPerms() {
    return showNotification({
            titleKey: 'permissionsPopup.screenShareTitle',
            descriptionKey: 'permissionsPopup.screenShareDesc',
            appearance: NOTIFICATION_TYPE.WARNING
    }, 10000);
}

export function askedAccessibilityPerms() {
    return showNotification({
        titleKey: 'permissionsPopup.accessibilityTitle',
        descriptionKey: 'permissionsPopup.accessibilityDesc',
        appearance: NOTIFICATION_TYPE.WARNING
    }, 10000);
}
