/******************************************************************************
							Multi Header Grid
														Create by Wogus
******************************************************************************/
// $$$$ 20070118	박재현 : 멀티헤더부분 수정
// $$$$ 20070124	박재현 : Merge 관련 수정	            
// $$$$ 20070423	박재현 : Flex 2.0.1 버전업 수정

// ActionScript file
package mycomp
{
	import mx.controls.*;
	import mx.containers.*;
	import mx.controls.dataGridClasses.*;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.accessibility.DataGridAccImpl;
	import mx.graphics.*;
	import flash.events.Event;
	
	import mx.core.FlexSprite;

	import mx.collections.IList;
    import mx.events.DataGridEvent;
    import mx.collections.*;
    import mx.styles.StyleManager;
   	import mx.binding.utils.*;
   	import mx.charts.chartClasses.StackedSeries;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.binding.*;
	import mx.utils.ArrayUtil;

		// DataGrid 원판 복사
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.events.DataGridEventReason;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import flash.geom.Point;
	import mx.core.UIComponent;
	import mx.styles.ISimpleStyleClient;
	import flash.display.Graphics;

	import mx.controls.listClasses.*;
	import mx.core.IUIComponent;
	
	use namespace mx_internal;

	public class MHGrid extends DataGrid implements IUIComponent
	{
		private var m_arMHbutton:Array;						// MultiHeader 일때 담을 button 배열
		private var m_arHbutton:Array;						// SingleHeader 일때 담을 button 배열

		private var m_headerColor:Object;					// header Color    ex> [0xffffff, 0xccccccc]


		// DataGrid 원판 복사
	    private var resizeCursorID:int = CursorManager.NO_CURSOR;		// resizeCursor ID
		private var resizingColumnNow:DataGridColumn;					// Resize되는 Column

		private var ResizeStartX:Number;					// Resize 시작 위치
		private var ResizeMinX:Number;						// Resize 최소값

	    private var resizeGraphic:IFlexDisplayObject;		// 

		private var inEndEdit:Boolean = false;				//
		private var dontEdit:Boolean = false;				//
		private var losingFocus:Boolean = false;			//
		
	    private var _columns:Array; 						// 실제 DataGrid 에서 관리하는 Column 배열

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 수정
		private var separators:Array;						// separator 배열
		

	    [Bindable]
		private var multiHeader:Array;						// Multiheader 일때 상단에 들어갈 텍스트 배열
	    [Bindable]
		private var arrColumn:Array;						// MHGird 에서 관리하는  Column 배열

		private var	m_bMultiHeader:Boolean = false;			// Multiheader 상태 확인 Flag
		private var m_bEnableMerge:Boolean = false;			// Merge 상태 확인 Flag

		public function MHGrid():void
		{
			super();

			separators = new Array();

			m_arHbutton = new Array();
			m_arMHbutton = new Array();

			addEventListener("render", OnmyResize);

			m_headerColor = [0xffffff, 0xccccccc];
			
		}

		// 초기화 
		// 버튼 배열 초기화
		override public function initialize():void
		{
			super.initialize();
		}
/*
		override protected function createChildren():void 
		{
			super.createChildren();
		}
*/
		// Merge 여부 세팅
		public function set enableMerge(value:Boolean):void
		{
			m_bEnableMerge = value;
		}

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 삭제
//		private function OnHeaderClick(event:Event):void


		// Column Index 구하는 함수
		private function findColIndex(label:String):Number
		{
			var j:Number;
			
	        for (j = 0; j < this.columnCount; j++)
	    	{
	    		if ( this.columns[j].dataField == label ) break;
    		}

			return j;
		}

		// Column Header 에  버튼을 지우고 새로 그리는 함수
		private function myCreateButton():void 
		{
			var m_button:Button;
			var i:Number = 0;
			var j:Number = 0;
			this.headerHeight = 40;
			
			var nMultiCnt:Number = 0;

			var deleteItem:Array = new Array();
			
			if ( listContent == null )
				createChildren();


			while ( (m_button =  m_arMHbutton.pop()) != null )
			{
				deleteItem.push(m_button);
			}

			while ( (m_button =  m_arHbutton.pop()) != null )
			{
				deleteItem.push(m_button);
			}

			if ( multiHeader == null ) 
			{
				this.headerHeight = 25;
			}
			

			var posX:Number = 0;

	        for (i = 0; i < this.columnCount; i++)
	    	{
	    		if ( multiHeader != null && multiHeader[i] != null && multiHeader[i] != '' )
	    		{
					var posMX:Number = this.columns[i].width;
			        for (j = i+1; j < this.columnCount; j++)
			    	{
			    		if ( multiHeader[i] == multiHeader[j] ) 
			    		{
			    			multiHeader[j] = '**equal**';
				    		posMX += this.columns[i].width;
			    			continue;
			    		}
			    		else
			    			break;
		    		}

		    		if ( multiHeader[i] != '**equal**' )
		    		{
						m_button = new Button();

			    		m_arMHbutton[i] = m_button;
			    		
						drawMTButton(m_arMHbutton[i], i, posX, posMX);
		    		}
    			
					m_button = new Button();
		    		m_arHbutton[i] = m_button;

					// $$$$ 2007-04-23 박재현 : 2.0.1 버전 삭제
//					m_button.addEventListener("click", OnHeaderClick);
		    		
					drawMBButton(m_arHbutton[i], i, posX);
					
					nMultiCnt++;
	    		}
	    		else
	    		{
					m_button = new Button();
		    		m_arHbutton[i] = m_button;

					// $$$$ 2007-04-23 박재현 : 2.0.1 버전 삭제
//					m_button.addEventListener("click", OnHeaderClick);

					drawSHButton(m_arHbutton[i], i, posX);
	    		}
	    		posX += this.columns[i].width;
	        }

			if ( nMultiCnt > 0 ) 
				m_bMultiHeader = true;
			else
				m_bMultiHeader = false;

		}

		// Resize 시 Header에 있는 버튼 크기를 조절
		private function OnmyResize(eventObj:Event):void 
		{

			var i:Number;
			if ( this.columns.length != m_arHbutton.length )
				return;

			var posX:Number = 0;

			for ( i=0 ; i < m_arMHbutton.length ; i++ )
			{
				var _button:Button = Button(m_arMHbutton[i]);
				
				if ( _button == null ) 
				{
					posX += this.columns[i].width;
					continue;
				}

				var posMX:Number = this.columns[i].width;
				
		        for (var j:Number = i+1; j < this.columnCount; j++)
		    	{
		    		if ( multiHeader[j] == '**equal**' ) 
		    		{
			    		posMX += this.columns[j].width + 1;
		    			continue;
		    		}
		    		else
		    			break;
	    		}

	    		if ( multiHeader[i] != '**equal**' )
	    		{
					_button.x = posX;
					_button.width = posMX;
	    		}
				posX += this.columns[i].width;
			}

			posX = 0;

			for ( i=0 ; i < m_arHbutton.length ; i++ )
			{
				m_arHbutton[i].x = posX;
				m_arHbutton[i].width = this.columns[i].width+1;
				posX += this.columns[i].width;
			}

		}

		override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}		

		// 각 Row의 뒷 배경색을 그림
	    override protected function drawRowBackgrounds():void
	    {
	        var rowBGs:Sprite = Sprite(listContent.getChildByName("rowBGs"));
	        if (!rowBGs)
	        {
	            rowBGs = new FlexSprite();
				rowBGs.mouseEnabled = false;
	            rowBGs.name = "rowBGs";
	            listContent.addChildAt(rowBGs, 0);
	        }

			var colors:Array = [0xeeeeee, 0xffffff];
	
			if (!colors || colors.length == 0)
				return;

			StyleManager.getColorNames(colors);
	
	        var curRow:int = 0;
	        if (showHeaders)
	            curRow++;
	
			var i:int = 0;
			var actualRow:int = verticalScrollPosition;
	        var n:int = listItems.length;

			while (curRow < n)
	        {
	            drawRowBackground(rowBGs, i++, rowInfo[curRow].y, rowInfo[curRow].height, colors[actualRow % colors.length], actualRow);

				// $$$$ 박재현 : Merge 관련 수정	            
	            if ( m_bEnableMerge == true )
	            {
					if ( curRow+1 < n && 
						listItems[curRow].length > 0 && listItems[curRow+1].length > 0 &&
						listItems[curRow][0].listData.label == listItems[curRow+1][0].listData.label )
						{
							listItems[curRow+1][0].htmlText = "";
						}
					else
						actualRow++;
	            }
	            else
					actualRow++;
	            

				curRow++;
	        }

			while (rowBGs.numChildren > i)
			{
	            rowBGs.removeChildAt(rowBGs.numChildren - 1);
			}
	    }

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 수정
		// Single Header 의 버튼을 그림
		private function drawSHButton(_button:Button, i:int, posX:int):void
		{
			_button.x = posX;
			_button.y = 00;
			_button.width = this.columns[i].width+1;
			_button.alpha = 1;
			_button.height = this.headerHeight-1;
			_button.label = arrColumn[i].headerText;
			
			_button.labelPlacement = this.columns[i].dataField;
			_button.visible = true;

			_button.setStyle("cornerRadius", 1);
			_button.setStyle("fillColors", m_headerColor);
			_button.setStyle("fillAlphas", [1, 1, 1, 1]);
			_button.setStyle("highlightAlphas", [1, 0]);
			_button.setStyle("fontSize", 11);
			_button.setStyle("fontFamily", "굴림");

			if ( listContent == null )
				return;
				
			listContent.addChild(_button);

	        var sortArrowHitArea:Sprite =
	            Sprite(listContent.getChildByName("sortArrowHitArea"));

			if ( sortArrowHitArea != null )
				listContent.setChildIndex(_button, listContent.getChildIndex(sortArrowHitArea)-1);

		}

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 수정
		// Multi Header 의 상단 버튼을 그림
		private function drawMTButton(_button:Button, i:int, posX:int, posMX:int):void
		{
			_button.x = posX;
			_button.y = 00;
			_button.width = posMX;
			_button.alpha = 1;
			_button.height = 20;
			_button.label = multiHeader[i];
			_button.labelPlacement = this.columns[i].dataField;
			_button.visible = true;

			_button.setStyle("cornerRadius", 1);
			_button.setStyle("fillColors", m_headerColor);
			_button.setStyle("fillAlphas", [1, 1, 1, 1]);
			_button.setStyle("highlightAlphas", [1, 0]);
			_button.setStyle("fontSize", 11);
			_button.setStyle("fontFamily", "굴림");

			if ( listContent == null )
				return;
			
			listContent.addChild(_button);


	        var sortArrowHitArea:Sprite =
	            Sprite(listContent.getChildByName("sortArrowHitArea"));

			if ( sortArrowHitArea != null )
				listContent.setChildIndex(_button, listContent.getChildIndex(sortArrowHitArea)-1);
		}

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 수정
		// Multi Header 의 하단 버튼을 그림
		private function drawMBButton(_button:Button, i:int, posX:int):void
		{
			_button.x = posX;
			_button.y = 20;
			_button.width = this.columns[i].width+1;
			_button.alpha = 1;
			_button.height = 20-1;
			_button.label = arrColumn[i].headerText;
			_button.labelPlacement = this.columns[i].dataField;
			_button.visible = true;

			_button.setStyle("cornerRadius", 1);
			_button.setStyle("fillColors", m_headerColor);
			_button.setStyle("fillAlphas", [1, 1, 1, 1]);
			_button.setStyle("highlightAlphas", [1, 0]);
			_button.setStyle("fontSize", 11);
			_button.setStyle("fontFamily", "굴림");

			if ( listContent == null )
				return;

			listContent.addChild(_button);

	        var sortArrowHitArea:Sprite =
	            Sprite(listContent.getChildByName("sortArrowHitArea"));

			if ( sortArrowHitArea != null )
				listContent.setChildIndex(_button, listContent.getChildIndex(sortArrowHitArea)-1);
		}

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 수정
		// 헤더 크기를 조절할 수있는 separator들을 그림
	    override protected function drawSeparators():void
	    {
	    	// $$$$ 20070423 박재현 : Flex 2.0.1 버전 업글 전 사항
/*
	        if (!separators)
	            separators = [];

	        var lines:Sprite = Sprite(listContent.getChildByName("lines"));

			var n:int = visibleColumns.length;
			for (var i:int = 0; i < n; i++)
	        {
	            var sep:IFlexDisplayObject;
	            if (i < lines.numChildren)
	            {
	                sep = IFlexDisplayObject(lines.getChildAt(i));
	            }
	            else
	            {
	                var headerSeparatorClass:Class =
						getStyle("headerSeparatorSkin");
	                sep = new headerSeparatorClass();
//	                lines.addChild(DisplayObject(sep));
//	                this.addChild(DisplayObject(sep));
					DisplayObject(sep).addEventListener(
						MouseEvent.MOUSE_OVER, columnResizeMouseOverHandler);
					DisplayObject(sep).addEventListener(
						MouseEvent.MOUSE_OUT, columnResizeMouseOutHandler);
					DisplayObject(sep).addEventListener(
						MouseEvent.MOUSE_DOWN, columnResizeMouseDownHandler);
//	                separator[i] = sep;
	                separators.push(sep);
	            }

	            if (!listItems || !listItems[0] || !listItems[0][i])
				{
					sep.visible = false;
	                continue;
				}
	
				sep.visible = true;
	            sep.x = listItems[0][i].x +
						visibleColumns[i].width - Math.round(sep.measuredWidth / 2 + 0.5);
				if (i > 0)
				{
	                sep.x = Math.max(sep.x,
									 separators[i - 1].x + Math.round(sep.measuredWidth / 2 + 0.5));
				}
	            sep.y = 0;

				// $$$$ 20070118 박재현 : 멀티헤더부분 수정

	    		if ( multiHeader != null && multiHeader[i] != null && multiHeader[i] != '' &&
	    			multiHeader[i+1] != null && multiHeader[i+1] != '')
	    		{
		            sep.y = 20;
		            sep.setActualSize(sep.measuredWidth, 20);
	    		}
	            else
	            {
		            sep.setActualSize(sep.measuredWidth,
									  rowInfo.length ?
									  rowInfo[0].height :
									  headerHeight);
	            }

				sep.name = String(i);
	        }
//	        while (lines.numChildren > visibleColumns.length)
	        while (separators.length > visibleColumns.length)
	        {
//	            this.removeChild(DisplayObject(separators[0]));
//	            lines.removeChildAt(lines.numChildren - 1);
	            separators.reverse();
	            separators.pop();
	            separators.reverse();
	        }
*/

	        if (!separators)
	            separators = [];
	
	        var lines:Sprite = Sprite(listContent.getChildByName("lines"));
	
			var n:int = visibleColumns.length;
			for (var i:int = 0; i < n; i++)
	        {
	            var sep:UIComponent;
	            var sepSkin:IFlexDisplayObject;
	            
	            if (i < lines.numChildren)
	            {
	                sep = UIComponent(lines.getChildAt(i));
	                sepSkin = IFlexDisplayObject(sep.getChildAt(0));
	            }
	            else
	            {
	                var headerSeparatorClass:Class =
	                    getStyle("headerSeparatorSkin");
	                sepSkin = new headerSeparatorClass();
	                if (sepSkin is ISimpleStyleClient)
	                    ISimpleStyleClient(sepSkin).styleName = this;
	                sep = new UIComponent();
	                sep.addChild(DisplayObject(sepSkin));
	                lines.addChild(sep);
//					this.setChildIndex(listContent, this.numChildren-1);

	                DisplayObject(sep).addEventListener(
	                    MouseEvent.MOUSE_OVER, columnResizeMouseOverHandler);
	                DisplayObject(sep).addEventListener(
	                    MouseEvent.MOUSE_OUT, columnResizeMouseOutHandler);
	                DisplayObject(sep).addEventListener(
	                    MouseEvent.MOUSE_DOWN, columnResizeMouseDownHandler);
	                separators.push(sep);
	            }
	
	            if (!listItems || !listItems[0] || !listItems[0][i])
				{
					sep.visible = false;
	                continue;
				}
	
				sep.visible = true;
	            sep.x = listItems[0][i].x +
						visibleColumns[i].width - Math.round(sep.measuredWidth / 2 + 0.5);
				if (i > 0)
				{
	                sep.x = Math.max(sep.x,
									 separators[i - 1].x + Math.round(sep.measuredWidth / 2 + 0.5));
				}
	            sep.y = 0;
	            
				// $$$$ 20070118 박재현 : 멀티헤더부분 수정

	    		if ( multiHeader != null && multiHeader[i] != null && multiHeader[i] != '' &&
	    			multiHeader[i+1] != null && multiHeader[i+1] != '')
	    		{
		            sep.y = 20;
		            sep.setActualSize(sep.measuredWidth, 20);
		            
		            // separator 그리기
		            sep.graphics.clear();
		            sep.graphics.beginFill(0xFFFFFF, 0);
		            sep.graphics.drawRect(-3/*separatorAffordance*/, 0, sepSkin.measuredWidth + 3/*separatorAffordance */, headerHeight/2);
		            sep.graphics.endFill();
		            
	    		}
	            else
	            {
		            sep.setActualSize(sep.measuredWidth,
									  rowInfo.length ?
									  rowInfo[0].height :
									  headerHeight);

		            // separator 그리기
		            sep.graphics.clear();
		            sep.graphics.beginFill(0xFFFFFF, 0);
		            sep.graphics.drawRect(-3/*separatorAffordance*/, 0, sepSkin.measuredWidth + 3/*separatorAffordance */, headerHeight);
		            sep.graphics.endFill();
	            }

	            // Draw invisible background for separator affordance
	            
	        }

	        while (lines.numChildren > visibleColumns.length)
	        {
	            lines.removeChildAt(lines.numChildren - 1);
	            separators.pop();
	        }

	    }


		// Column List를 입력받음
		public function set ArrColumn(value:Array):void
		{
			arrColumn = value;

			ChangeWatcher.watch(this, ["arrColumn"], columnChanged);
			columnChanged(null);
		}

		// Column이 변경되었을 때 처리할 사항들
		private function columnChanged(event:Event):void
		{
			var i:Number = 0;
			if ( arrColumn == null ) return;

			var newCol:Array = new Array();

	        for (i=0; i < arrColumn.length; i++)
	    	{
				var dgCol:DataGridColumn = new DataGridColumn();

				dgCol.dataField = arrColumn[i].dataField;
				dgCol.headerText = "";
				dgCol.resizable = true;
				if ( arrColumn[i].width != null )
					dgCol.width = arrColumn[i].width;
				newCol.push(dgCol);
	    	}

			this.columns = newCol;

			multiHeader = new Array();			

			for ( i=0 ; i < arrColumn.length ; i++ )
			{
				if ( arrColumn[i].multiHeader == null ) continue;
				if ( arrColumn[i].multiHeader == "" ) continue;

				multiHeader[i] = String(arrColumn[i].multiHeader);
			}

			if ( multiHeader.length == 0 )	multiHeader = null;

			myCreateButton();

		}

		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		// DataGrid.as source 에서 가져옴
		// 리사이즈 할때 Mouse Over 상태에 대한 처리
	    private function columnResizeMouseOverHandler(event:MouseEvent):void
	    {
	        if (!enabled || !resizableColumns)
				return;

			var target:DisplayObject = DisplayObject(event.target);
//			var index:int = target.parent.getChildIndex(target);
			var index:int = int(target.name);
			if (!visibleColumns[index].resizable)
				return;
	
	        // hide the mouse, attach and show the cursor
	        var stretchCursorClass:Class = getStyle("stretchCursor");
	        resizeCursorID = CursorManager.setCursor(stretchCursorClass,
													 CursorManagerPriority.HIGH);
	    }
	
		// DataGrid.as source 에서 가져옴
		// 리사이즈 할때 Mouse Out 상태에 대한 처리
	    private function columnResizeMouseOutHandler(event:MouseEvent):void
	    {
	        if (!enabled || !resizableColumns)
				return;
	
			var target:DisplayObject = DisplayObject(event.target);
//			var index:int = target.parent.getChildIndex(target);
			var index:int = int(target.name);
			if (!visibleColumns[index].resizable)
				return;
	
	        CursorManager.removeCursor(resizeCursorID);
	    }

		// DataGrid.as source 에서 가져옴
		// 리사이즈 할때 Mouse Down 상태에 대한 처리
	    private function columnResizeMouseDownHandler(event:MouseEvent):void
	    {
	        if (!enabled || !resizableColumns)
				return;
	
			var target:DisplayObject = DisplayObject(event.target);
//			var index:int = target.parent.getChildIndex(target);
			var index:int = int(target.name);
			if (!visibleColumns[index].resizable)
				return;

			if (itemEditorInstance)
				endEdit(DataGridEventReason.OTHER);

			ResizeStartX = DisplayObject(event.target).x;
			
            resizingColumnNow = visibleColumns[0];
			

			var n:int = separators.length;
			for (var i:int = 0; i < n; i++)
	        {
	            if (separators[i] == event.target)
	            {
	                resizingColumnNow = visibleColumns[i];
	                break;
	            }
	        }
	        if (!resizingColumnNow)
	            return;
	
			ResizeMinX = listItems[0][i].x + resizingColumnNow.minWidth;
	
			isPressed = true;
	
	        systemManager.addEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
	        systemManager.addEventListener(MouseEvent.MOUSE_UP, columnResizeMouseUpHandler, true);

	        var resizeSkinClass:Class = getStyle("columnResizeSkin");
	        resizeGraphic = new resizeSkinClass();
	        listContent.addChild(DisplayObject(resizeGraphic));
	        resizeGraphic.move(DisplayObject(event.target).x, 0);
	        resizeGraphic.setActualSize(resizeGraphic.measuredWidth,
										unscaledHeight);
	    }
	
		// DataGrid.as source 에서 가져옴
		// 리사이즈 도중 그래픽 처리
	    private function columnResizingHandler(event:MouseEvent):void
	    {
	        if (!MouseEvent(event).buttonDown)
	        	columnResizeMouseUpHandler(event);
	        
	        var vsw:int = verticalScrollBar ? verticalScrollBar.width : 0;
	
			var pt:Point = new Point(event.stageX, event.stageY);
			pt = globalToLocal(pt);
	        resizeGraphic.move(Math.min(Math.max(ResizeMinX, pt.x),
							   unscaledWidth - separators[0].width - vsw), 0);
	    }
	    
		// DataGrid.as source 에서 가져옴
		// 리사이즈 할때 Mouse Up 상태에 대한 처리
	    private function columnResizeMouseUpHandler(event:MouseEvent):void
	    {
	        if (!enabled || !resizableColumns)
				return;
	
			isPressed = false;
	
	        systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
	        systemManager.removeEventListener(MouseEvent.MOUSE_UP, columnResizeMouseUpHandler, true);
	
	        listContent.removeChild(DisplayObject(resizeGraphic));
	
	        CursorManager.removeCursor(resizeCursorID);
	
	        var c:DataGridColumn = resizingColumnNow;
	        resizingColumnNow = null;
	
	        // need to find the visible column index here.
	        var n:int = visibleColumns.length;
			var i:int;
	        for (i = 0; i < n; i++)
	        {
	        	if (c == visibleColumns[i])
	        		break;
	        }
			if (i >= visibleColumns.length)
				return;
	
	        var vsw:int = verticalScrollBar ? verticalScrollBar.width : 0;
	
			var pt:Point = new Point(event.stageX, event.stageY);
			pt = globalToLocal(pt);
	
	        // resize the column
	        var widthChange:Number = Math.min(Math.max(ResizeMinX, pt.x),
				unscaledWidth - separators[0].width - vsw) - ResizeStartX;
	        resizeColumn(i, Math.floor(c.width + widthChange));
	
	        // event
	        var dataGridEvent:DataGridEvent =
	            new DataGridEvent(DataGridEvent.COLUMN_STRETCH);
	        dataGridEvent.columnIndex = c.colNum;
	        dataGridEvent.dataField = c.dataField;
	        dataGridEvent.localX = pt.x;
	        dispatchEvent(dataGridEvent);
	    }

		// DataGrid.as source 에서 가져옴
		// FDS를 사용하지 않아서 이해 못함 ;
	    private function endEdit(reason:String):Boolean
	    {
			// this happens if the renderer is removed asynchronously ususally with FDS
			if (!editedItemRenderer)
				return true;
	
			inEndEdit = true;
	
	        var dataGridEvent:DataGridEvent =
	            new DataGridEvent(DataGridEvent.ITEM_EDIT_END, false, true);
				// ITEM_EDIT events are cancelable
	        dataGridEvent.columnIndex = editedItemPosition.columnIndex;
	        dataGridEvent.dataField = _columns[editedItemPosition.columnIndex].dataField;
	        dataGridEvent.rowIndex = editedItemPosition.rowIndex;
			dataGridEvent.itemRenderer = editedItemRenderer;
			dataGridEvent.reason = reason;
	        dispatchEvent(dataGridEvent);
			// set a flag to not open another edit session if the item editor is still up
			// this means somebody wants the old edit session to stay.
			dontEdit = itemEditorInstance != null;
			// trace("dontEdit", dontEdit);
	
			if (!dontEdit && reason == DataGridEventReason.CANCELLED)
			{
				losingFocus = true;
				setFocus();
			}
	
			inEndEdit = false;

			return !(dataGridEvent.isDefaultPrevented())
		}

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 추가
		// Multi Header 을 그릴때 상단 버튼 위로 Line 그려지는것믈 막기위해 상속
	    override protected function drawVerticalLine(s:Sprite, colIndex:int, color:uint, x:Number):void
	    {
	        //draw our vertical lines
	        var g:Graphics = s.graphics;
	        if (lockedColumnCount > 0 && colIndex == lockedColumnCount - 1)
	            g.lineStyle(1, 0, 100);
	        else
	            g.lineStyle(1, color, 100);
//	        g.moveTo(x, 1);
	        g.moveTo(x, headerHeight);
	        g.lineTo(x, listContent.height);
	    }
	    
		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 추가
		// Column 순서 변경시 arrColum 에도 반영하기 위해 상속
	    override mx_internal function shiftColumns(oldIndex:int, newIndex:int,
	                                      trigger:Event = null):void
	    {
	    	super.shiftColumns(oldIndex, newIndex, trigger);
	    	
			if (newIndex >= 0 && oldIndex != newIndex)
			{
		    	var tempObj:Object = new Object();
				tempObj = this.arrColumn[oldIndex];
				arrColumn[oldIndex] = arrColumn[newIndex];
				arrColumn[newIndex] = tempObj;
				
				columnChanged(null);
			}
	    }

		// $$$$ 2007-04-23 박재현 : 2.0.1 버전 추가
		// Sort Arrow가 그려지는 것을 막음
		// 시간이 없어서 Arrow그리는거 나중으로 미룸
		override protected function placeSortArrow():void
		{
//			super.placeSortArrow();
		}

	}
}