package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import geometry.Quad;
	
	import interaction.MousePicking;
	import interaction.PickingEvent;
	
	import physics.VertexBody;
	
	[SWF( widthPercent="100", heightPercent="100", backgroundColor=0x000000, frameRate="50" )]
	public class Ring extends Sprite
	{
		private var _stageW2:int;
		private var _stageH2:int;
		
		private var _loop:Timer;

		private var _chords:Vector.<Chord>;
		private var _pickings:Vector.<MousePicking>;
		private var _pickingArea:Sprite;
		
		private const COLORS:Array = [ 0x1369AB, 0x7108A0, 0x00940E, 0xFFD702, 0xA02F09 ];
		public static const BLUR:BlurFilter 	= new BlurFilter( 4, 4, 1 );
		private var CANVAS:BitmapData;
		private var HOLDER:Bitmap;
		
		private var _lastVx:Number;
		private var _lastVy:Number;
		private var _quads:Vector.<Quad>;
		private var _quadsContainer:Sprite;
		private var _drawTimer:Timer;
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			this.init();		
		}
		
		private function init():void
		{
			// 
			_stageW2 	= stage.stageWidth * .5;
			_stageH2 	= stage.stageHeight * .5;

			
			_pickingArea 	= new Sprite();
			_pickingArea.graphics.beginFill( 0x000000 );
			_pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( _pickingArea );

			_quadsContainer 	= new Sprite();
			addChild( _quadsContainer );
			
			_chords 	= new Vector.<Chord>();
			_pickings 	= new Vector.<MousePicking>();
			_quads 		= new Vector.<Quad>();
			
			var i:int;
			var offsetX:Number = _stageW2 - 200;
			var vertices:Vector.<VertexBody>;
			var pick:MousePicking;
			
			for ( i = 0 ; i < 5 ; i++ )
			{
				var ch:Chord 	= new Chord( offsetX, i );
				addChild( ch );
				ch.addEventListener( ChordEvent.BENT, onChordBent );
				_chords.push( ch );
				
				vertices	= ch.vertices;
				pick		= new MousePicking( _pickingArea, vertices );
				pick.addEventListener(PickingEvent.PICKING_UPDATE, onMousePickingUpdated);
				_pickings.push( pick );
				
				offsetX += 100;
			}
			
			_loop = new Timer( 30 );
			_loop.addEventListener(TimerEvent.TIMER, update);
			_loop.start();
		}			
		
		protected function onDraw(event:TimerEvent):void
		{
			CANVAS.draw( _quadsContainer );
		}
		
		protected function update( event:TimerEvent ):void
		{
			Config.WORLD.Step( Config.DT, 6, 6 );
			Config.WORLD.ClearForces();
			
			var i:int = 0;
			var chord:Chord;
			var picking:MousePicking;
			var ln:int = _chords.length;
			
			for ( i = 0 ; i < ln ; i++ )
			{
				chord = _chords[ i ];
				picking = _pickings[ i ];
				
				chord.update( event );
				picking.update();
			}
			
			var q:Quad;
			for each ( q in _quads )
			{
				q.draw( event );
			}
		}
		
		protected function onChordBent(event:ChordEvent):void
		{
			collide( event.pixelCoordinates );
		}
		
		protected function onMousePickingUpdated(event:PickingEvent):void
		{
			_lastVx = ( event.x > 3 ) ? 3 : event.x;
			_lastVy = ( event.y > 3 ) ? 3 : event.y;
			
			_lastVx = ( event.x < .3 ) ? .3 : event.x;
			_lastVy = ( event.y < .3 ) ? .3 : event.y;
		}
		
		private function collide(p:Point):void
		{
			var point:Point 	= p;	
			
			var quad:Quad 		= createQuadAtPoint( point );
			
			var colorIndex:int	= Math.random() * COLORS.length;
			
			quad.color			= COLORS[ colorIndex ];
			
			var ln:int 			= _quads.length;
			
			var bodyIndex:int 	= Math.random() * 5;
			
			var b1:b2Body 		= quad.bodies[ bodyIndex ].body;
			
			var f1:b2Vec2		= new b2Vec2( _lastVx / Config.WORLDSCALE, _lastVy / Config.WORLDSCALE );
			var fap1:b2Vec2		= b1.GetWorldCenter();
			
			b1.ApplyImpulse( f1, fap1 );
			
			if ( ln > 20 )
			{
				var q:Quad = _quads.shift();
				q.destroy();
				_quadsContainer.removeChild( q );
			}
			
		}
		
		private function createQuadAtPoint( p:Point ):Quad
		{
			var points:Vector.<Point> = new Vector.<Point>(4, true);
			
			var _loc1:Number 	= p.x;
			var _loc2:Number 	= p.y - 5;
			
			var _loc3:int		= 20 + Math.random() * Math.random() * 20;
			
			points[0] = new Point( _loc1 , _loc2 );
			points[1] = new Point( _loc1 + _loc3, _loc2 );
			points[2] = new Point( _loc1 + _loc3, _loc2 + _loc3 );
			points[3] = new Point( _loc1, _loc2 + _loc3 );
			
			var quad:Quad = new Quad( points );
			_quadsContainer.addChild( quad );	
			
			_quads.push( quad );
			
			return quad;
		}

				
	}
}