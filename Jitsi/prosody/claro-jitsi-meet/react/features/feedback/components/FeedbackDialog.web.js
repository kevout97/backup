// @flow

import { FieldTextAreaStateless } from '@atlaskit/field-text-area';
import StarIcon from '@atlaskit/icon/glyph/star';
import StarFilledIcon from '@atlaskit/icon/glyph/star-filled';
import React, { Component } from 'react';
import { connect } from '../../base/redux';
import type { Dispatch } from 'redux';

import DropdownMenu, {
    DropdownItem,
    DropdownItemGroup
} from '@atlaskit/dropdown-menu';

import {
    createFeedbackOpenEvent,
    createSendValueEvent,
    sendAnalytics
} from '../../analytics';
import { Dialog } from '../../base/dialog';
import { translate } from '../../base/i18n';

import { cancelFeedback, submitFeedback } from '../actions';

declare var APP: Object;
declare var interfaceConfig: Object;

const scoreAnimationClass
    = interfaceConfig.ENABLE_FEEDBACK_ANIMATION ? 'shake-rotate' : '';

/**
 * The scores to display for selecting. The score is the index in the array and
 * the value of the index is a translation key used for display in the dialog.
 *
 * @types {string[]}
 */
const SCORES = [
    'feedback.veryBad',
    'feedback.bad',
    'feedback.average',
    'feedback.good',
    'feedback.veryGood'
];

/**
 * The type of the React {@code Component} props of {@link FeedbackDialog}.
 */
type Props = {

    /**
     * The cached feedback message, if any, that was set when closing a previous
     * instance of {@code FeedbackDialog}.
     */
    _message: string,

    /**
     * The cached feedback score, if any, that was set when closing a previous
     * instance of {@code FeedbackDialog}.
     */
    _score: number,

    /**
     * The JitsiConference that is being rated. The conference is passed in
     * because feedback can occur after a conference has been left, so
     * references to it may no longer exist in redux.
     */
    conference: Object,

    _audioProblem: string,
    _videoProblem: string,
    _shareScreenProblem: string,
    _remoteControlProblem: string,

    /**
     * Invoked to signal feedback submission or canceling.
     */
    dispatch: Dispatch<any>,

    /**
     * Callback invoked when {@code FeedbackDialog} is unmounted.
     */
    onClose: Function,

    /**
     * Invoked to obtain translated strings.
     */
    t: Function
};

/**
 * The type of the React {@code Component} state of {@link FeedbackDialog}.
 */
type State = {

    /**
     * The currently entered feedback message.
     */
    message: string,

    /**
     * The score selection index which is currently being hovered. The value -1
     * is used as a sentinel value to match store behavior of using -1 for no
     * score having been selected.
     */
    mousedOverScore: number,

    /**
     * The currently selected score selection index. The score will not be 0
     * indexed so subtract one to map with SCORES.
     */
    score: number,

    disabledSendButton: boolean,

    audioProblem: string,
    videoProblem: string,
    shareScreenProblem: string,
    remoteControlProblem: string,

    showSendProblemsFields : boolean,
};

/**
 * A React {@code Component} for displaying a dialog to rate the current
 * conference quality, write a message describing the experience, and submit
 * the feedback.
 *
 * @extends Component
 */
class FeedbackDialog extends Component<Props, State> {
    /**
     * An array of objects with click handlers for each of the scores listed in
     * the constant SCORES. This pattern is used for binding event handlers only
     * once for each score selection icon.
     */
    _scoreClickConfigurations: Array<Object>;

    /**
     * Initializes a new {@code FeedbackDialog} instance.
     *
     * @param {Object} props - The read-only React {@code Component} props with
     * which the new instance is to be initialized.
     */
    constructor(props: Props) {
        super(props);

        const { _message, _score, _audioProblem, _videoProblem, _shareScreenProblem, _remoteControlProblem} = this.props;

        this.state = {
            /**
             * The currently entered feedback message.
             *
             * @type {string}
             */
            message: _message,

            /**
             * The score selection index which is currently being hovered. The
             * value -1 is used as a sentinel value to match store behavior of
             * using -1 for no score having been selected.
             *
             * @type {number}
             */
            mousedOverScore: -1,

            disabledSendButton:true,

            /**
             * The currently selected score selection index. The score will not
             * be 0 indexed so subtract one to map with SCORES.
             *
             * @type {number}
             */
            score: _score > -1 ? _score - 1 : _score,


            audioProblem: '' ,
            videoProblem: '' ,
            shareScreenProblem: '',
            remoteControlProblem: '',
            showSendProblemsFields : false,

        };

        this._scoreClickConfigurations = SCORES.map((textKey, index) => {
            return {
                _onClick: () => this._onScoreSelect(index),
                _onMouseOver: () => this._onScoreMouseOver(index)
            };
        });

        // Bind event handlers so they are only bound once for every instance.
        this._onCancel = this._onCancel.bind(this);
        this._onMessageChange = this._onMessageChange.bind(this);
        this._onScoreContainerMouseLeave
            = this._onScoreContainerMouseLeave.bind(this);
        this._onSubmit = this._onSubmit.bind(this);
        this._onSecondaryAction = this._onSecondaryAction.bind(this);
    }

    /**
     * Emits an analytics event to notify feedback has been opened.
     *
     * @inheritdoc
     */
    componentDidMount() {
        sendAnalytics(createFeedbackOpenEvent());
        if (typeof APP !== 'undefined') {
            APP.API.notifyFeedbackPromptDisplayed();
        }
    }

    /**
     * Invokes the onClose callback, if defined, to notify of the close event.
     *
     * @inheritdoc
     */
    componentWillUnmount() {
        if (this.props.onClose) {
            this.props.onClose();
        }
    }

    /**
     * Implements React's {@link Component#render()}.
     *
     * @inheritdoc
     * @returns {ReactElement}
     */
    render() {
        const { message, mousedOverScore, score, disabledSendButton,audioProblem,videoProblem,remoteControlProblem,shareScreenProblem,showSendProblemsFields} = this.state;
        const scoreToDisplayAsSelected
            = mousedOverScore > -1 ? mousedOverScore : score;

        const scoreIcons = this._scoreClickConfigurations.map(
            (config, index) => {
                const isFilled = index <= scoreToDisplayAsSelected;
                const activeClass = isFilled ? 'active' : '';
                const className
                    = `star-btn ${scoreAnimationClass} ${activeClass}`;

                return (
                    <a
                        className = { className }
                        key = { index }
                        onClick = { config._onClick }
                        onMouseOver = { config._onMouseOver }>
                        { isFilled
                            ? <StarFilledIcon
                                label = 'star-filled'
                                size = 'xlarge' />
                            : <StarIcon
                                label = 'star'
                                size = 'xlarge' /> }
                    </a>
                );
            });

        const { t } = this.props;

        const feedbackRating = () => {
            return (
                    <div className = 'rating'>
                        <div className = 'star-label'>
                            <p id = 'starLabel'>
                                { t(SCORES[scoreToDisplayAsSelected]) }
                            </p>
                        </div>
                        <div
                            className = 'stars'
                            onMouseLeave = { this._onScoreContainerMouseLeave }>
                            { scoreIcons }
                        </div>
                    </div>
                );
        };

        const feedbackProblems = () =>{
            return (
                <div className = 'details'>
                <div
                    className = 'settings-sub-pane language-settings' >
                    <div className = 'mock-atlaskit-label'>
                        { t('feedback.problems.audio.title') }
                    </div>
                    <DropdownMenu  triggerType="button" shouldFitContainer = { true }  trigger = {audioProblem === '' ? t('feedback.problems.noproblem'): audioProblem } >
                        <DropdownItemGroup>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({audioProblem : ''}) } }>
                                    { t('feedback.problems.noproblem') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({audioProblem : t('feedback.problems.audio.lacks')}) } } >
                                { t('feedback.problems.audio.lacks') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({audioProblem : t('feedback.problems.audio.bad')}) } } >
                                { t('feedback.problems.audio.bad') }
                            </DropdownItem>
                            <DropdownItem onClick ={()=>{ this._onListBoxChange({audioProblem : t('feedback.problems.audio.none')}) } } >
                                { t('feedback.problems.audio.none') }
                            </DropdownItem>
                        </DropdownItemGroup>
                    </DropdownMenu>
                </div>

                <div
                    className = 'settings-sub-pane language-settings' >
                    <div className = 'mock-atlaskit-label'>
                        { t('feedback.problems.video.title') }
                    </div>
                    <DropdownMenu triggerType="button" shouldFitContainer = { true }  trigger={videoProblem === '' ? t('feedback.problems.noproblem'): videoProblem } >
                        <DropdownItemGroup>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({videoProblem : ''}) } } >
                                { t('feedback.problems.noproblem') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({videoProblem : t('feedback.problems.video.lacks')}) } } >
                                { t('feedback.problems.video.lacks') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({videoProblem : t('feedback.problems.video.bad')}) } } >
                                { t('feedback.problems.video.bad') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({videoProblem : t('feedback.problems.video.none')}) } } >
                                { t('feedback.problems.video.none') }
                            </DropdownItem>
                        </DropdownItemGroup>
                    </DropdownMenu>
                </div>
                <div
                    className = 'settings-sub-pane language-settings' >
                    <div className = 'mock-atlaskit-label'>
                        { t('feedback.problems.shareScreen.title') }
                    </div>
                    <DropdownMenu  triggerType="button" shouldFitContainer = { true }  trigger={ shareScreenProblem === '' ? t('feedback.problems.noproblem'): shareScreenProblem } >
                        <DropdownItemGroup>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({shareScreenProblem :'' }) } } >
                                { t('feedback.problems.noproblem') }
                            </DropdownItem>
                            <DropdownItem onClick ={()=>{ this._onListBoxChange({shareScreenProblem : t('feedback.problems.shareScreen.lacks')}) } }>
                                { t('feedback.problems.shareScreen.lacks') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({shareScreenProblem : t('feedback.problems.shareScreen.bad')}) } }>
                                { t('feedback.problems.shareScreen.bad') }
                            </DropdownItem>
                        </DropdownItemGroup>
                    </DropdownMenu>
                </div>
                <div
                    className = 'settings-sub-pane language-settings' >
                    <div className = 'mock-atlaskit-label'>
                        { t('feedback.problems.remoteControl.title') }
                    </div>
                    <DropdownMenu triggerType="button" shouldFitContainer = { true }  trigger={remoteControlProblem === '' ? t('feedback.problems.noproblem'): remoteControlProblem } >
                        <DropdownItemGroup>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({remoteControlProblem : ''}) } } >
                                { t('feedback.problems.noproblem') }
                            </DropdownItem>
                            <DropdownItem onClick ={()=>{ this._onListBoxChange({remoteControlProblem : t('feedback.problems.remoteControl.lacks')}) } }>
                                { t('feedback.problems.remoteControl.lacks') }
                            </DropdownItem>
                            <DropdownItem  onClick ={()=>{ this._onListBoxChange({remoteControlProblem:t('feedback.problems.remoteControl.bad')}) } }>
                                { t('feedback.problems.remoteControl.bad') }
                            </DropdownItem>
                        </DropdownItemGroup>
                    </DropdownMenu>
                </div>

                <FieldTextAreaStateless
                    autoFocus = { true }
                    className = 'input-control'
                    id = 'feedbackTextArea'
                    label = { t('feedback.detailsLabel') }
                    onChange = { this._onMessageChange }
                    shouldFitContainer = { true }
                value = { message } />
            </div>
            );
        }

        var feedback;
        if(this.state.showSendProblemsFields){
                feedback = feedbackProblems();
        }else{
            feedback = feedbackRating();
        }

        return (
            <Dialog
                okKey = 'dialog.Submit'
                okDisabled = {this.state.disabledSendButton}
                onCancel = { this._onCancel }
                onSubmit = { this._onSubmit }
                onSecondaryAction = {this._onSecondaryAction}
                titleKey = {!this.state.showSendProblemsFields ? t('feedback.rateExperience') : t('feedback.sendProblemsTitle') }
                secondaryText = {!this.state.showSendProblemsFields ? t('feedback.sendProblems') : t('feedback.cancelSendProblems') }>
                <div className = 'feedback-dialog'>
                    {feedback}
                </div>
            </Dialog>
        );
    }

    _onCancel: () => boolean;

    /**
     * Dispatches an action notifying feedback was not submitted. The submitted
     * score will have one added as the rest of the app does not expect 0
     * indexing.
     *
     * @private
     * @returns {boolean} Returns true to close the dialog.
     */
    _onCancel() {
        const { message, score } = this.state;
        const scoreToSubmit = score > -1 ? score + 1 : score;

        this.props.dispatch(cancelFeedback(scoreToSubmit, message));

        return true;
    }

    _onSecondaryAction: () => void;

    resetSendProblemsFields ()  {
        const {score} = this.state;
        this.setState({
            audioProblem: '',
            videoProblem: '',
            shareScreenProblem: '',
            remoteControlProblem: '',
            message : '',
            disabledSendButton : score === -1
        });
    }


    _onSecondaryAction(){
        if(this.state.showSendProblemsFields){ //Cancel label is showing
            this.resetSendProblemsFields();
        }else{
            this.setState({ disabledSendButton : true });
        }
       this.setState({showSendProblemsFields: !this.state.showSendProblemsFields});
    }

    _onMessageChange: (Object) => void;

    /**
     * Updates the known entered feedback message.
     *
     * @param {Object} event - The DOM event from updating the textfield for the
     * feedback message.
     * @private
     * @returns {void}
     */
    _onMessageChange(event) {
        var txtMessage =  event.target.value;
        this._onListBoxChange({ message: txtMessage});
    }
    _onListBoxChange(objToUpdate){

        const {audioProblem,videoProblem,shareScreenProblem,remoteControlProblem,message, score} =  this.state;

        var value = Object.values(objToUpdate)[0].trim();

        var disableButton = false;
        if ( audioProblem.length === 0 &&  videoProblem.length === 0 &&  shareScreenProblem.length === 0
                    &&  remoteControlProblem.length === 0 &&  message.length === 0 ) //All empty
        {

            if(value.length === 0){ //new value is empty
                disableButton = true;
            }else{ //new value is not empty
                disableButton = false;
            }

        }
        else{ //there is values

            if(value.length !== 0){ //new value is not empty
                disableButton = false;
            }else{ //new value is empty

                    var count = 0;
                    if(audioProblem.length !== 0) count++;
                    if(videoProblem.length !== 0) count++;
                    if(shareScreenProblem.length !== 0) count++;
                    if(remoteControlProblem.length !== 0) count++;
                    if(message.length !== 0) count++;

                    if(count === 1){
                        var key = Object.keys(objToUpdate)[0].trim();
                        //If new value is empty and will replace the only not empty value, all values will be empty
                        if(key == 'audioProblem' && audioProblem.length !== 0){
                            disableButton = true;
                        }
                        else if(key == 'videoProblem' && videoProblem.length !== 0){
                            disableButton = true;
                        }
                        else if(key == 'shareScreenProblem' && shareScreenProblem.length !== 0){
                            disableButton = true;
                        }
                        else if(key == 'remoteControlProblem' && remoteControlProblem.length !== 0){
                            disableButton = true;
                        }
                        else if(key == 'message' && message.length !== 0){
                            disableButton = true;
                        }else{
                            disableButton = false;
                        }

                    }else{
                        disableButton = false;
                    }


            }

        }

        objToUpdate.disabledSendButton = disableButton;
        this.setState(objToUpdate);
    }

    /**
     * Updates the currently selected score.
     *
     * @param {number} score - The index of the selected score in SCORES.
     * @private
     * @returns {void}
     */
    _onScoreSelect(score) {
        this.setState({ score, disabledSendButton:false });
    }

    _onScoreContainerMouseLeave: () => void;

    /**
     * Sets the currently hovered score to null to indicate no hover is
     * occurring.
     *
     * @private
     * @returns {void}
     */
    _onScoreContainerMouseLeave() {
        this.setState({ mousedOverScore: -1 });
    }

    /**
     * Updates the known state of the score icon currently behind hovered over.
     *
     * @param {number} mousedOverScore - The index of the SCORES value currently
     * being moused over.
     * @private
     * @returns {void}
     */
    _onScoreMouseOver(mousedOverScore) {
        this.setState({ mousedOverScore });
    }

    _onSubmit: () => void;

    /**
     * Dispatches the entered feedback for submission. The submitted score will
     * have one added as the rest of the app does not expect 0 indexing.
     *
     * @private
     * @returns {boolean} Returns true to close the dialog.
     */
    _onSubmit() {
        const { conference, dispatch } = this.props;
        const { message, score, audioProblem, videoProblem, shareScreenProblem, remoteControlProblem } = this.state;

        const scoreToSubmit = score > -1 ? score + 1 : score;
        sendAnalytics(createSendValueEvent(scoreToSubmit));
        dispatch(submitFeedback(scoreToSubmit, message, audioProblem, videoProblem, shareScreenProblem, remoteControlProblem, conference));

        return true;
    }
}

/**
 * Maps (parts of) the Redux state to the associated {@code FeedbackDialog}'s
 * props.
 *
 * @param {Object} state - The Redux state.
 * @private
 * @returns {{
 * }}
 */
function _mapStateToProps(state) {
    const { message, score } = state['features/feedback'];

    return {
        /**
         * The cached feedback message, if any, that was set when closing a
         * previous instance of {@code FeedbackDialog}.
         *
         * @type {string}
         */
        _message: message,

        /**
         * The currently selected score selection index.
         *
         * @type {number}
         */
        _score: score
    };
}

export default translate(connect(_mapStateToProps)(FeedbackDialog));
