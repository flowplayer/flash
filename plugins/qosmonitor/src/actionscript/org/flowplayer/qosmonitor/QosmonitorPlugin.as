package org.flowplayer.qosmonitor {
    import org.flowplayer.model.PluginFactory; 
    import flash.display.Sprite;

    public class QosmonitorPlugin extends Sprite implements PluginFactory  {
        
        public function QosmonitorPlugin() {
            
        }
        
        public function newPlugin():Object {
            return new QosmonitorProvider();
        }
    }
}