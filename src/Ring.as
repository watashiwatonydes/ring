package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import geometry.Quad;
	
	import interaction.MousePicking;
	
	import org.si.sion.SiONData;
	import org.si.sion.SiONDriver;
	import org.si.sion.SiONVoice;
	import org.si.sion.utils.SiONPresetVoice;
	import org.si.sound.namespaces._sound_object_internal;
	
	import physics.JointConnection;
	import physics.VertexBody;
	
	[SWF( widthPercent="100", heightPercent="100", backgroundColor=0x000000, frameRate="50" )]
	public class Ring extends Sprite
	{
		private var _stageW2:int;
		private var _stageH2:int;
		private var _vertices:Vector.<VertexBody>;
		private var _connections:Vector.<JointConnection>;
		private var _quads:Vector.<Quad>;
		private var _quadsContainer:Sprite;
		private var _loop:Timer;
		private var _picking:MousePicking;
		
		public static const COLORS:Array 		= [ 0xFF0000, 0xFFFFFF, 0xFF0000, 0xFFFFFF, 0xFF0000 ];

		private var _pickingArea:Sprite;
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			this.init();		
		}
		
		private function init():void
		{
			_stageW2 	= stage.stageWidth * .5;
			_stageH2 	= stage.stageHeight * .5;

			
			_pickingArea 	= new Sprite();
			_pickingArea.graphics.beginFill( 0x000000 );
			_pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( _pickingArea );
			
			_vertices 		= new Vector.<VertexBody>();
			_connections 	= new Vector.<JointConnection>();
			_quads 			= new Vector.<Quad>();
			
			_quadsContainer = new Sprite();
			addChild( _quadsContainer );

			_loop = new Timer( 30 );
			_loop.addEventListener(TimerEvent.TIMER, update);
			_loop.start();
			
			

			// 
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}	
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			switch( event.keyCode )
			{
				case Keyboard.A:
					
					var quad:Quad = createQuadAtPoint( new Point(_stageW2, _stageH2) );
					
					quad.expand();
					
					break;
				
				case Keyboard.B:
					
					_picking = new MousePicking( _pickingArea, _quads[0].bodies );
					
					break;
			}
		}
		
		protected function update(event:Event):void
		{
			Config.WORLD.Step( Config.DT, 6, 6 );
			Config.WORLD.ClearForces();
			
			var q:Quad;
			for each ( q in _quads )
			{
				q.draw();
			}

			
		}
		
		private function createQuadAtPoint( p:Point ):Quad
		{
			var points:Vector.<Point> = new Vector.<Point>(4, true);
			
			var _loc1:Number 	= p.x;
			var _loc2:Number 	= p.y;
			
			var _loc3:int		= 30;
			var _loc4:int		= 30;
			
			points[0] = new Point( _loc1 , _loc2 );
			points[1] = new Point( _loc1 + _loc3, _loc2 );
			points[2] = new Point( _loc1 + _loc3, _loc2 + _loc4 );
			points[3] = new Point( _loc1, _loc2 + _loc4 );
			
			var quad:Quad = new Quad( points );
			_quadsContainer.addChild( quad );	
			
			_quads.push( quad );
			
			return quad;
		}
		
	}
}