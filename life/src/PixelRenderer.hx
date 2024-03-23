class PixelRenderer {

    public var pixels:Array<{x:Int, y:Int}>;
    var length:Int;
  
    public function new() {
        pixels = [];
      }
  
    public function render(level:PixelLevel) {
  
      length = level.width * level.height; 
  
      // Add alive pixels
      for (y in 0...level.height) {
        for (x in 0...level.width) {
          if (level.isAlive(x, y)) {
            pixels.push({x: x, y: y}); 
          }
        }
      }
  
      // Draw pixels
      for (p in pixels) {
        drawPixel(p.x, p.y); 
      }
  
    }
  
    function drawPixel(x:Int, y:Int) {
        #if js
        var canvas:js.html.CanvasElement = js.Browser.document.createCanvasElement();
        var ctx = canvas.getContext2d();
        #end
      }
  
  }