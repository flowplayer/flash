package org.flowplayer.info.ui
{
    import flash.display.DisplayObjectContainer;


    import org.flowplayer.info.assets.InfoToggleOn;
    import org.flowplayer.info.assets.InfoToggleOff;
    import org.flowplayer.ui.AbstractToggleButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;




    public class InfoButton extends AbstractToggleButton
    {
 

        
        public function InfoButton(config:ButtonConfig, animationEngine:AnimationEngine)
        {
           
            super(config, animationEngine);
        }
        
        override protected function onResize():void {
            _upStateFace.width = width;
            _upStateFace.height = height;
            
            if (_downStateFace) {
            	_downStateFace.width = width;
                _downStateFace.height = height;
            }
        }
        
        override protected function createUpStateFace():DisplayObjectContainer {
            return new InfoToggleOff();
        }
        
        override protected function createDownStateFace():DisplayObjectContainer {
            return new InfoToggleOn();
        }
        


    }
}