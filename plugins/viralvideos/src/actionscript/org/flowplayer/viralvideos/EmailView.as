/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.viralvideos {
    import com.adobe.serialization.json.JSON;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.navigateToURL;
    import flash.text.TextField;
    import flash.utils.Timer;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.ui.buttons.LabelButton;
    import org.flowplayer.ui.buttons.ButtonConfig;
    import org.flowplayer.util.URLUtil;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.viralvideos.config.EmailConfig;

    internal class EmailView extends StyleableView {

        private var _config:EmailConfig;
        private var _formContainer:Sprite;
        private var _titleLabel:TextField;
        private var _emailToLabel:TextField;
        private var _emailToInput:TextField;
        private var _messageLabel:TextField;
        private var _messageInput:TextField;
        private var _nameFromLabel:TextField;
        private var _nameFromInput:TextField;
        private var _emailFromLabel:TextField;
        private var _emailFromInput:TextField;
        private var _statusLabel:TextField;
        private var _sendBtn:LabelButton;
        private var _videoURL:String;
        private var _buttonConfig:ButtonConfig;

        public function EmailView(plugin:DisplayPluginModel, player:Flowplayer, config:EmailConfig, buttonConfig:ButtonConfig,  style:Object) {
            super("viral-email", plugin, player, style);
            _config = config;
            _buttonConfig = buttonConfig;
            createForm();
            this.addEventListener(Event.ADDED_TO_STAGE, setTextFocus);
        }

        public function setTextFocus(event:Event):void {
            this.removeEventListener(Event.ADDED_TO_STAGE, setTextFocus);
            stage.focus = _emailToInput;
        }

        private function titleLabel():TextField {
            var field:TextField = createLabelField();
            field.htmlText = "<span class=\"title\">" + _config.labels.title + "</span>";
            
            return field;
        }

        private function emailToLabel():TextField {
            var field:TextField = createLabelField();
            field.htmlText = "<span class=\"label\">"+ _config.labels.to +" <span class=" +
                             "\"small\">"+ _config.labels.toSmall +"</span></span>";
            return field;
        }

        private function emailToInput():TextField {
            var field:TextField = createInputField();
            field.tabIndex = 1;
            field.mouseWheelEnabled = true;
            return field;
        }

        private function optional(field:String):String {
            if (_config.isRequired(field)) return "";
            return " <span class=\"small\">" + _config.labels.optional + "</span></span>";
        }

        private function messageLabel():TextField {
            var field:TextField = createLabelField();
            field.htmlText = "<span class=\"label\">" + _config.labels.message + optional("message");
            return field;
        }

        private function messageInput():TextField  {
            var field:TextField = createInputField();
            field.tabIndex = 2;
            field.multiline = true;
            field.wordWrap = true;
            field.mouseWheelEnabled = true;
            return field;
        }

        private function nameFromLabel():TextField {
            var field:TextField = createLabelField();
            field.htmlText = "<span class=\"label\">" + _config.labels.from + optional("name");
            return field;
        }

        private function nameFromInput():TextField {
            var field:TextField = createInputField();
            field.tabIndex = 3;
            return field;
        }

        private function emailFromLabel():TextField {
            var field:TextField = createLabelField();
            field.htmlText = "<span class=\"label\">" + _config.labels.fromAddress + optional("email");
            return field;
        }

        private function emailFromInput():TextField {
            var field:TextField = createInputField();
            field.tabIndex = 4;
            return field;
        }

        private function createForm():void {
            _formContainer = new Sprite();
            addChild(_formContainer);

            _titleLabel = titleLabel();
            _formContainer.addChild(_titleLabel);

            _emailToLabel = emailToLabel();
            _formContainer.addChild(_emailToLabel);

            _emailToInput = emailToInput();
            _formContainer.addChild(_emailToInput);


            _messageLabel = messageLabel();
            addChild(_messageLabel);

            _messageInput = messageInput();
            _formContainer.addChild(_messageInput);


            _nameFromLabel = nameFromLabel();
            addChild(_nameFromLabel);


            _emailFromLabel = emailFromLabel();
            addChild(_emailFromLabel);

            _nameFromInput = nameFromInput();
            _formContainer.addChild(_nameFromInput);

            _statusLabel = createLabelField();
            _formContainer.addChild(_statusLabel);


            _emailFromInput = emailFromInput();
            _formContainer.addChild(_emailFromInput);

            _sendBtn = new LabelButton(_config.labels.send, _buttonConfig, player.animationEngine);
            _sendBtn.tabEnabled = true;
            _sendBtn.tabIndex = 5;
            _sendBtn.addEventListener(MouseEvent.CLICK, onSubmit);

            _formContainer.addChild(_sendBtn);

            //arrange the form elements
            arrangeForm();

        }
        
        private function getPageUrl():String {
        	return player.currentClip.getCustomProperty("pageUrl") 
        	? String(player.currentClip.getCustomProperty("pageUrl"))
        	: URLUtil.pageUrl;
        }

        private function getEmailToken():void {
            log.debug("Requesting " + _config.tokenUrl);
            var loader:URLLoader = new URLLoader();
            var request:URLRequest = new URLRequest(_config.tokenUrl);
            request.method = URLRequestMethod.GET;

            loader.load(request);

            loader.addEventListener(Event.COMPLETE, onTokenSuccess);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onTokenError);
        }

        private function sendServerEmail():void {

            var loader:URLLoader = new URLLoader();
            var request:URLRequest = new URLRequest(_config.script);
            request.method = URLRequestMethod.POST;

            //set the post variables from the form elements
            var param:URLVariables = new URLVariables();
            param.name = _nameFromInput.text;
            param.email = _emailFromInput.text;
            param.to = _emailToInput.text;
            //format the message from the message template
            param.message = formatString(_config.labels.template, _messageInput.text, _videoURL, _videoURL);
            param.subject = _config.labels.subject;
            param.token = _config.token;

            param.dataFormat = URLLoaderDataFormat.VARIABLES;
            request.data = param;

            log.debug("Loading request");
            loader.load(request);
            loader.addEventListener(Event.COMPLETE, onSendSuccess);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onSendError);
        }

        private function sendLocalEmail():void {
            var request:URLRequest = new URLRequest(formatString("mailto:{0}?subject={1}&body={2}", _emailToInput.text, encodeURIComponent(_config.labels.subject), encodeURIComponent(formatString(_config.labels.template, _messageInput.text, _videoURL, _nameFromInput.text))));
            navigateToURL(request, "_self");
            createCloseTimer();
        }

        private function setStatus(msg:String):void {
            _statusLabel.htmlText = msg;
            createLabelReset(_statusLabel);
        }

        protected function createCloseTimer():void {
            var timer:Timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void { ViralVideos(model.getDisplayObject()).close(); } );
            timer.start();
        }

        private function formSuccess(value:String):void {
            setStatus('<span class="success">' + value + '</span>');
        }

        private function formError(error:String):void {
            setStatus('<span class="error">' + error + '</span>');
        }

        private function validateField(field:TextField, fieldName:String, missingFields:Array):void {
            if (!field.text && _config.isRequired(fieldName)) missingFields.push(fieldName);
        }

        private function checkRequiredFields():Boolean {
            var required:Array = _config.required;
            var missingFields:Array = [];
            if (required.length > 0) {
                validateField(_nameFromInput, "name", missingFields);
                validateField(_emailFromInput, "email", missingFields);
                validateField(_emailToInput, "to", missingFields);
                validateField(_messageInput, "message", missingFields);
            }
            return (missingFields.length == 0);
        }

        private function onSubmit(event:MouseEvent):void {
            if (! checkRequiredFields()) {
                formError(_config.labels.required);
                return;
            }

            //#543 set the per clip page url on form submission to get the individual configs.
            _videoURL = getPageUrl();

            if (_config.script) {
                //email token is already set , post the form
                if (_config.token && !_config.tokenUrl)
                {
                    formSuccess(_config.labels.sending);
                    sendServerEmail();
                } else if (_config.tokenUrl) {
                    //request the email script token to be able to post the form
                    formSuccess(_config.labels.sending);
                    getEmailToken();
                } else {
                    //email script token url is not enabled just post the form
                    formSuccess(_config.labels.sending);
                    sendServerEmail();
                }

            } else {
                //send a local email instead
                formSuccess(_config.labels.sending);
                sendLocalEmail();
            }
        }

        private function onSendError(event:IOErrorEvent):void {
            log.debug("Error: " + event.text);

            var loader:URLLoader = event.target as URLLoader;

            loader.removeEventListener(Event.COMPLETE, onSendSuccess);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendError);
            loader.close();
            loader = null;

            closeViewWithSuccess();
        }

        private function onSendSuccess(event:Event):void {
            var loader:URLLoader = event.target as URLLoader;

            log.debug("Server returned with output: " + loader.data.toString());

            loader.removeEventListener(Event.COMPLETE, onSendSuccess);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendError);

            loader.close();
            loader = null;

            closeViewWithSuccess();
        }

        private function onTokenError(event:IOErrorEvent):void {
            log.debug("Error: " + event.text);

            var loader:URLLoader = event.target as URLLoader;

            loader.removeEventListener(Event.COMPLETE, onTokenSuccess);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onTokenError);
            loader.close();
            loader = null;

            closeViewWithSuccess();
        }

        private function closeViewWithSuccess():void
        {
            formSuccess(_config.labels.success);
            createCloseTimer();
        }

        private function onTokenSuccess(event:Event):void {
            var loader:URLLoader = event.target as URLLoader;

            loader.removeEventListener(Event.COMPLETE, onTokenSuccess);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, onTokenError);

            log.debug("Loading Token " + loader.data.toString());

            loader.close();
            loader = null;

            var data:Object = null;

            try {
                data = JSON.decode(loader.data.toString());
            } catch(e:Error) {

            }

            loader.close();
            loader = null;

            if (data != null)
            {
                //if a json object key is error an error is returned
                if (data.error)
                {
                    log.debug("Server returned with error: " + data.error);
                    closeViewWithSuccess();
                } else {
                    //we have a token, set the email script token and post the form
                    _config.token = data.token;
                    sendServerEmail();
                }
            }

        }

        private function arrangeForm():void {
            _titleLabel.x = PADDING_X;
            _titleLabel.y = MARGIN_TOP;
            _titleLabel.width = width;
            _titleLabel.height = 20;

            _emailToLabel.x = PADDING_X;
            _emailToLabel.y = _titleLabel.y + _titleLabel.height + (PADDING_Y * 2);
            _emailToLabel.width = width;
            _emailToLabel.height = 15;

            _emailToInput.x = PADDING_X;
            _emailToInput.y = _emailToLabel.y + _emailToLabel.height + PADDING_Y;
            _emailToInput.width = width - 2 * PADDING_X;
            _emailToInput.height = 20;

            _messageLabel.x = PADDING_X;
            _messageLabel.y = _emailToInput.y + _emailToInput.height + PADDING_Y;
            _messageLabel.width = width - PADDING_X * 2;
            _messageLabel.height = 20;

            // from bottom

            _sendBtn.x = width - _sendBtn.width - PADDING_X;
            _sendBtn.y = height - _sendBtn.height - MARGIN_Y;
            _sendBtn.setSize(100, 25);

            _statusLabel.x = PADDING_X;
            _statusLabel.width = width - PADDING_X * 2 - _sendBtn.x;
            _statusLabel.y = _sendBtn.y;

            _statusLabel.x = PADDING_X;
            _statusLabel.y = _sendBtn.y;

            _nameFromInput.x = PADDING_X;
            _nameFromInput.y = _sendBtn.y - _nameFromInput.height - 4 * PADDING_Y;
            _nameFromInput.width = 0.5 * (width - (2 * PADDING_X) - 5);
            _nameFromInput.height = 20;

            _emailFromInput.x = _nameFromInput.x + _nameFromInput.width + 5;
            _emailFromInput.y = _nameFromInput.y;
            _emailFromInput.width = 0.5 * (width - (2 * PADDING_X) - 5);
            _emailFromInput.height = 20;

            _nameFromLabel.x = PADDING_X;
            _nameFromLabel.y = _emailFromInput.y - _nameFromLabel.height - PADDING_Y;

            _emailFromLabel.x = _emailFromInput.x;
            _emailFromLabel.y = _nameFromLabel.y;

            // message field takes all space available vertically
            _messageInput.x = PADDING_X;
            _messageInput.y = _messageLabel.y + _messageLabel.height + PADDING_Y;
            _messageInput.width = width - PADDING_X * 2;
            _messageInput.height = height - (_messageLabel.y + _messageLabel.height) - (height - _emailFromLabel.y) - PADDING_Y * 2;
        }

        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            arrangeForm();
        }
    }
}
