package itemRenderer
{
 import mx.containers.HBox;
 import mx.controls.Image;
 import mx.controls.Text;
 
 public class DataGridRenderer extends HBox
 {
  private var hbx:HBox;
  private var _image:Image;
  private var _valueData:String;
  private var _text:Text;
  
  public function DataGridRenderer()
  {
   super();
   hbx = new HBox();
   hbx.percentWidth = 100;
   hbx.setStyle("horizontalAlign","center");
   hbx.setStyle("height","300");
   _image = new Image();
   _text = new Text();
   
  }
  
  public function set valueData(value:String):void
  {
   this._valueData = value; 
  }
  
  public function get valueData():String
  {
   return _valueData;
  }
  
  override public function set data(value:Object):void
  {
   super.data = value;
   
   if(super.data["imagePath"] != undefined && super.data["imagePath"] != null && super.data["imagePath"] != "")
   {
    this.removeAllChildren();
    _image.source = super.data["imagePath"];
    _text.text = _valueData;
    
    addChild(_image);
    addChild(_text);
   } else {
    this.removeAllChildren();
    _text.text = _valueData;
    addChild(_text);
   }
  }
 }
}