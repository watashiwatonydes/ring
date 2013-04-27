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
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
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
		private var _staticVerticesLeft:Vector.<VertexBody>;
		private var _staticVerticesRight:Vector.<VertexBody>;
		private var _connections:Vector.<JointConnection>;
		private var _quads:Vector.<Quad>;
		private var _quadsContainer:Sprite;
		private var _loop:Timer;
		private var _oldMousePosition:Point;
		private var _heatVertex:VertexBody;
		
		public static const COLORS:Array 		= [ 0xFF0000, 0xFFFFFF, 0xFF0000, 0xFFFFFF, 0xFF0000 ];
		private var _debug:TextField;

		private var _picking:MousePicking;
		private var _pickingArea:Sprite;
		private var _drawingArea:Sprite;
		
		
		public static const SOUNDS_DATAS:Vector.<SiONData>	= new Vector.<SiONData>();
		
		private var _driver:SiONDriver;
		private var _presets:SiONPresetVoice;
		private var _voice:SiONVoice;
		
		
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			this.init();		
		}
		
		private function init():void
		{
			_driver = new SiONDriver();
			
			var s0:SiONData = _driver.compile('<c');
			var s1:SiONData = _driver.compile('<<c');
			var s2:SiONData = _driver.compile('c');
			var s3:SiONData = _driver.compile('<c');
			var s4:SiONData = _driver.compile('<<c');
			var s5:SiONData = _driver.compile('c');
			var s6:SiONData = _driver.compile('c');
			
			SOUNDS_DATAS.push( s0, s1, s2, s3, s4, s5, s6 );
			
			_driver.play();
			
			_presets 	= new SiONPresetVoice();
			
			_voice		= _presets[ "default" ][ 0 ];

			
			
			// 
			_stageW2 	= stage.stageWidth * .5;
			_stageH2 	= stage.stageHeight * .5;

			
			_vertices 				= new Vector.<VertexBody>();
			_staticVerticesLeft		= new Vector.<VertexBody>();
			_staticVerticesRight 	= new Vector.<VertexBody>();
			_connections 			= new Vector.<JointConnection>();
			_oldMousePosition 		= new Point( -1, -1 );
			
			_pickingArea 	= new Sprite();
			_pickingArea.graphics.beginFill( 0x111111 );
			_pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( _pickingArea );
			
			_drawingArea 	= new Sprite();
			addChild( _drawingArea );
			_drawingArea.filters = [ new BlurFilter(4, 4, 3) ];
			
			var i:int;
			var n:int = 6;
			var incY:Number = stage.stageHeight / n;
			var v:VertexBody; // dynamic
			var w:VertexBody; // static attach on left
			var z:VertexBody; // static attach on right
			var p:Point = new Point();
			var q:Point = new Point();
			var r:Point = new Point();
			var posY:Number = incY / 2;
			
			
			p.x = _stageW2;
			q.x = _stageW2 - 200;
			r.x = _stageW2 + 200;
			q.y = r.y = p.y = 0;
			
			var topAttach:VertexBody = new VertexBody( p, 1 );
			var topLeftAttach:VertexBody = new VertexBody( p, 1 );
			var topRightAttach:VertexBody = new VertexBody( p, 1 );

			addChild( topAttach );
			addChild( topLeftAttach );
			addChild( topRightAttach );
			
			_vertices.push( topAttach );
			_staticVerticesLeft.push( topAttach );
			_staticVerticesRight.push( topAttach );
			
			for ( i = 0 ; i < n ; i++ )
			{
				p.x = _stageW2;
				p.y = posY;
				q.y = p.y;
				r.y = p.y;
				
				v = new VertexBody( p );
				_vertices.push( v );
				
				w = new VertexBody( q, 1 );
				_staticVerticesLeft.push( w );
				
				z = new VertexBody( r, 1 );
				_staticVerticesRight.push( z );
				
				addChild( v );
				addChild( w );
				addChild( z );
				
				posY += incY; 
			}
			
			p.y = q.y = r.y = stage.stageHeight;
			
			var bottomAttach:VertexBody = new VertexBody( p, 1 );
			var bottomLeftAttach:VertexBody = new VertexBody( q, 1 );
			var bottomRightAttach:VertexBody = new VertexBody( r, 1 );
			
			addChild( bottomAttach );
			addChild( bottomLeftAttach );
			addChild( bottomRightAttach );
			
			_vertices.push( bottomAttach );
			_staticVerticesLeft.push( bottomLeftAttach );
			_staticVerticesRight.push( bottomRightAttach );
			
			_picking = new MousePicking( _pickingArea, _vertices );
			
			var ln:int = _vertices.length;
			var co:JointConnection;
			var co2:JointConnection;
			var co3:JointConnection;
			var a:VertexBody;
			var b:VertexBody;
			var l:VertexBody;
			var ri:VertexBody;
			
			for ( i = 0 ; i < ln - 1; i++ )
			{
				a 	= _vertices[i]
				b 	= _vertices[i+1]
					
				co 	= new JointConnection( JointConnection.DISTANCE_JOINT, a, b, 1, .01 );  // > 2 for consistency
				_connections.push( co );
				addChild( co );
			}

			for ( i = 0 ; i < ln - 1; i += 1 )
			{
				a 	= _vertices[i]
				b 	= _vertices[i+1]
				l 	= _staticVerticesLeft[i+1]
				ri 	= _staticVerticesRight[i+1]
				
				co2 	= new JointConnection( JointConnection.DISTANCE_JOINT, l, b, 2, .1 );
				_connections.push( co2 );
				addChild( co2 );
				co2.draw();
				
				co3 	= new JointConnection( JointConnection.DISTANCE_JOINT, b, ri, 2, .1 );
				_connections.push( co3 );
				addChild( co3 );
				co3.draw();
			}
			
			
			_loop = new Timer( 30 );
			_loop.addEventListener(TimerEvent.TIMER, update);
			_loop.start();
			
			
			_debug = new TextField();
			_debug.defaultTextFormat = new TextFormat( "arial", 12, 0xffffff );
			addChild( _debug );
		}	
		
		protected function update(event:Event):void
		{
			Config.WORLD.Step( Config.DT, 6, 6 );
			Config.WORLD.ClearForces();
			
			var v:VertexBody;
			var p:Point;
			var d:Number;
			var i:int = 0;
			var vl:b2Vec2;
			var ln:int = _vertices.length;
			
			for ( i = 0 ; i < ln ; i++ )
			{
				v = _vertices[ i ];
				v.update();
				
				if( v.bodyType == b2Body.b2_dynamicBody )
				{
					p 	= v.pixelCoordinates;
					vl 	= v.body.GetLinearVelocity();
					
					if (Math.abs(p.x - _stageW2) > 2)
					{
						_driver.sequenceOn( SOUNDS_DATAS[ i - 1 ], _voice, 0, 0, 1, 1 );
					}
					
					//v.draw( 20, 0xff0000, 1 );
					//v.alpha 	+= ( 0 - v.alpha ) * .05;
					//v.scaleX	+= ( 0 - v.scaleX ) * .05;
					//v.scaleY 	+= ( 0 - v.scaleY ) * .05;
				}
			}
			
			drawRope();
			
			if ( _picking )
				_picking.draw();
		}
		
		private function drawRope():void
		{
			
			if (_loop.currentCount % 2 == 0)
				_drawingArea.graphics.clear();
			
			_drawingArea.graphics.lineStyle( .1, 0xffffff, .8 );
			
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
			
			
		}
		
	}
}