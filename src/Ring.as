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

			_vertices 			= new Vector.<VertexBody>();
			_connections 		= new Vector.<JointConnection>();
			_oldMousePosition 	= new Point( -1, -1 );
			
			_pickingArea 	= new Sprite();
			_pickingArea.graphics.beginFill( 0x111111 );
			_pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( _pickingArea );
			
			_drawingArea 	= new Sprite();
			addChild( _drawingArea );
			
			
			var p:Point = new Point();
			p.x = _stageW2;
			p.y = 00;
			var topAttach:VertexBody = new VertexBody( p, 1 );
			addChild( topAttach );
			_vertices.push( topAttach );
			
			p.y = stage.stageHeight;
			
			var bottomAttach:VertexBody = new VertexBody( p, 1 );
			addChild( bottomAttach );
			_vertices.push( bottomAttach );
			
			_loop = new Timer( 30 );
			_loop.addEventListener(TimerEvent.TIMER, update);
			_loop.start();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			
			
			_debug = new TextField();
			_debug.defaultTextFormat = new TextFormat( "arial", 12, 0xffffff );
			addChild( _debug );
		}	
		
		protected function onMouseMoveHandler(event:MouseEvent):void
		{
			var currentMouseX:Number = event.stageX;
			
			_debug.text = currentMouseX + ":" + _oldMousePosition.x;
			
			if (currentMouseX <= 0 || currentMouseX >= stage.stageWidth)
			{
				_oldMousePosition.x = -1;
				return;
			}
			
			if (_oldMousePosition.x != -1)
			{
				if ( _oldMousePosition.x >= _stageW2 && currentMouseX <= _stageW2 || 
					 _oldMousePosition.x <= _stageW2 && currentMouseX >= _stageW2 )
				{
					
					if ( _heatVertex == null )
					{
						trace ( "A cross the line" );
				 		_heatVertex 	= new VertexBody( new Point(currentMouseX, event.stageY) );

						addChild( _heatVertex );
						_vertices.splice( 1, 0, _heatVertex );
						
						var jc0:JointConnection = new JointConnection( JointConnection.DISTANCE_JOINT, _vertices[0], _heatVertex, 16, .01);
						var jc1:JointConnection = new JointConnection( JointConnection.DISTANCE_JOINT, _heatVertex, _vertices[2], 16, .01 );
						
						_connections.push( jc0, jc1 );
						
						_picking = new MousePicking( _heatVertex );
					}
					
				}
			}
			
			
			_oldMousePosition.x = event.stageX;
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
					
					v.draw( 20, 0xff0000, 1 );
					v.alpha 	+= ( 0 - v.alpha ) * .05;
					v.scaleX	+= ( 0 - v.scaleX ) * .05;
					v.scaleY 	+= ( 0 - v.scaleY ) * .05;
				}
			}
			
			drawRope();
			
			if ( _picking )
				_picking.draw();
		}
		
		private function drawRope():void
		{
			_drawingArea.graphics.clear();
			
			_drawingArea.graphics.lineStyle( .1, 0xffffff, 1 );

			var ln:int 			= _vertices.length;
			var cpl:Point = new Point();
			
			if ( ln > 2 )
			{
				var upperBounds:int = ln - 2
				
				_drawingArea.graphics.moveTo( _vertices[ 0 ].x, _vertices[ 0 ].y );
				
				var x1:Number = _vertices[ 1 ].x * 2 - (_vertices[ 0 ].x + _vertices[ 2 ].x) * .5;
				var y1:Number = _vertices[ 1 ].y * 2 - (_vertices[ 0 ].y + _vertices[ 2 ].y) * .5;
				
				_drawingArea.graphics.curveTo( x1, y1, _vertices[ 2 ].x, _vertices[ 2 ].y );
			}
			else
			{
				_drawingArea.graphics.moveTo( _vertices[ 0 ].x, _vertices[ 0 ].y );
				
				cpl.x = (_vertices[ 0 ].x + _vertices[ 1 ].x) * .5;
				cpl.y = (_vertices[ 0 ].y + _vertices[ 1 ].y) * .5;
				
				_drawingArea.graphics.curveTo( cpl.x, cpl.y, _vertices[ 1 ].x, _vertices[ 1 ].y );
			}
			
		}
		
	}
}