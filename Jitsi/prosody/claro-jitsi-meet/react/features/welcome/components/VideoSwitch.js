// @flow

import React, { Component } from 'react';
import { Switch, TouchableWithoutFeedback, View, TouchableHighlight } from 'react-native';

import { ColorSchemeRegistry } from '../../base/color-scheme';
import { translate } from '../../base/i18n';
import { Text } from '../../base/react';
import { connect } from '../../base/redux';
import { updateSettings } from '../../base/settings';

import styles, { SWITCH_THUMB_COLOR, SWITCH_UNDER_COLOR } from './styles';
import WelcomePageNative from './WelcomePage.native';
import { AbstractWelcomePage } from './AbstractWelcomePage';

/**
 * The type of the React {@code Component} props of {@link VideoSwitch}.
 */
type Props = {

    /**
     * The redux {@code dispatch} function.
     */
    dispatch: Function,

    /**
     * The i18n translate function.
     */
    t: Function,

    /**
     * Color schemed style of the header component.
     */
    _headerStyles: Object,

    /**
     * The current settings from redux.
     */
    _settings: Object
};

/**
 * Renders the "Video <-> Voice" switch on the {@code WelcomePage}.
 */
class VideoSwitch extends Component<Props> {
    /**
     * Initializes a new {@code VideoSwitch} instance.
     *
     * @inheritdoc
     */
    constructor(props) {
        super(props);
        // Bind event handlers so they are only bound once per instance.
        this._onStartAudioOnlyChange = this._onStartAudioOnlyChange.bind(this);
        this._onStartAudioOnlyFalse = this._onStartAudioOnlyChangeFn(false);
        this._onStartAudioOnlyTrue = this._onStartAudioOnlyChangeFn(true);
    }

    /**
     * Implements React's {@link Component#render}.
     *
     * @inheritdoc
     */
    render() {
        const { t, _headerStyles, _settings } = this.props;

        return (
            <View style = { styles.audioVideoSwitchContainer }>
                <TouchableHighlight onPress = {this.SampleFunction}>
                <View style = { styles.switchLabel }>
                        <Text style = { _headerStyles.headerText }>
                            { t('welcomepage.join') }
                        </Text>
                    </View>
                </TouchableHighlight>
                <TouchableWithoutFeedback
                    onPress = { this._onStartAudioOnlyFalse }>
                    <View style = { styles.switchLabel }>
                        <Text style = { _headerStyles.headerText }>
                            { t('welcomepage.audioVideoSwitch.video') }
                        </Text>
                    </View>
                </TouchableWithoutFeedback>
                <Switch
                    onValueChange = { this._onStartAudioOnlyChange }
                    style = { styles.audioVideoSwitch }
                    thumbColor = { SWITCH_THUMB_COLOR }
                    trackColor = {{ true: SWITCH_UNDER_COLOR }}
                    value = { _settings.startAudioOnly } />
                <TouchableWithoutFeedback
                    onPress = { this._onStartAudioOnlyTrue }>
                    <View style = { styles.switchLabel }>
                        <Text style = { _headerStyles.headerText }>
                            { t('welcomepage.audioVideoSwitch.audio') }
                        </Text>
                    </View>
                </TouchableWithoutFeedback>
            </View>
        );
    }
    SampleFunction(){
        console.log('Quiere entrar a conferencia');
    }

    entraras() {
        const room = this.state.room //|| this.state.generatedRoomname;
        if (room) {
            this.setState({ joining: true });

            // By the time the Promise of appNavigate settles, this component
            // may have already been unmounted.
            const onAppNavigateSettled
                = () => this._mounted && this.setState({ joining: false });

            this.props.dispatch(appNavigate(room))
                .then(onAppNavigateSettled, onAppNavigateSettled);
        }
        
        Alert.alert(
            'Entraste a conferencia',
            'se llama asi',
            [
              {text: 'Ya se que entre amigo', onPress: () => console.log('Detonar el crear entrar a conferencia')},
            ],
            {cancelable: false},
          );

    }

    _onStartAudioOnlyChange: boolean => void;

    /**
     * Handles the audio-video switch changes.
     *
     * @private
     * @param {boolean} startAudioOnly - The new startAudioOnly value.
     * @returns {void}
     */
    _onStartAudioOnlyChange(startAudioOnly) {
        const { dispatch } = this.props;

        dispatch(updateSettings({
            startAudioOnly
        }));
    }

    /**
     * Creates a function that forwards the {@code startAudioOnly} changes to
     * the function that handles it.
     *
     * @private
     * @param {boolean} startAudioOnly - The new {@code startAudioOnly} value.
     * @returns {void}
     */
    _onStartAudioOnlyChangeFn(startAudioOnly) {
        return () => this._onStartAudioOnlyChange(startAudioOnly);
    }

    _onStartAudioOnlyFalse: () => void;

    _onStartAudioOnlyTrue: () => void;
}

/**
 * Maps (parts of) the redux state to the React {@code Component} props of
 * {@code VideoSwitch}.
 *
 * @param {Object} state - The redux state.
 * @protected
 * @returns {{
 *     _settings: Object
 * }}
 */
export function _mapStateToProps(state: Object) {
    return {
        _headerStyles: ColorSchemeRegistry.get(state, 'Header'),
        _settings: state['features/base/settings']
    };
}

export default translate(connect(_mapStateToProps)(VideoSwitch));
