package
{
	import flash.events.Event;
	import flash.geom.Point;
	import physics.VertexBody;
	
	public class ChordEvent extends Event
	{
		public static const BENT:String = "bent";
		public static const VIBRATE:String = "vibrate";
		public static const RELEASE:String = "release";
		
		
		public var noteIndex:int;
		public var chordIndex:int;
		public var pixelCoordinates:Point;
		public var vertex:VertexBody;
		
		public function ChordEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}