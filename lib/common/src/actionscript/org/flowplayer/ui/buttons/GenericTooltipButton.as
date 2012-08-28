/*
 * Author: Thomas Dubois, <thomas _at_ flowplayer org>
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.ui.buttons {
	
    import flash.display.DisplayObjectContainer;
    import org.flowplayer.view.AnimationEngine;
	
	import org.flowplayer.ui.buttons.TooltipButtonConfig;
	import org.flowplayer.ui.buttons.AbstractTooltipButton;


	/**
	 * @author api
	 */
	public class GenericTooltipButton extends AbstractTooltipButton {

		private var _buttonFace:DisplayObjectContainer;

		public function GenericTooltipButton(face:DisplayObjectContainer, config:TooltipButtonConfig, animationEngine:AnimationEngine) {
			_buttonFace = face;
			super(config, animationEngine);
		}

        override protected function createFace():DisplayObjectContainer {
            return _buttonFace;
        }
	}
}
