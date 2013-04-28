package
{
	import flash.events.Event;
	
	public class ChordEvent extends Event
	{
		public static const UPDATE:String = "update";
		public var chordIndex:int;
		
		public function ChordEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}