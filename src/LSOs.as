package
{
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	public class LSOs
	{
		private var lsosE:SharedObject;
		public function LSOs()
		{
		}
		public function lsosWrite(lsos:SharedObject,diskFg:Boolean = false):void{
			lsosE= lsos;
			try{
				var flushResult:String = lsosE.flush();

				if(flushResult == SharedObjectFlushStatus.PENDING){
					lsosE.addEventListener(NetStatusEvent.NET_STATUS, onStatus,false,0,true);
				}
				else if(flushResult == SharedObjectFlushStatus.FLUSHED)
				{
					trace("[lsos  저장완료 ]");					
				}
			}catch (e:Error){
				Security.showSettings(SecurityPanel.LOCAL_STORAGE); //허용하도록 사용자에게 물어보기
			}
		}
		
		//로컬공유객체 쓰기 사용자 허가 /거부 시 핸들러
		private function onStatus(e:NetStatusEvent):void{
			if(e.info.code == "SharedObject.Flush.Success"){
				//사용자허용
				var flushResult:String = lsosE.flush();
			}else if(e.info.code == "SharedObject.Flush.Failed"){
				//사용자거부
			}
			lsosE.removeEventListener(NetStatusEvent.NET_STATUS, onStatus);	
		}
	}
}