import format.swf.Data.RGBA;
import format.png.Data.Chunk;
import format.png.Reader;
import format.png.Data.Header;
import format.png.Data.Color;
import haxe.zip.Uncompress;

class PixelLevel {
	public var width:Int;
	public var height:Int;

	var pixels:Array<Bool>;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
		pixels = new Array<Bool>();
	}

	public function isAlive(x:Int, y:Int):Bool {
		return pixels[y * width + x];
	}

	public function setAlive(x:Int, y:Int, value:Bool):Void {
		pixels[y * width + x] = value;
	}

	public function countAliveNeighbors(x:Int, y:Int):Int {
		var count = 0;

		// Scan x-1 to x+1
		for (nx in x - 1...x + 2) {
			// Scan y-1 to y+1
			for (ny in y - 1...y + 2) {
				if (isAlive(nx, ny))
					count++;
			}
		}

		// Exclude self
		if (isAlive(x, y))
			count--;

		return count;
	}

	// Other methods for simulation rules, rendering, etc.

	public function seed(pattern:String):Void {
		// Based on pattern name, initialize pixels

		if (pattern == "Glider") {
			// Set pixels for Glider shape
		} else if (pattern == "Pulsar") {
			// Set pixels for Pulsar shape
		}
		// Other patterns...
	}

	public function update():Void {
		// Update pixel states based on simulation rules

		var newPixels = pixels.copy();

		for (y in 0...height) {
			for (x in 0...width) {
				var neighbors = countAliveNeighbors(x, y);

				// Apply rules
				if (isAlive(x, y) && (neighbors < 2 || neighbors > 3)) {
					newPixels[y * width + x] = false; // Die unless 2-3 neighbors
				} else if (!isAlive(x, y) && neighbors == 3) {
					newPixels[y * width + x] = true; // Birth if exactly 3 neighbors
				}
			}
		}

		pixels = newPixels;
	}

	public function render(renderer:PixelRenderer):Void {
		// Pass pixels to renderer
		renderer.render(this);
	}

	public function loadImage(bytes:haxe.io.Bytes) {
		// Parse header
		var header = createHeader(bytes);

		// Get width and height
		var width = header.width;
		var height = header.height;

		// Get image data bytes
		var reader = new format.png.Reader(new haxe.io.BytesInput(bytes));
        var chunks:Array<Chunk> = reader.read();
		var imageData = getImageData(chunks);

		// Create input
		var input = new haxe.io.BytesInput(imageData);

		// Create reader
		var reader = new format.png.Reader(input);

		// Load pixels
		for (y in 0...height) {
			for (x in 0...width) {
				var rgba = getPixel(bytes, x, y);
				setPixel(x, y, rgba);
			}
		}
	}

	function createHeader(bytes:Bytes):Header {
		var reader = new format.png.Reader(new haxe.io.BytesInput(bytes));
		var width = bytes.getInt32(16);
		var height = bytes.getInt32(20);

		var header:Header = {
			width: width,
			interlaced: false,
			height: height,
			color: format.png.Color.ColIndexed,
			colbits: 8
		};
		return header;
	}

	function getImageData(chunks:Array<Chunk>):Bytes {
		for (chunk in chunks) {
			switch (chunk) {
				case CEnd:
					// Handle CEnd case
					break;
				case CHeader(header):
					// Handle CHeader case
					break;
				case CPalette(header):
					// Handle CPalette case
					break;
				case CUnknown(id, bytes):
					// Handle CUnknown case, access id and bytes
					break;
				case CData(bytes):
					return bytes;
			}
		}
		return null;
	}

    function decompressPNG(data:Bytes):Bytes {
        return Uncompress.run(data);
    }

    function getPixel(bytes:Bytes, x:Int, y:Int):RGBA {

        // Get image data bytes
		var reader = new format.png.Reader(new haxe.io.BytesInput(bytes));
        var chunks:Array<Chunk> = reader.read();
        var imgBytes = getImageData(chunks);
        
        // Decompress PNG data
        var img = decompressPNG(imgBytes);
      
        // Get pixel bytes
        var offset = 4 * (y * width + x);
        var r = img.get(offset);
        var g = img.get(offset + 1); 
        var b = img.get(offset + 2);
        var a = img.get(offset + 3);
      
        return {r: r, g: g, b: b, a: a};
      }

	function setPixel(x:Int, y:Int, rgba:RGBA) {
		// Set alive state based on alpha
		var alive = rgba.a > 0;
		setAlive(x, y, alive);
	}
}
