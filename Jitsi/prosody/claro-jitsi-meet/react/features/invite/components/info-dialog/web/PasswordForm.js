// @flow

import React, { Component } from 'react';

import { translate } from '../../../../base/i18n';
import { LOCKED_LOCALLY } from '../../../../room-lock';

/**
 * The type of the React {@code Component} props of {@link PasswordForm}.
 */
type Props = {

    /**
     * Whether or not to show the password editing field.
     */
    editEnabled: boolean,

    /**
     * The value for how the conference is locked (or undefined if not locked)
     * as defined by room-lock constants.
     */
    locked: string,

    /**
     * Callback to invoke when the local participant is submitting a password
     * set request.
     */
    onSubmit: Function,

    /**
     * The current known password for the JitsiConference.
     */
    password: string,

    /**
     * The number of digits to be used in the password.
     */
    passwordNumberOfDigits: boolean,

    passwordWithError:boolean,

    /**
     * Invoked to obtain translated strings.
     */
    t: Function
};

/**
 * The type of the React {@code Component} state of {@link PasswordForm}.
 */
type State = {

    /**
     * The value of the password being entered by the local participant.
     */
    enteredPassword: string
};

/**
 * React {@code Component} for displaying and editing the conference password.
 *
 * @extends Component
 */
class PasswordForm extends Component<Props, State> {
    /**
     * Implements React's {@link Component#getDerivedStateFromProps()}.
     *
     * @inheritdoc
     */
    static getDerivedStateFromProps(props, state) {
        return {
            enteredPassword: props.editEnabled ? state.enteredPassword : ''
        };
    }

    state = {
        enteredPassword: '',
        passwordWithError: false,
    };

    /**
     * Initializes a new {@code PasswordForm} instance.
     *
     * @param {Props} props - The React {@code Component} props to initialize
     * the new {@code PasswordForm} instance with.
     */
    constructor(props: Props) {
        super(props);

        // Bind event handlers so they are only bound once per instance.
        this._onEnteredPasswordChange
            = this._onEnteredPasswordChange.bind(this);
        this._onPasswordSubmit = this._onPasswordSubmit.bind(this);
        this._onKeyDown = this._onKeyDown.bind(this);
    }

    /**
     * Implements React's {@link Component#render()}.
     *
     * @inheritdoc
     * @returns {ReactElement}
     */
    render() {
        const { t } = this.props;

        return (
            <div>
            <div className = 'info-password'
                style = {{
                    opacity: this.props.editEnabled || this.props.locked ? '1' : '0'
                }}
            >
                <span className = 'info-label'>
                    { t('info.password') }
                </span>
                <span className = 'spacer'>&nbsp;</span>
                <span className = 'info-password-field info-value'>
                    { this._renderPasswordField() }
                </span>

            </div>
            { this._renderErrorMessage() }
            </div>
        );
    }

    /**
     * Returns a ReactElement for showing the current state of the password or
     * for editing the current password.
     *
     * @private
     * @returns {ReactElement}
     */
    _renderPasswordField() {
        if (this.props.editEnabled) {
            let digitPattern, placeHolderText;

            digitPattern = "[A-Za-z0-9@_\.\-]{8}";
            return (
                <form
                    className = 'info-password-form'
                    onKeyDown = { this._onKeyDown }
                    onSubmit = { this._onPasswordSubmit }>
                    <input
                        autoFocus = { true }
                        className = 'info-password-input'
                        minLength = {8}
                        maxLength = {8}
                        onChange = { this._onEnteredPasswordChange }
                        pattern = { digitPattern }
                        placeholder = { placeHolderText }
                        spellCheck = { 'false' }
                        type = 'text'
                        value = { this.state.enteredPassword }
                        />
                </form>
            );
        } else if (this.props.locked === LOCKED_LOCALLY) {
            return (
                <div className = 'info-password-local'>
                    { this.props.password }
                </div>
            );
        } else if (this.props.locked) {
            return (
                <div className = 'info-password-remote'>
                    { this.props.t('passwordSetRemotely') }
                </div>
            );
        }

        return (
            <div className = 'info-password-none'>
                   { this.props.t('info.noPassword') }
            </div>
        );
    }

    _renderErrorMessage(){
        const { t } = this.props;

        if(!this.props.editEnabled)
            return null;

        let className = this.state.passwordWithError ? 'info-password-error':'info-password-warning';
        let textKey = this.state.passwordWithError ? "info.conferencePasswordError":'info.conferencePasswordRequirements';
        return (
            <div className = {className}>
                { t(textKey) }
            </div>
        );

    }

    _onEnteredPasswordChange: (Object) => void;

    /**
     * Updates the internal state of entered password.
     *
     * @param {Object} event - DOM Event for value change.
     * @private
     * @returns {void}
     */
    _onEnteredPasswordChange(event) {
        let password = event.target.value;
        let isValid = this._isValidPassword(password);

        this.setState({ enteredPassword: password, passwordWithError:!isValid});
    }

    _onPasswordSubmit: (Object) => void;

    /**
     * Invokes the passed in onSubmit callback to notify the parent that a
     * password submission has been attempted.
     *
     * @param {Object} event - DOM Event for form submission.
     * @private
     * @returns {void}
     */
    _onPasswordSubmit(event) {
        event.preventDefault();
        event.stopPropagation();

        if(this._isValidPassword(this.state.enteredPassword))
            this.props.onSubmit(this.state.enteredPassword);

        return false;
    }

    _isValidPassword(password: string){
        let arr =  password.split(" ");
        if(arr.length > 1)
            return false;

        let isDigit = false;
        let isLetter = false;

        let i = 0;
        while(i < password.length){

            if(password[i] >= 'a' && password[i] <= 'z' || password[i] >= 'A' && password[i] <= 'Z' ){
                isLetter = true;
            }else if(!isNaN(password[i]) ){
                isDigit = true;
            }
            else if(password[i] !== '@'
                        && password[i] !== '.'
                        && password[i] !== '-'
                        && password[i] !== '_' ){
                return false;
            }

            if(isDigit && isLetter )
                return true;
            i++;
        }
        return false;
    }



    _onKeyDown: (Object) => void;

    /**
     * Stops the the EnterKey for propagation in order to prevent the dialog
     * to close.
     *
     * @param {Object} event - The key event.
     * @private
     * @returns {void}
     */
    _onKeyDown(event) {
        if (event.key === 'Enter') {
            event.stopPropagation();
        }
    }

}

export default translate(PasswordForm);
