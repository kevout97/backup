/* @flow */

import React, { Component } from 'react';

import { isBrowsersOptimal } from '../../base/environment';
import { translate , translateToHTML } from '../../base/i18n';

import { CHROME, FIREFOX } from './browserLinks';

/**
 * The namespace of the CSS styles of UnsupportedDesktopBrowser.
 *
 * @private
 * @type {string}
 */
const _SNS = 'unsupported-desktop-browser';

/**
 * The type of the React {@code Component} props of
 * {@link UnsupportedDesktopBrowser}.
 */
type Props = {

    /**
     * The function to translate human-readable text.
     */
    t: Function
};

/**
 * React component representing unsupported browser page.
 *
 * @class UnsupportedDesktopBrowser
 */
class UnsupportedDesktopBrowser extends Component<Props> {
    /**
     * Renders the component.
     *
     * @returns {ReactElement}
     */
    render() {
        return (
            <div className = { _SNS }>
                <h2 className = { `${_SNS}__title` }>
                    { t('unsupportedDesktopBrowser.title') }                   
                </h2>
                <p className = { `${_SNS}__description` }>    
                    { t('unsupportedDesktopBrowser.descriptionBrowsers') }  
                    <a
                        className = { `${_SNS}__link` }
                        href = { CHROME } >Chrome</a>&nbsp;
                        {
                            this._showFirefox() && <>and <a
                                className = { `${_SNS}__link` }
                                href = { FIREFOX }>Firefox</a></>
                        }               
                    { translateToHTML(t, 'unsupportedDesktopBrowser.descriptionDesktop') }                                       
                </p>
            </div>
        );
    }

    /**
     * Returns whether or not a link to download Firefox is displayed.
     *
     * @private
     * @returns {boolean}
     */
    _showFirefox() {
        return isBrowsersOptimal('firefox');
    }
}

export default translate(UnsupportedDesktopBrowser);
