package render
{
	import mx.collections.ArrayCollection;
	import mx.controls.CheckBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridListData;
	
	public class hdRender extends CheckBox
	{
		/* public var _headerFlag : Boolean = false; 
		public function hdRender()
		{
			super();
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler) ;
		}
		
		 private function mouseClickHandler(event:Event):void{
			if(DataGrid(owner).dataProvider is ArrayCollection){
				var dgData : ArrayCollection = DataGrid(owner).dataProvider as ArrayCollection ;
				
				if(listData != null && listData.rowIndex == 0){
					_headerFlag = selected ;
					
					for(var i : uint = 0 ; i < dgData.length ; i++){
						dgData[i][DataGridListData(listData).dataField] = _headerFlag ;
					}
				}else{
					dgData[listData.rowIndex-1][DataGridListData(listData).dataField] = selected; 
				}
				
				DataGrid(owner).invaildateList() ;
			}
		} 
		
		public override function set data(value:Object):void{
			this.data=value; 
			
			if(data == null) return ;
			
			if(listData.rowIndex != 0){
				_data = value[DataGridListData(listData).dataField];
				selected = _data; 
			}else{
				selected = _headerFlag
			}
		}
		
		public override function get data():Object{
			return _data; 
		} */
	}
}