package org.osmf.layout
{
    import flexunit.framework.Assert;
    
    public class TestLayoutTargetSprite
    {		
        private var layoutTargetSprite:LayoutTargetSprite;
        
        [Before]
        public function setUp():void
        {
            this.layoutTargetSprite = new LayoutTargetSprite()
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function testXSetterSingleChild():void
        {
            var triggered:Boolean = false;
           
            function genericTriggeredCallback():void
            {
                triggered = true;
            }

            var genericDO:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback);     
            this.layoutTargetSprite.addChild(genericDO);
            
            this.layoutTargetSprite.x = 10;
            
            Assert.assertTrue(triggered);
        }
        
        [Test]
        public function testYSetterSingleChild():void
        {
            var triggered:Boolean = false;
            
            function genericTriggeredCallback():void
            {
                triggered = true;
            }
            
            var genericDO:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback);     
            this.layoutTargetSprite.addChild(genericDO);
            
            this.layoutTargetSprite.y = 10;
            
            Assert.assertTrue(triggered);
        }
        
        [Test]
        public function testXSetterMultipleChildren():void
        {
            var triggered1:Boolean = false;
            var triggered2:Boolean = false;
            
            function genericTriggeredCallback1():void
            {
                triggered1 = true;
            }
            
            function genericTriggeredCallback2():void
            {
                triggered2 = true;
            }
            
            var genericDO1:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback1);
            var genericDO2:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback2);
            this.layoutTargetSprite.addChild(genericDO1);
            this.layoutTargetSprite.addChild(genericDO2);
            
            this.layoutTargetSprite.x = 10;
            
            Assert.assertTrue(triggered1);
            Assert.assertTrue(triggered2);
        }
        
        [Test]
        public function testYSetterMultipleChildren():void
        {
            var triggered1:Boolean = false;
            var triggered2:Boolean = false;
            
            function genericTriggeredCallback1():void
            {
                triggered1 = true;
            }
            
            function genericTriggeredCallback2():void
            {
                triggered2 = true;
            }
            
            var genericDO1:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback1);
            var genericDO2:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback2);
            this.layoutTargetSprite.addChild(genericDO1);
            this.layoutTargetSprite.addChild(genericDO2);
            
            this.layoutTargetSprite.y = 10;
            
            Assert.assertTrue(triggered1);
            Assert.assertTrue(triggered2);
        }
        
        [Test]
        public function testXSetterMultipleContainers():void
        {
            var triggered:Boolean = false;
            
            function genericTriggeredCallback():void
            {
                triggered = true;
            }
            
            var genericDO:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback);
            var middleLayoutTargetSprite:LayoutTargetSprite = new LayoutTargetSprite();
           
            middleLayoutTargetSprite.addChild(genericDO);
            this.layoutTargetSprite.addChild(middleLayoutTargetSprite);
            
            this.layoutTargetSprite.x = 10;
            
            Assert.assertTrue(triggered);
        }
        
        [Test]
        public function testYSetterMultipleContainers():void
        {
            var triggered:Boolean = false;
            
            function genericTriggeredCallback():void
            {
                triggered = true;
            }
            
            var genericDO:GenericDisplayObject = new GenericDisplayObject(genericTriggeredCallback);
            var middleLayoutTargetSprite:LayoutTargetSprite = new LayoutTargetSprite();
            
            middleLayoutTargetSprite.addChild(genericDO);
            this.layoutTargetSprite.addChild(middleLayoutTargetSprite);
            
            this.layoutTargetSprite.y = 10;
            
            Assert.assertTrue(triggered);
        }
    }
}
import flash.display.Sprite;

internal class GenericDisplayObject extends Sprite
{
    private var _callback:Function;
    
    public function GenericDisplayObject(callback:Function)
    {
        this._callback = callback;    
    }
    
    override public function set x(value:Number):void
    {
        this._callback();    
    }
    
    override public function set y(value:Number):void
    {
        this._callback();
    }
}