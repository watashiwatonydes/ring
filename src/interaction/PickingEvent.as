package interaction
{
	import flash.events.Event;
	
	public class PickingEvent extends Event
	{
		public var x:Number;
		public var y:Number;
		
		public static const PICKING_UPDATE:String = "pickingUpdate"
		public static const PICKING_VERTEX:String = "pickingVertex"
		
		public function PickingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}