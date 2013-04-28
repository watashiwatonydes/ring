package
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ChordEvent extends Event
	{
		public static const UPDATE:String = "update";
		public var noteIndex:int;
		public var chordIndex:int;
		public var pixelCoordinates:Point;
		
		public function ChordEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}