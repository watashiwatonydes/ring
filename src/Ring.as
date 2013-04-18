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
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
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
	
	[SWF( widthPercent="100", heightPercent="100", backgroundColor=0x000000, frameRate="60" )]
	public class Ring extends Sprite
	{
		private var _stageW2:int;
		private var _vertices:Vector.<VertexBody>;
		private var _connections:Vector.<JointConnection>;
		private var _quads:Vector.<Quad>;
		private var _quadsContainer:Sprite;
		private var _loop:Timer;
		private var _picking:MousePicking;
		
		// public static const COLORS:Array 		= [ 0x1369AB, 0x7108A0, 0x00940E, 0xFFD702, 0xA02F09 ];
		// public static const COLORS:Array 		= [ 0xE82181, 0xFFFFFF ];
		public static const COLORS:Array 		= [ 0x124D6B, 0x31526B, 0x008FBD, 0x44C9E0, 0xC2DADB ];
		
		
		public static const SOUNDS_DATAS:Vector.<SiONData>	= new Vector.<SiONData>();
		
		private var _driver:SiONDriver;
		private var _presets:SiONPresetVoice;
		private var _voice:SiONVoice;
		private var _drawingArea:Shape;
		
		private const BLUR_FILTER:BlurFilter = new BlurFilter( 2, 2, 3 );
		private var DRAW_BUFFER:BitmapData;
		private var CANVAS:Bitmap;
		private var _capture:Timer;
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			
			this.init();		
		}
		
		private function init():void
		{
			_stageW2 	= stage.stageWidth * .5;

			_driver = new SiONDriver();

			var s0:SiONData = _driver.compile('>cg');
			var s1:SiONData = _driver.compile('>c');
			var s2:SiONData = _driver.compile('cg');
			var s3:SiONData = _driver.compile('<c');
			var s4:SiONData = _driver.compile('<<c');
			var s5:SiONData = _driver.compile('c');
			var s6:SiONData = _driver.compile('c');
			
			SOUNDS_DATAS.push( s0, s1, s2, s3, s4, s5, s6 );
			
			_driver.play();
			
			_presets 	= new SiONPresetVoice();
			
			_voice		= _presets[ "default" ][ 0 ];
			
			// 
			
			var pickingArea:Sprite 	= new Sprite();
			pickingArea.graphics.beginFill( 0x000000 );
			pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( pickingArea );
			
			
			
			_vertices 		= new Vector.<VertexBody>();
			_connections 	= new Vector.<JointConnection>();
			_quads 			= new Vector.<Quad>();
			
			
			var i:int;
			var n:int = 7;
			var incY:Number = stage.stageHeight / n;
			var v:VertexBody;
			var p:Point = new Point();
			var posY:Number = incY / 2;

			p.x = _stageW2;
			p.y = 0;
			var topAttach:VertexBody = new VertexBody( p, 1 );
			addChild( topAttach );
			_vertices.push( topAttach );
			
			for ( i = 0 ; i < n ; i++ )
			{
				p.x = _stageW2;
				p.y = posY;
				
				v = new VertexBody( p );
				_vertices.push( v );
				
				addChild( v );
				posY += incY; 
			}
			
			p.y = stage.stageHeight;
			var bottomAttach:VertexBody = new VertexBody( p, 1 );
			addChild( bottomAttach );
			_vertices.push( bottomAttach );
			
			var ln:int = _vertices.length;
			var co:JointConnection;
			var a:VertexBody;
			var b:VertexBody;
			for ( i = 0 ; i < ln - 1; i++ )
			{
				a 	= _vertices[i]
				b 	= _vertices[i+1]
				co 	= new JointConnection( JointConnection.DISTANCE_JOINT, a, b, 8, 1 );
				_connections.push( co );
				addChild( co );
			}
			
			_picking = new MousePicking( pickingArea, _vertices );
			
			// 
			DRAW_BUFFER 		= new BitmapData( stage.stageWidth, stage.stageHeight, true, 0x00ffffff )
			CANVAS 				= new Bitmap( DRAW_BUFFER );
			CANVAS.bitmapData 	= DRAW_BUFFER;
			CANVAS.x 			= 0;
			CANVAS.y 			= 0;
			addChild( CANVAS );	
			
			_quadsContainer 	= new Sprite();
			addChild( _quadsContainer );

			_drawingArea			= new Shape();
			addChild( _drawingArea );
			
			_loop = new Timer( 25 );
			_loop.addEventListener(TimerEvent.TIMER, update);
			_loop.start();
			

			_capture = new Timer( 2000 );
			_capture.addEventListener(TimerEvent.TIMER, takeSnapshot);
			_capture.start();
			
			// Apply random force to the centered vertex
			var bodyIndex:int 	= _vertices.length / 2;
			var b1:b2Body 		= _vertices[ bodyIndex ].body;
			var vx:Number 		= -10 / Config.WORLDSCALE;
			var f1:b2Vec2		= new b2Vec2( vx, 0 );
			var fap1:b2Vec2		= b1.GetWorldCenter();
			b1.ApplyImpulse( f1, fap1 );
		}		
		
		protected function takeSnapshot(event:TimerEvent):void
		{
			DRAW_BUFFER.draw( _quadsContainer );
		}
		
		protected function update(event:Event):void
		{
			Config.WORLD.Step( Config.DT, 6, 6 );
			Config.WORLD.ClearForces();
			
			var v:VertexBody;
			var p:Point;
			var d:Number;
			var i:int = 0;
			var ln:int = _vertices.length;
			
			
			for ( i = 0 ; i < ln ; i++ )
			{
				v = _vertices[ i ];
				v.update();
				
				if( v.bodyType == b2Body.b2_dynamicBody )
				{
					p 	= v.pixelCoordinates;
					d 	= p.x - _stageW2;
					
					if ( Math.abs( d ) < 1 )
					{
						v.draw( 15, 0xffffff, .5 );
						
						v.scaleX = v.scaleY = 3;
						v.alpha = 1;
						
						if ( _loop.currentCount > 10 )
						{
							_driver.sequenceOn( SOUNDS_DATAS[ i - 1 ], _voice, 0, 0, 1, 1 );
						}
						
						this.collide( p, d );
					}
					else 
					{
						v.draw( 10, 0xff0000, .5 );
						v.alpha 	+= ( 0 - v.alpha ) * .05;
						v.scaleX	+= ( 0 - v.scaleX ) * .05;
						v.scaleY 	+= ( 0 - v.scaleY ) * .05;
					}
				}
			}
			
			var q:Quad;
			for each ( q in _quads )
			{
				q.draw();
			}

			
			_picking.draw();
			
			drawRope();
		}
		
		private function collide(p:Point, d:Number):void
		{
			var point:Point 	= p;	
			
			var quad:Quad 		= createQuadAtPoint( point );
			
			var colorIndex:int	= Math.random() * COLORS.length;
			
			quad.color			= COLORS[ colorIndex ];
			
			var ln:int 			= _quads.length;
			
			var bodyIndex:int 	= Math.random() * 5;
			
			var b1:b2Body 		= quad.bodies[ bodyIndex ].body;
			
			var vx:Number = 0, vy:Number = 0;
			vx = (Math.random() * 4) / Config.WORLDSCALE;
			vy = (Math.random() * 4) / Config.WORLDSCALE;
			
			
			var f1:b2Vec2		= new b2Vec2( vx, vy );
			var fap1:b2Vec2		= b1.GetWorldCenter();
			
			b1.ApplyImpulse( f1, fap1 );
			
			if ( ln > 60 )
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
		private function drawRope():void
		{
			_drawingArea.graphics.clear();
			
			_drawingArea.graphics.lineStyle( 1, 0xffffff, 1 );

			var ln:int 		= _vertices.length;
			_drawingArea.graphics.moveTo( _vertices[ 0 ].x, _vertices[ 0 ].y );
			
			var cpl:Point = new Point();
			var i:int;
			for ( i = 1 ; i < ln - 2 ; i++)
			{
				cpl.x = (_vertices[ i ].x + _vertices[ i+1 ].x) * .5;
				cpl.y = (_vertices[ i ].y + _vertices[ i+1 ].y) * .5;
				
				_drawingArea.graphics.curveTo( _vertices[ i ].x, _vertices[ i ].y, cpl.x, cpl.y );
			}
			
			_drawingArea.graphics.curveTo( _vertices[ i ].x, _vertices[ i ].y, _vertices[ i + 1 ].x, _vertices[ i + 1 ].y );
			_drawingArea.graphics.endFill();
			
			_drawingArea.filters = [ BLUR_FILTER ];
		}
		
	}
}