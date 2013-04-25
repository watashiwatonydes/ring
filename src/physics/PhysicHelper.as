package physics
{
	import flash.geom.Point;
	
	import geometry.Delaunay;

	public class PhysicHelper
	{
		
		private static var ConnectionsMap:Object = new Object();
		private static var _connectionType:uint;
		
		public static function ConnectBodies( bodies:Vector.<VertexBody>, connectionType:uint = 2 ):Vector.<JointConnection>
		{
			_connectionType = connectionType;
			
			var ln:int = bodies.length; 
			if ( ln < 2 )
				throw new Error( "Parameter bodies must contains at least 2 VerticeBody instances" );
			
			var buffer:Vector.<JointConnection> 	= new Vector.<JointConnection>();
			

			var b0:VertexBody, b1:VertexBody;
			var conn:JointConnection;
			
			b0 		= bodies[ 0 ];
			b1 		= bodies[ 1 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );

			b0 		= bodies[ 0 ];
			b1 		= bodies[ 4 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			b0 		= bodies[ 0 ];
			b1 		= bodies[ 3 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			///
			b0 		= bodies[ 1 ];
			b1 		= bodies[ 2 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			b0 		= bodies[ 1 ];
			b1 		= bodies[ 4 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			///
			b0 		= bodies[ 2 ];
			b1 		= bodies[ 3 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			b0 		= bodies[ 2 ];
			b1 		= bodies[ 4 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			///
			b0 		= bodies[ 3 ];
			b1 		= bodies[ 4 ];
			conn 	= new JointConnection( _connectionType, b0, b1, 2, .1, 5 );
			buffer.push( conn );
			
			return buffer;
		}
		
		
		
		
	}
}