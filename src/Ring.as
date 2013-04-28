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
		
		public static const SOUNDS_DATAS:Vector.<SiONData>	= new Vector.<SiONData>();
		
		private var _driver:SiONDriver;
		private var _presets:SiONPresetVoice;
		private var _voice:SiONVoice;
		private var _lastUpdateCounter:int = 0;
		
		
		public function Ring()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align		= StageAlign.TOP_LEFT;
			
			this.init();		
		}
		
		private function init():void
		{
			// filters = [ new BlurFilter( 4, 4, 2 ) ];
			
			_driver = new SiONDriver();
			
			var s0:SiONData 	= _driver.compile('<c');
			var s1:SiONData 	= _driver.compile('c');
			var s2:SiONData 	= _driver.compile('<<c');
			var s3:SiONData 	= _driver.compile('c');
			var s4:SiONData 	= _driver.compile('<c');
			var s5:SiONData 	= _driver.compile('c');
			var s6:SiONData 	= _driver.compile('<c');
			var s7:SiONData 	= _driver.compile('c');
			var s8:SiONData 	= _driver.compile('<<c');
			var s9:SiONData 	= _driver.compile('c');
			var s10:SiONData 	= _driver.compile('<c');
			
			SOUNDS_DATAS.push( s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10 );
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
				var ch:Chord 	= new Chord( offsetX );
				addChild( ch );
				ch.addEventListener( ChordEvent.UPDATE, onChordUpdated );
				_chords.push( ch );
				
				vertices	= ch.vertices;
				pick		= new MousePicking( _pickingArea, vertices );
				_pickings.push( pick );
				
				offsetX -= 100;
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
			
			if ( diff < 3 )
				return;
			else
			{
				_driver.sequenceOn( SOUNDS_DATAS[ event.chordIndex ], _voice, 0, 0, 1, 1 );	
				_lastUpdateCounter 	= c;
			}
			
		}
				
	}
}