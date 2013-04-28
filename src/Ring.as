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
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import geometry.Quad;
	
	import interaction.MousePicking;
	import interaction.PickingEvent;
	
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
		
		private var _loop:Timer;

		private var _chords:Vector.<Chord>;
		private var _pickings:Vector.<MousePicking>;
		private var _pickingArea:Sprite;
		
		private const SOUNDS_DATAS:Vector.<Vector.<SiONData>> = new Vector.<Vector.<SiONData>>();
		
		private var _driver:SiONDriver;
		private var _presets:SiONPresetVoice;
		private var _voice:SiONVoice;
		private var _lastUpdateCounter:int = 0;
		private var _lastVx:Number;
		private var _lastVy:Number;
		
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			this.init();		
		}
		
		private function init():void
		{
			filters = [ new BlurFilter( 4, 4, 3 ) ];
			
			_driver = new SiONDriver();
			
			SOUNDS_DATAS[0]		= new Vector.<SiONData>()
			SOUNDS_DATAS[1]		= new Vector.<SiONData>()
			SOUNDS_DATAS[2]		= new Vector.<SiONData>()
			
			var s00:SiONData 	= _driver.compile('>cg');
			var s01:SiONData 	= _driver.compile('>c');
			var s02:SiONData 	= _driver.compile('cg');
			var s03:SiONData 	= _driver.compile('c');
			var s04:SiONData 	= _driver.compile('<c');
			
			SOUNDS_DATAS[0].push( s00, s01, s02, s03, s04 );
			
			var s10:SiONData 	= _driver.compile('ca');
			var s11:SiONData 	= _driver.compile('b');
			var s12:SiONData 	= _driver.compile('ad');
			var s13:SiONData 	= _driver.compile('>d');
			var s14:SiONData 	= _driver.compile('>a');
			
			SOUNDS_DATAS[1].push( s10, s11, s12, s13, s14 );
			
			var s20:SiONData 	= _driver.compile('g');
			var s21:SiONData 	= _driver.compile('f');
			var s22:SiONData 	= _driver.compile('e');
			var s23:SiONData 	= _driver.compile('>e');
			var s24:SiONData 	= _driver.compile('>>e');
			
			SOUNDS_DATAS[2].push( s20, s21, s22, s23, s24 );
			
			_driver.play();
			
			_presets 	= new SiONPresetVoice();
			_voice		= _presets[ "default" ][ 0 ];

			// 
			_stageW2 	= stage.stageWidth * .5;
			_stageH2 	= stage.stageHeight * .5;

			_pickingArea 	= new Sprite();
			_pickingArea.graphics.beginFill( 0x111111 );
			_pickingArea.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			addChild( _pickingArea );
			
			_chords 	= new Vector.<Chord>();
			_pickings 	= new Vector.<MousePicking>();
			
			var i:int;
			var offsetX:Number = _stageW2;
			var vertices:Vector.<VertexBody>;
			var pick:MousePicking;
			
			for ( i = 0 ; i < 3 ; i++ )
			{
				var ch:Chord 	= new Chord( offsetX, i );
				addChild( ch );
				ch.addEventListener( ChordEvent.UPDATE, onChordUpdated );
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
		}
		
		protected function onChordUpdated(event:ChordEvent):void
		{
			var c:int 			= _loop.currentCount;
			var diff:int 		= Math.abs( c - _lastUpdateCounter ); 
			
			if ( diff < 10 )
				return;
			else
			{
				_driver.sequenceOn( SOUNDS_DATAS[ event.chordIndex ][ event.noteIndex ], _voice, 0, 0, 1, 1 );	
				_lastUpdateCounter 	= c;
				
				
				
			}
			
		}
		
		protected function onMousePickingUpdated(event:PickingEvent):void
		{
			_lastVx = event.x;
			_lastVy = event.y;
		}
		
				
	}
}